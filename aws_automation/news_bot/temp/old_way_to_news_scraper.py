import time
import feedparser
import trafilatura
import firebase_admin
from firebase_admin import credentials, messaging
from bs4 import BeautifulSoup
from datetime import datetime
from supabase import create_client, Client
from urllib.parse import quote
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from webdriver_manager.chrome import ChromeDriverManager

# --- 1. Supabase Config ---
SUPABASE_URL = "https://zlcddmhcxtxvgzxcfvxx.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpsY2RkbWhjeHR4dmd6eGNmdnh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyOTM0MTcsImV4cCI6MjA4MDg2OTQxN30.F5SxofdTfi9oBO3db1nygSXIiYEqoXgZ0OTW_Fu5Kew"

# --- 2. Firebase Config ---
SERVICE_ACCOUNT_PATH = "service_account.json"

# Initialize Clients
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

if not firebase_admin._apps:
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    firebase_admin.initialize_app(cred)

# --- 3. Utility Functions ---

def clean_html(html_content):
    if not html_content: return ""
    soup = BeautifulSoup(html_content, "html.parser")
    return soup.get_text()

def setup_driver():
    print("🌐 Starting Headless Chrome Driver...")
    chrome_options = Options()
    # إعدادات السيرفر الأساسية لتجنب الـ Crash
    chrome_options.add_argument("--headless=new")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--blink-settings=imagesEnabled=false") # تسريع السحب
    chrome_options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")

    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=chrome_options)
    return driver

def resolve_url_with_selenium(google_url, driver):
    """Bypasses Google Consent and resolves the actual news URL"""
    try:
        driver.get(google_url)
        time.sleep(2)

        # تخطي صفحة الموافقة لو ظهرت
        if "consent.google.com" in driver.current_url:
            print("      🛡️ Consent page detected. Bypassing...")
            try:
                consent_buttons = driver.find_elements(By.TAG_NAME, 'button')
                for btn in consent_buttons:
                    if btn.text in ['Accept all', 'I agree', 'Agree', 'موافق', 'قبول الكل']:
                        btn.click()
                        time.sleep(2)
                        break
            except: pass

        # انتظار التحويل للرابط الأصلي
        for _ in range(10):
            current_url = driver.current_url
            if "news.google.com" not in current_url and "consent.google.com" not in current_url:
                return current_url
            time.sleep(1)

        return driver.current_url
    except Exception as e:
        print(f"      ⚠️ URL Resolution failed: {e}")
        return google_url

def send_stock_notification(symbol, news_title, news_url):
    """Sends professional FCM notifications to interested users"""
    try:
        # جلب التوكنز للمهتمين فقط
        res = supabase.table("user_watchlist") \
            .select("user_id, profiles(fcm_token)") \
            .eq("stock_symbol", symbol) \
            .execute()

        tokens = [item['profiles']['fcm_token'] for item in res.data if item.get('profiles') and item['profiles'].get('fcm_token')]

        if not tokens: return

        display_title = f"📈 Market Update: {symbol}"
        display_body = (news_title[:100] + "...") if len(news_title) > 100 else news_title

        message = messaging.MulticastMessage(
            notification=messaging.Notification(
                title=display_title,
                body=display_body,
            ),
            android=messaging.AndroidConfig(
                priority='high',
                notification=messaging.AndroidNotification(sound='default', channel_id='stock_news')
            ),
            data={
                'type': 'stock_news',
                'symbol': symbol,
                'url': news_url,
                'click_action': 'FLUTTER_NOTIFICATION_CLICK'
            },
            tokens=tokens
        )

        response = messaging.send_each_for_multicast(message)
        print(f"      🔔 FCM Sent: {response.success_count} success, {response.failure_count} failure.")
    except Exception as e:
        print(f"      ❌ FCM Error: {e}")

# --- 4. Main Process ---

def fetch_and_store_news():
    start_time = datetime.now()
    print(f"\n{'='*65}")
    print(f"🚀 PRODUCTION CYCLE STARTED: {start_time.strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"{'='*65}")

    driver = setup_driver()
    total_new_articles = 0

    try:
        print("📥 Fetching stock list from database...")
        response = supabase.table("stocks").select("id, symbol, company_name_en").execute()
        stocks_list = response.data
        print(f"✅ Found {len(stocks_list)} stocks to process.")

        for stock in stocks_list:
            stock_id, symbol, company_name_en = stock['id'], stock['symbol'], stock['company_name_en']

            search_query = company_name_en if company_name_en else f"{symbol} Stock"
            encoded_query = quote(f"{search_query} Egypt Stock")
            rss_url = f"https://news.google.com/rss/search?q={encoded_query}&hl=en-US&gl=EG&ceid=EG:en"

            print(f"\n🔎 [{symbol}] Syncing news...")
            feed = feedparser.parse(rss_url)

            for entry in feed.entries[:8]:
                try:
                    title = entry.title

                    # منع التكرار
                    check_existing = supabase.table("stock_news").select("id").eq("title", title).execute()
                    if len(check_existing.data) > 0: continue

                    print(f"   📰 New Found: {title[:55]}...")
                    final_url = resolve_url_with_selenium(entry.link, driver)

                    # استخراج المحتوى
                    content = None
                    description = clean_html(entry.description) if 'description' in entry else ""

                    if "news.google.com" not in final_url:
                        try:
                            downloaded = trafilatura.fetch_url(final_url)
                            if downloaded:
                                content = trafilatura.extract(downloaded, include_comments=False)
                        except: pass

                    final_content_for_db = content if (content and len(content) > 200) else description
                    source_status = "✅ Full Content" if content and len(content) > 200 else "⚠️ Fallback to Summary"

                    # حفظ في Supabase
                    news_data = {
                        "stock_id": stock_id,
                        "title": title,
                        "description": description,
                        "content": final_content_for_db,
                        "url": final_url,
                        "source": entry.source.title if 'source' in entry else "News Source",
                        "published_at": datetime(*entry.published_parsed[:6]).isoformat() if 'published_parsed' in entry else datetime.now().isoformat()
                    }

                    supabase.table("stock_news").upsert(news_data, on_conflict="url").execute()

                    # إرسال إشعار
                    send_stock_notification(symbol, title, final_url)

                    total_new_articles += 1
                    print(f"      {source_status} | Saved & Notified.")

                except Exception as e:
                    print(f"      ❌ Article Error: {e}")

    except Exception as e:
        print(f"\n🚨 CRITICAL SYSTEM ERROR: {e}")
    finally:
        driver.quit()
        end_time = datetime.now()
        print(f"\n{'='*65}")
        print(f"📊 Cycle Finished. Total New Articles: {total_new_articles}")
        print(f"⏱️ Runtime: {end_time - start_time}")
        print(f"{'='*65}")

if __name__ == "__main__":
    # تشغيل الدالة مرة واحدة فقط
    fetch_and_store_news()
