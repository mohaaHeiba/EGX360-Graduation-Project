import time
import feedparser
import trafilatura
import firebase_admin
import re
import random
from difflib import SequenceMatcher # <--- دي المسئولة عن كشف التشابه
from firebase_admin import credentials, messaging
from bs4 import BeautifulSoup
from datetime import datetime, timezone
from dateutil import parser
from supabase import create_client, Client
from urllib.parse import quote
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from webdriver_manager.chrome import ChromeDriverManager

# ==============================================================================
# 1. Config
# ==============================================================================
SUPABASE_URL = "https://zlcddmhcxtxvgzxcfvxx.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpsY2RkbWhjeHR4dmd6eGNmdnh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyOTM0MTcsImV4cCI6MjA4MDg2OTQxN30.F5SxofdTfi9oBO3db1nygSXIiYEqoXgZ0OTW_Fu5Kew"
SERVICE_ACCOUNT_PATH = "service_account.json"

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

if not firebase_admin._apps:
    try:
        cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
        firebase_admin.initialize_app(cred)
    except: pass

# ==============================================================================
# 2. Helpers (Cleaners & Logic)
# ==============================================================================

def clean_html(html_content):
    if not html_content: return ""
    soup = BeautifulSoup(html_content, "html.parser")
    return soup.get_text().strip()

def clean_and_validate_content(text, description, title):
    if not text:
        return description if description else title

    text = re.sub(r'<[^>]+>', '', text)
    text = re.sub(r'\s+', ' ', text).strip()

    garbage_phrases = [
        "javascript is disabled", "enable javascript", "browser is not supported",
        "please turn on javascript", "access denied", "security check",
        "solve a puzzle", "verifies that you are not a bot", "attention required",
        "oops! page", "page not found", "404", "moment please",
        "checking your browser", "cloudflare", "redirecting",
        "one more step", "human verification", "copyright 20", "all rights reserved",
        "المزيد من أجلك", "يرجى استكمال الفحص الأمني", "إكمال اختبار captcha",
        "جميع الحقوق محفوظة", "تأكد أنك إنسان"
    ]

    text_lower = text.lower()
    for phrase in garbage_phrases:
        if phrase in text_lower:
            return description if description and len(description) > 20 else title

    if len(text) < 80:
        return description if description and len(description) > 20 else text

    return text

def is_blacklisted(url):
    bad_domains = [
        "facebook.com", "twitter.com", "instagram.com", "youtube.com",
        "tiktok.com", "linkedin.com", "google.com/search", "pinterest"
    ]
    for domain in bad_domains:
        if domain in url.lower(): return True
    return False

def build_smart_query(company_name, symbol):
    clean_name = company_name.replace("المصرية", "").replace("القابضة", "").strip()
    query = f'"{clean_name}" AND (سهم OR بورصة OR أرباح OR تداول OR اقتصاد OR جنيه)'
    return quote(query)

def is_fresh_news(entry, max_days=3):
    try:
        if hasattr(entry, 'published_parsed'):
            pub_date = datetime(*entry.published_parsed[:6])
            pub_date = pub_date.replace(tzinfo=timezone.utc)
            now = datetime.now(timezone.utc)
            if (now - pub_date).days > max_days:
                return False, pub_date
            return True, pub_date
        elif hasattr(entry, 'published'):
             pub_date = parser.parse(entry.published)
             if pub_date.tzinfo is None: pub_date = pub_date.replace(tzinfo=timezone.utc)
             now = datetime.now(timezone.utc)
             return (now - pub_date).days <= max_days, pub_date
    except: pass
    return True, datetime.now()

