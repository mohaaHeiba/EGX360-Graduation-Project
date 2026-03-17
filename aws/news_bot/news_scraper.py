import time
import feedparser
import trafilatura
import firebase_admin
import re
import random
import json
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

# ======================= AI Imports =======================
from cerebras.cloud.sdk import Cerebras
from transformers import pipeline

# ==============================================================================
# 1. Config & AI Initialization
# ==============================================================================
SUPABASE_URL = "https://zlcddmhcxtxvgzxcfvxx.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpsY2RkbWhjeHR4dmd6eGNmdnh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyOTM0MTcsImV4cCI6MjA4MDg2OTQxN30.F5SxofdTfi9oBO3db1nygSXIiYEqoXgZ0OTW_Fu5Kew"
CEREBRAS_APIKEY = "csk-ywf42kf845xf43crjpphnn9crt28698w8xpkx8ef5p4rdcew"

SERVICE_ACCOUNT_PATH = "service_account.json"

# تهيئة قواعد البيانات
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
cerebras_client = Cerebras(api_key=CEREBRAS_APIKEY)

if not firebase_admin._apps:
    try:
        cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
        firebase_admin.initialize_app(cred)
    except Exception as e: 
        print(f"⚠️ Firebase Init Error: {e}")

print("🤖 Loading FinBERT model for English news (Offline Hugging Face)...")
# تحميل موديل FinBERT للإنجليزي (متدرب على الأخبار المالية)
finbert = pipeline("text-classification", model="ProsusAI/finbert", truncation=True, max_length=512)

# ==============================================================================
# 2. AI Processing Functions
# ==============================================================================

def is_arabic(text):
    """التعرف التلقائي على اللغة: لو فيه حروف عربي يبقى عربي"""
    return bool(re.search(r'[\u0600-\u06FF]', str(text)))

def process_arabic_with_cerebras(title, content):
    """استخدام Cerebras لتنظيف الخبر العربي وفلترته وتصنيفه دون أي اختصار"""
    prompt = f"""
    أنت خبير مالي ومحرر صحفي لأسواق المال. قم بمعالجة الخبر التالي:
    1. VALID: هل الخبر سليم وله معنى مالي حقيقي؟ (True/False) - لو كان مجرد هراء أو حروف عشوائية أو إعلان اجعلها False.
    2. SENTIMENT: صنف تأثير الخبر (Positive أو Negative أو Neutral).
    3. TEXT: قم بتنظيف الخبر من أي إعلانات أو روابط، ولكن إياك أن تختصره أو تقصره. يجب الحفاظ على الخبر كاملاً بجميع تفاصيله وأرقامه ودسامته الأصلية.
    
    الخبر الأصلي:
    Title: {title}
    Content: {str(content)[:2500]}
    
    الرد يجب أن يكون بهذا التنسيق النصي الصارم فقط:
    [START]
    VALID: <True or False>
    SENTIMENT: <Positive or Negative or Neutral>
    TEXT: <النص الكامل النظيف هنا>
    [END]
    """
    try:
        response = cerebras_client.chat.completions.create(
            messages=[
                {"role": "system", "content": "You are a precise financial editor. DO NOT summarize. Use only the [START] and [END] block format."},
                {"role": "user", "content": prompt}
            ],
            model="llama3.1-8b",
            temperature=0.1,
            max_tokens=3000 # زودنا التوكنز عشان ياخد راحته في الكتابة وميقصش الكلام
        )
        
        raw_text = response.choices[0].message.content
        block = re.search(r'\[START\](.*?)\[END\]', raw_text, re.DOTALL)
        
        if block:
            data = block.group(1)
            valid_str = re.search(r'VALID:\s*(.+)', data).group(1).strip()
            sentiment = re.search(r'SENTIMENT:\s*(.+)', data).group(1).strip().capitalize()
            text_match = re.search(r'TEXT:\s*(.*)', data, re.DOTALL)
            
            is_valid = True if 'True' in valid_str else False
            clean_text = text_match.group(1).strip() if text_match else content
            
            return is_valid, sentiment, clean_text
            
        return True, "Neutral", content
    except Exception as e:
        print(f"      ⚠️ Cerebras Error: {e}")
        return True, "Neutral", content

def process_english_with_finbert(title, content):
    """استخدام Hugging Face (FinBERT) للأخبار الإنجليزية"""
    text_to_analyze = f"{title}. {content}"
    try:
        result = finbert(text_to_analyze)[0]
        return result['label'].capitalize()
    except Exception as e:
        print(f"      ⚠️ FinBERT Error: {e}")
        return "Neutral"

