import time
import feedparser
import trafilatura
import firebase_admin
import re
import random
from difflib import SequenceMatcher 
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
    return soup.get_text(separator="\n").strip()

def clean_and_validate_content(text, description, title):
    if not text or len(text) < 20:
        cleaned_desc = clean_html(description) if description else ""
        return "" if cleaned_desc.strip() == title.strip() else cleaned_desc

    text = re.sub(r'<[^>]+>', '', text)
    
    # ✂️ منطق الـ Stop Condition
    stop_markers = [
        r"جريدة المال هي جريدة", r"تقدم تغطية شاملة لآخر أخبار", 
        r"إيكونومي بلس عبر واتس اب", r"اضغط هنا", r"حقوق النشر محفوظة", 
        r"مواضيع متعلقة", r"اقرأ أيضاً", r"إقرأ أيضاً", r"قد يعجبك أيضاً", 
        r"الأكثر قراءة", r"©", r"تم التصميم والتطوير", r"كلمات دالة",
        r"تابعوا آخر أخبار اليوم السابع", r"أرشيفية\s*:\s*مشاركة الخبر"
    ]
    
    for marker in stop_markers:
        if re.search(marker, text, flags=re.IGNORECASE):
            # print(f"      ✂️ Stop Marker Hit: [{marker}]") # اختياري لو عايز تعرف بالظبط اتقص فين
            parts = re.split(marker, text, flags=re.IGNORECASE)
            text = parts[0]

    # حذف العنوان لو تكرر
    if title and title.strip() in text[:150]:
        text = text.replace(title.strip(), "", 1).strip()

    # منظم السطور
    text = re.sub(r'(?<!\d)\.(?!\d)\s+([أ-ي])', r'.\n\n\1', text)

    junk_patterns = [
        r"(Facebook|Twitter|Pinterest|Linkedin|Whatsapp|Telegram|Email)", 
        r"بواسطة\s*[:\s]*[\w\s]+", r"كتبت?\s*[:\s]*[\w\s]+",   
        r"\d+\s*:\s*\d+\s*(م|ص)", r"الرابط المختصر.*", r"\|\s*\|\s*[\w-]+",
        r"جميع الحقوق محفوظة", r"النشر\s*\d+", r"00:00\s*/\s*00:16"
    ]
    for pattern in junk_patterns:
        text = re.sub(pattern, '', text, flags=re.IGNORECASE)

    lines = text.split('\n')
    cleaned_lines = []
    seen_lines = set() 
    
    important_keywords = ["سعر", "جنيه", "سهم", "بورصة", "ارباح", "تراجع", "ارتفاع", "حديد", "بنك", "أسمدة", "صفقة"]
    
    for line in lines:
        line = line.strip()
        if not line or len(line) < 3: continue
        line_mini = line[:60].lower()
        if line_mini in seen_lines: continue

        has_numbers = any(char.isdigit() for char in line)
        has_finance = any(key in line for key in important_keywords)
        is_list = bool(re.match(r'^(\d+[\.\-\)]|•|\*)', line))
        
        if len(line.split()) > 3 or has_numbers or has_finance or is_list or len(line) > 50:
            cleaned_lines.append(line)
            seen_lines.add(line_mini)
            
    text = '\n\n'.join(cleaned_lines)
    text = re.sub(r'[ \t]+', ' ', text)
    text = re.sub(r'\n\s*\n', '\n\n', text)
    return text.strip()

def is_blacklisted(url):
    bad_domains = ["facebook.com", "twitter.com", "instagram.com", "youtube.com", "google.com/search"]
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
            pub_date = datetime(*entry.published_parsed[:6]).replace(tzinfo=timezone.utc)
            return (datetime.now(timezone.utc) - pub_date).days <= max_days, pub_date
        elif hasattr(entry, 'published'):
             pub_date = parser.parse(entry.published)
             if pub_date.tzinfo is None: pub_date = pub_date.replace(tzinfo=timezone.utc)
             return (datetime.now(timezone.utc) - pub_date).days <= max_days, pub_date
    except: pass
    return True, datetime.now()