# ---------------------------------------------------------
# 🔥 دالة كشف التكرار الجديدة (Anti-Duplicate Logic)
# ---------------------------------------------------------
def is_duplicate_news(stock_id, new_title):
    try:
        # هات آخر 10 أخبار للسهم ده من الداتابيز
        res = supabase.table("stock_news")\
            .select("title")\
            .eq("stock_id", stock_id)\
            .order("created_at", desc=True)\
            .limit(10)\
            .execute()

        if not res.data: return False

        new_title_clean = re.sub(r'[^\w\s]', '', new_title) # شيل الرموز للمقارنة

        for news in res.data:
            old_title = news['title']
            old_title_clean = re.sub(r'[^\w\s]', '', old_title)

            # قارن نسبة التشابه (من 0 لـ 1)
            similarity = SequenceMatcher(None, new_title_clean, old_title_clean).ratio()

            # لو التشابه أكبر من 70%، يبقى ده خبر مكرر
            if similarity > 0.70:
                return True

        return False
    except:
        return False

def send_notification(symbol, news_title, news_url):
    try:
        res = supabase.table("user_watchlist").select("profiles(fcm_token)").eq("stock_symbol", symbol).execute()
        tokens = list(set([i['profiles']['fcm_token'] for i in res.data if i.get('profiles') and i['profiles'].get('fcm_token')]))

        if not tokens: return

        message = messaging.MulticastMessage(
            notification=messaging.Notification(title=f"📢 {symbol} News", body=news_title[:100]+"..."),
            android=messaging.AndroidConfig(priority='high', notification=messaging.AndroidNotification(sound='default', channel_id='stock_news')),
            data={'type': 'stock_news', 'symbol': symbol, 'url': news_url, 'click_action': 'FLUTTER_NOTIFICATION_CLICK'},
            tokens=tokens
        )
        messaging.send_each_for_multicast(message)
    except: pass

def save_news_to_db(stock_id, symbol, title, description, content, url, source, pub_date):
    try:
        # 1. فحص الرابط (التطابق التام)
        check = supabase.table("stock_news").select("id").eq("url", url).execute()
        if check.data: return

        # 2. فحص التشابه (التطابق في المعنى/العنوان)
        if is_duplicate_news(stock_id, title):
            print(f"      🚫 Skipped Duplicate: {title[:30]}...")
            return

        final_content = clean_and_validate_content(content, description, title)

        data = {
            "stock_id": stock_id,
            "title": title,
            "description": description[:500],
            "content": final_content,
            "url": url,
            "source": source,
            "published_at": pub_date.isoformat()
        }
        supabase.table("stock_news").insert(data).execute()
        send_notification(symbol, title, url)
        print(f"      ✅ Saved: {title[:40]}...")
    except Exception as e:
        print(f"      ❌ Save Error: {e}")

# ==============================================================================
# 3. Engines
# ==============================================================================

# --- A. CRYPTO ENGINE ---
def process_crypto(crypto_list):
    print(f"\n{'='*40}")
    print(f"💎 CRYPTO ENGINE STARTED ({len(crypto_list)} coins)")
    print(f"{'='*40}")

    sources = {
        "CoinTelegraph": "https://cointelegraph.com/rss",
        "CoinDesk": "https://www.coindesk.com/arc/outboundfeeds/rss/"
    }

    for coin in crypto_list:
        slug = coin['company_name_en'].lower().strip().replace(" ", "-")
        sources[f"Tag: {coin['symbol']}"] = f"https://cointelegraph.com/rss/tag/{slug}"

    for src_name, url in sources.items():
        try:
            feed = feedparser.parse(url)
            if feed.entries:
                feed.entries.sort(key=lambda x: x.get('published_parsed', time.gmtime()), reverse=True)

            for entry in feed.entries[:10]:
                title = entry.title
                link = entry.link
                fresh, pub_date = is_fresh_news(entry, max_days=2)
                if not fresh: continue

                desc = clean_html(entry.summary) if 'summary' in entry else ""
                full_text = f"{title} {desc}".lower()

                for coin in crypto_list:
                    symbol = coin['symbol']
                    is_match = (src_name == f"Tag: {symbol}") or \
                               (f" {coin['company_name_en'].lower()} " in full_text) or \
                               (f" {symbol.lower()} " in full_text)

                    if is_match:
                        print(f"   💎 Match: [{symbol}] {title[:30]}...")
                        # الكريبتو مش بنعمله check duplicate قوي عشان مصادره قليلة ومحددة
                        save_news_to_db(coin['id'], symbol, title, desc, desc, link, "Crypto News", pub_date)

        except Exception as e:
            print(f"   ⚠️ RSS Error ({src_name}): {e}")