# ==============================================================================
# 3. Helpers (Cleaners & Logic)
# ==============================================================================

def clean_html(html_content):
    if not html_content: return ""
    soup = BeautifulSoup(html_content, "html.parser")
    return soup.get_text(separator="\n").strip()

def clean_and_validate_content(text, description, title):
    """تنظيف مبدئي للنصوص وفلترة رسائل الحماية (Cloudflare)"""
    if not text:
        text = ""
        
    # 🛡️ 1. فلتر صائد لرسائل الحماية (Cloudflare/Bot Protection)
    bot_protection_phrases = [
        "This website uses a security service",
        "protect against malicious bots",
        "verifies you are not a bot",
        "Enable JavaScript and cookies to continue",
        "Performance and Security by",
        "Verification successful"
    ]
    
    # لو لقينا أي جملة من بتوع الحماية، هنمسح النص كله عشان نُجبر السكربت يستخدم الـ Description
    if any(phrase.lower() in text.lower() for phrase in bot_protection_phrases):
        print("      🛡️ Cloudflare Bot Protection detected! Falling back to description.")
        text = "" # تفريغ النص بالكامل

    if len(text) < 20:
        cleaned_desc = clean_html(description) if description else ""
        return "" if cleaned_desc.strip() == title.strip() else cleaned_desc

    text = re.sub(r'<[^>]+>', '', text)
    
    # ✂️ 2. علامات التوقف (Stop Markers)
    stop_markers = [
        r"جريدة المال هي جريدة", r"تقدم تغطية شاملة لآخر أخبار", 
        r"إيكونومي بلس عبر واتس اب", r"اضغط هنا", r"حقوق النشر محفوظة", 
        r"مواضيع متعلقة", r"اقرأ أيضاً", r"إقرأ أيضاً", r"قد يعجبك أيضاً", 
        r"الأكثر قراءة", r"©", r"تم التصميم والتطوير", r"كلمات دالة",
        r"تابعوا آخر أخبار اليوم السابع", r"أرشيفية\s*:\s*مشاركة الخبر"
    ]
    
    for marker in stop_markers:
        if re.search(marker, text, flags=re.IGNORECASE):
            parts = re.split(marker, text, flags=re.IGNORECASE)
            text = parts[0]

    # 3. حذف العنوان لو تكرر في أول الخبر
    if title and title.strip() in text[:150]:
        text = text.replace(title.strip(), "", 1).strip()

    text = re.sub(r'(?<!\d)\.(?!\d)\s+([أ-ي])', r'.\n\n\1', text)

    # 4. تنظيف الزيادات (Junk)
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
        
        # بنقلل شرط الطول شوية عشان الإنجليزي
        if len(line.split()) > 3 or has_numbers or has_finance or is_list or len(line) > 40:
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
    # إضافة when:5d بتجبر جوجل يجيب أحدث الأخبار في آخر 5 أيام وبيتجاهل القديم تماماً
    query = f'"{clean_name}" AND (سهم OR بورصة OR أرباح OR تداول OR اقتصاد OR جنيه) when:5d'
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
    return True, datetime.now(timezone.utc)

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

# ==============================================================================
# 4. Database Saving & AI Routing
# ==============================================================================