def is_duplicate_news(stock_id, new_title):
    try:
        res = supabase.table("stock_news").select("title").eq("stock_id", stock_id).order("created_at", desc=True).limit(10).execute()
        if not res.data: return False
        new_title_clean = re.sub(r'[^\w\s]', '', new_title)
        for news in res.data:
            similarity = SequenceMatcher(None, new_title_clean, re.sub(r'[^\w\s]', '', news['title'])).ratio()
            if similarity > 0.70: return True
        return False
    except: return False

def send_notification(symbol, news_title, news_url):
    try:
        res = supabase.table("user_watchlist").select("profiles(fcm_token)").eq("stock_symbol", symbol).execute()
        tokens = list(set([i['profiles']['fcm_token'] for i in res.data if i.get('profiles') and i['profiles'].get('fcm_token')]))
        if not tokens: return
        message = messaging.MulticastMessage(
            notification=messaging.Notification(title=f"📢 {symbol} News", body=news_title[:100]+"..."),
            android=messaging.AndroidConfig(priority='high', notification=messaging.AndroidNotification(sound='default', channel_id='stock_news')),
            data={'type': 'stock_news', 'symbol': symbol, 'url': news_url},
            tokens=tokens
        )
        messaging.send_each_for_multicast(message)
        print(f"      🔔 Notification sent to {len(tokens)} users")
    except Exception as e:
        print(f"      ⚠️ Notification Error: {e}")

def save_news_to_db(stock_id, symbol, title, description, content, url, source, pub_date):
    try:
        check = supabase.table("stock_news").select("id").eq("url", url).execute()
        if check.data: 
            print(f"      ⏭️ Already exists (URL Match): {url[:40]}...")
            return

        if is_duplicate_news(stock_id, title):
            print(f"      🚫 Skipped Duplicate Title: {title[:30]}...")
            return

        final_description = clean_html(description)
        if final_description.strip() == title.strip(): final_description = ""

        final_content = clean_and_validate_content(content, description, title)
        
        if not final_content or len(final_content) < 100:
            print(f"      ⚠️ Content too thin ({len(final_content)} chars), trying description...")
            final_content = final_description if len(final_description) > 50 else ""

        if not final_content:
            print(f"      ❌ Dropped: No usable content found.")
            return 

        data = {
            "stock_id": stock_id, "title": title, "description": final_description[:500],
            "content": final_content, "url": url, "source": source,
            "published_at": pub_date.isoformat()
        }
        supabase.table("stock_news").insert(data).execute()
        print(f"      ✅ Successfully Saved! ({len(final_content)} chars)")
        send_notification(symbol, title, url)
    except Exception as e:
        print(f"      ❌ DB Error: {e}")

# ==============================================================================
# 3. Engines
# ==============================================================================

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
        time.sleep(2)
        if "consent.google.com" in driver.current_url:
            try:
                btns = driver.find_elements(By.TAG_NAME, 'button')
                for btn in btns:
                    if btn.text in ['Accept all', 'I agree', 'موافق']:
                        btn.click(); time.sleep(1); break
            except: pass
        return driver.current_url
    except: return google_url