# --- B. STOCKS ENGINE ---
def setup_stock_driver():
    print("🌐 Starting Headless Chrome Driver...")
    chrome_options = Options()
    chrome_options.add_argument("--headless=new")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--blink-settings=imagesEnabled=false")
    chrome_options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
    return webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=chrome_options)

def resolve_url_with_selenium(google_url, driver):
    try:
        driver.get(google_url)
        time.sleep(1.5)
        if "consent.google.com" in driver.current_url:
            try:
                btns = driver.find_elements(By.TAG_NAME, 'button')
                for btn in btns:
                    if btn.text in ['Accept all', 'I agree', 'موافق']:
                        btn.click(); time.sleep(1); break
            except: pass

        for _ in range(8):
            if "news.google.com" not in driver.current_url: return driver.current_url
            time.sleep(0.5)
        return driver.current_url
    except: return google_url

def process_stocks(stocks_list):
    driver = setup_stock_driver()
    try:
        print(f"\n{'='*40}")
        print(f"🇪🇬 STOCK ENGINE STARTED ({len(stocks_list)} items)")
        print(f"{'='*40}")

        for stock in stocks_list:
            symbol = stock['symbol']
            name_ar = stock['company_name_ar']
            stock_id = stock['id']

            encoded_query = build_smart_query(name_ar, symbol)
            rss_url = f"https://news.google.com/rss/search?q={encoded_query}&hl=ar&gl=EG&ceid=EG:ar"

            print(f"\n🔎 [{symbol}] Scanning...")
            feed = feedparser.parse(rss_url)

            if feed.entries:
                feed.entries.sort(key=lambda x: x.get('published_parsed', time.gmtime()), reverse=True)

            processed_count = 0
            for entry in feed.entries:
                if processed_count >= 2: break

                title = entry.title
                fresh, pub_date = is_fresh_news(entry, max_days=3)
                if not fresh: continue

                if is_blacklisted(entry.link): continue

                # 🔥 فحص سريع قبل ما نتعب نفسنا ونفتح السيلينيوم
                # لو العنوان مكرر، منضيعش وقت في فتح الرابط
                if is_duplicate_news(stock_id, title):
                    print(f"      🚫 Skipped Duplicate Title: {title[:30]}...")
                    continue

                print(f"   📰 Processing: {title[:40]}...")
                final_url = resolve_url_with_selenium(entry.link, driver)

                if is_blacklisted(final_url): continue

                content = None
                rss_desc = clean_html(entry.description) if 'description' in entry else ""

                if "news.google.com" not in final_url:
                    try:
                        downloaded = trafilatura.fetch_url(final_url, no_ssl=True)
                        if downloaded:
                            content = trafilatura.extract(downloaded, include_comments=False)
                    except: pass

                if not content:
                    try:
                        content = trafilatura.extract(driver.page_source, include_comments=False)
                    except: pass

                save_news_to_db(stock_id, symbol, title, rss_desc, content, final_url, "Google News", pub_date)
                processed_count += 1

            time.sleep(random.uniform(2, 4))

    finally:
        driver.quit()

# ==============================================================================
# 4. MAIN RUNNER
# ==============================================================================
if __name__ == "__main__":
    print(f"🚀 Job Started: {datetime.now()}")
    try:
        print("📥 Loading DB...")
        all_stocks = supabase.table("stocks").select("*").execute().data

        crypto = [s for s in all_stocks if 'Crypto' in s.get('sector', '')]
        stocks = [s for s in all_stocks if 'Crypto' not in s.get('sector', '')]

        if crypto: process_crypto(crypto)
        if stocks: process_stocks(stocks)

    except Exception as e:
        print(f"\n🚨 CRITICAL ERROR: {e}")
    print(f"\n✅ Job Finished: {datetime.now()}")