def save_news_to_db(stock_id, symbol, title, description, content, url, source, pub_date):
    try:
        # فحص إذا كان الرابط موجود مسبقاً
        check = supabase.table("stock_news").select("id").eq("url", url).execute()
        if check.data: 
            print(f"      ⏭️ Already exists (URL Match): {url[:40]}...")
            return

        # فحص تشابه العناوين
        if is_duplicate_news(stock_id, title):
            print(f"      🚫 Skipped Duplicate Title: {title[:30]}...")
            return

        final_description = clean_html(description)
        if final_description.strip() == title.strip(): final_description = ""

        # التنظيف الأولي للخبر
        base_content = clean_and_validate_content(content, description, title)
        
        if not base_content or len(base_content) < 100:
            print(f"      ⚠️ Content too thin ({len(base_content)} chars), trying description...")
            base_content = final_description if len(final_description) > 50 else ""

        if not base_content:
            print(f"      ❌ Dropped: No usable content found.")
            return 

        # 🧠 توجيه الخبر للذكاء الاصطناعي (عربي / إنجليزي)
        print(f"      🧠 AI Analysis Started...")
        if is_arabic(title + base_content):
            is_valid, sentiment, final_content = process_arabic_with_cerebras(title, base_content)
            
            # لو الـ AI قال إن الخبر ملوش لازمة أو هراء، هنرميه فوراً
            if not is_valid:
                print(f"      🗑️ AI Dropped: Invalid or garbage Arabic content.")
                return
            print(f"      🤖 Cerebras (Arabic) -> Sentiment: {sentiment}")
        else:
            # لو الخبر إنجليزي، نستخدم FinBERT للتصنيف والمحتوى المنظف مبدئياً
            sentiment = process_english_with_finbert(title, base_content)
            final_content = base_content 
            print(f"      🤖 FinBERT (English) -> Sentiment: {sentiment}")

        # حفظ البيانات في Supabase بشكل مفصول (المحتوى لوحده والتصنيف لوحده)
        data = {
            "stock_id": stock_id, 
            "title": title, 
            "description": final_description[:500],
            "content": final_content, # المحتوى الكامل النظيف
            "url": url, 
            "source": source,
            "sentiment_label": sentiment, # التصنيف في العمود الجديد
            "published_at": pub_date.isoformat()
        }
        
        supabase.table("stock_news").insert(data).execute()
        print(f"      ✅ Successfully Saved! ({len(final_content)} chars) | Sentiment: {sentiment}")
        
        # إرسال إشعار للمستخدمين (يمكن إيقافه لو مش محتاجه دلوقتي)
        send_notification(symbol, title, url)
        
    except Exception as e:
        print(f"      ❌ DB Error: {e}")

# ==============================================================================
# 5. Scraper Engines
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
            
            entries = feed.entries[:5]
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
    driver = setup_stock_driver() # هنستخدم نفس متصفح الأسهم عشان نجيب الداتا من جوجل
    try:
        print(f"\n{'='*50}\n💎 CRYPTO ENGINE: Processing {len(crypto_list)} coins\n{'='*50}")
        for coin in crypto_list:
            symbol, name_en, coin_id = coin['symbol'], coin['company_name_en'], coin['id']
            
            # بنعمل طلب بحث مخصص لكل عملة لوحدها على Google News بالإنجليزي
            query = f'("{name_en}" OR "{symbol} crypto" OR "{symbol} coin") when:5d'
            encoded_query = quote(query)
            rss_url = f"https://news.google.com/rss/search?q={encoded_query}&hl=en-US&gl=US&ceid=US:en"

            print(f"\n📡 [{symbol}] Scanning Google News (Crypto)...")
            feed = feedparser.parse(rss_url)
            
            # هناخد آخر 2 أخبار لكل عملة عشان منستهلكش وقت طويل
            entries = feed.entries[:5]
            print(f"   Found {len(feed.entries)} entries, taking top {len(entries)}")

            for entry in entries:
                title = entry.title
                print(f"\n   💎 Title: {title[:60]}...")
                
                # زودنا المدة لـ 4 أيام عشان الكريبتو أخباره متقلبة
                fresh, pub_date = is_fresh_news(entry, max_days=4)
                if not fresh:
                    print(f"      ⏩ Skipped: Too old ({pub_date})")
                    continue

                if is_blacklisted(entry.link):
                    print(f"      ⏩ Skipped: Blacklisted domain")
                    continue

                if is_duplicate_news(coin_id, title):
                    print(f"      🚫 Skipped: Duplicate title detected in DB")
                    continue

                print(f"      🚀 Resolving URL with Selenium...")
                final_url = resolve_url_with_selenium(entry.link, driver)

                content = None
                rss_desc = clean_html(entry.description) if 'description' in entry else ""

                try:
                    downloaded = trafilatura.fetch_url(final_url)
                    if downloaded:
                        content = trafilatura.extract(downloaded, include_formatting=True, include_links=False)
                except Exception: pass

                if not content or len(content) < 400:
                    try:
                        content = BeautifulSoup(driver.page_source, "html.parser").get_text(separator="\n").strip()
                    except: pass

                # الحفظ وتوجيه الذكاء الاصطناعي (FinBERT هيشتغل أوتوماتيك لأن الخبر إنجليزي)
                save_news_to_db(coin_id, symbol, title, rss_desc, content, final_url, "Google News Crypto", pub_date)
            
            time.sleep(random.uniform(1, 3))
    finally:
        print("\n🛑 Closing Chrome Driver (Crypto)...")
        driver.quit()

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