def process_stocks(stocks_list):
    driver = setup_stock_driver()
    try:
        print(f"\n{'='*50}\n🇪🇬 STOCK ENGINE: Processing {len(stocks_list)} items\n{'='*50}")
        for stock in stocks_list:
            symbol, name_ar, stock_id = stock['symbol'], stock['company_name_ar'], stock['id']
            encoded_query = build_smart_query(name_ar, symbol)
            rss_url = f"https://news.google.com/rss/search?q={encoded_query}&hl=ar&gl=EG&ceid=EG:ar"

            print(f"\n🔎 [{symbol}] Scanning RSS...")
            feed = feedparser.parse(rss_url)
            
            entries = feed.entries[:2]
            print(f"   Found {len(feed.entries)} entries, taking top {len(entries)}")

            for entry in entries:
                title = entry.title
                print(f"\n   📰 Title: {title[:60]}...")
                
                fresh, pub_date = is_fresh_news(entry, max_days=3)
                if not fresh:
                    print(f"      ⏩ Skipped: Too old ({pub_date})")
                    continue

                if is_blacklisted(entry.link):
                    print(f"      ⏩ Skipped: Blacklisted domain")
                    continue

                if is_duplicate_news(stock_id, title):
                    print(f"      🚫 Skipped: Duplicate title detected in DB")
                    continue

                print(f"      🚀 Resolving URL with Selenium...")
                final_url = resolve_url_with_selenium(entry.link, driver)
                print(f"      🔗 Final URL: {final_url[:50]}...")

                content = None
                rss_desc = clean_html(entry.description) if 'description' in entry else ""

                try:
                    print(f"      📥 Attempting Trafilatura...")
                    downloaded = trafilatura.fetch_url(final_url)
                    if downloaded:
                        content = trafilatura.extract(downloaded, include_formatting=True, include_links=False)
                except Exception as e:
                    print(f"      ⚠️ Trafilatura Error: {e}")

                if not content or len(content) < 400:
                    print(f"      🔄 Falling back to BS4/Selenium source...")
                    try:
                        content = BeautifulSoup(driver.page_source, "html.parser").get_text(separator="\n").strip()
                    except: pass

                save_news_to_db(stock_id, symbol, title, rss_desc, content, final_url, "Google News", pub_date)
            
            time.sleep(random.uniform(2, 4))
    finally:
        print("\n🛑 Closing Chrome Driver...")
        driver.quit()

def process_crypto(crypto_list):
    print(f"\n{'='*50}\n💎 CRYPTO ENGINE: Processing {len(crypto_list)} coins\n{'='*50}")
    sources = {"CoinTelegraph": "https://cointelegraph.com/rss", "CoinDesk": "https://www.coindesk.com/arc/outboundfeeds/rss/"}
    for src_name, url in sources.items():
        try:
            print(f"📡 Checking {src_name} RSS...")
            feed = feedparser.parse(url)
            for entry in feed.entries[:5]:
                title, link = entry.title, entry.link
                fresh, pub_date = is_fresh_news(entry, max_days=2)
                if not fresh: continue
                
                desc = clean_html(entry.summary) if 'summary' in entry else ""
                full_text = f"{title} {desc}".lower()

                for coin in crypto_list:
                    if coin['company_name_en'].lower() in full_text or coin['symbol'].lower() in full_text:
                        print(f"   💎 Match found for [{coin['symbol']}]: {title[:40]}...")
                        save_news_to_db(coin['id'], coin['symbol'], title, desc, desc, link, src_name, pub_date)
        except Exception as e: 
            print(f"   ⚠️ RSS Error ({src_name}): {e}")

if __name__ == "__main__":
    start_time = datetime.now()
    print(f"🚀 Job Started: {start_time}")
    try:
        print("📥 Loading stocks from Supabase...")
        all_stocks = supabase.table("stocks").select("*").execute().data
        print(f"✅ Loaded {len(all_stocks)} items from DB")

        crypto = [s for s in all_stocks if 'Crypto' in s.get('sector', '')]
        stocks = [s for s in all_stocks if 'Crypto' not in s.get('sector', '')]

        if crypto: process_crypto(crypto)
        if stocks: process_stocks(stocks)

    except Exception as e: 
        print(f"\n🚨 CRITICAL ERROR: {e}")
    
    end_time = datetime.now()
    print(f"\n✅ Job Finished: {end_time}")
    print(f"⏱️ Total Duration: {end_time - start_time}")