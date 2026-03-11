import time
import feedparser
import trafilatura
import re
import pandas as pd
import os
from bs4 import BeautifulSoup
from datetime import datetime, timezone
from dateutil import parser
from urllib.parse import quote
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

# ==============================================================================
# 1. Config & Local Data (EGX30 Index)
# ==============================================================================
CSV_FILE = "stock_news.csv"

# قائمة أسهم مؤشر EGX30 (أكبر وأنشط 30 شركة في البورصة المصرية)
EGX_STOCKS = [
    {'id': 1, 'symbol': 'TMGH', 'name': 'مجموعة طلعت مصطفى'},
    {'id': 2, 'symbol': 'COMI', 'name': 'البنك التجاري الدولي'},
    {'id': 3, 'symbol': 'FWRY', 'name': 'فوري'},
    {'id': 4, 'symbol': 'ABUK', 'name': 'أبوقير للأسمدة'},
    {'id': 5, 'symbol': 'EAST', 'name': 'ايسترن كومباني'},
    {'id': 6, 'symbol': 'EFIH', 'name': 'إي فاينانس'},
    {'id': 7, 'symbol': 'EMFD', 'name': 'إعمار مصر'},
    {'id': 8, 'symbol': 'ETEL', 'name': 'المصرية للاتصالات'},
    {'id': 9, 'symbol': 'EXPA', 'name': 'البنك المصري لتنمية الصادرات'},
    {'id': 10, 'symbol': 'HRHO', 'name': 'إي اف جي القابضة'},
    {'id': 11, 'symbol': 'ESRS', 'name': 'حديد عز'}, 
    {'id': 12, 'symbol': 'SWDY', 'name': 'السويدي إليكتريك'},
    {'id': 13, 'symbol': 'PHDC', 'name': 'بالم هيلز للتعمير'},
    {'id': 14, 'symbol': 'MASR', 'name': 'مدينة مصر للإسكان'},
    {'id': 15, 'symbol': 'BTFH', 'name': 'بلتون القابضة'},
    {'id': 16, 'symbol': 'ORHD', 'name': 'أوراسكوم للتنمية مصر'},
    {'id': 17, 'symbol': 'MFPC', 'name': 'موبكو للأسمدة'},
    {'id': 18, 'symbol': 'SKPC', 'name': 'سيدي كرير للبتروكيماويات'},
    {'id': 19, 'symbol': 'HELI', 'name': 'مصر الجديدة للإسكان'},
    {'id': 20, 'symbol': 'AMOC', 'name': 'الإسكندرية للزيوت المعدنية'},
    {'id': 21, 'symbol': 'ISPH', 'name': 'ابن سينا فارما'},
    {'id': 22, 'symbol': 'JUFO', 'name': 'جهينة للصناعات الغذائية'},
    {'id': 23, 'symbol': 'ADIB', 'name': 'مصرف أبو ظبي الإسلامي'},
    {'id': 24, 'symbol': 'CIRA', 'name': 'سيرا للتعليم'},
    {'id': 25, 'symbol': 'DOMT', 'name': 'دومتي'},
    {'id': 26, 'symbol': 'ORAS', 'name': 'أوراسكوم كونستراكشون'},
    {'id': 27, 'symbol': 'SUGR', 'name': 'الدلتا للسكر'},
    {'id': 28, 'symbol': 'MTIE', 'name': 'إم إم جروب'},
    {'id': 29, 'symbol': 'CCAP', 'name': 'القلعة للاستشارات المالية'},
    {'id': 30, 'symbol': 'ALCN', 'name': 'الإسكندرية لتداول الحاويات'},
]

# متغير عالمي لتخزين اللينكات وتجنب التكرار بسرعة الصاروخ
EXISTING_URLS = set()

# ==============================================================================
# 2. Helpers (Cleaners & CSV Logic)
# ==============================================================================

def init_csv():
    global EXISTING_URLS
    if not os.path.exists(CSV_FILE):
        df = pd.DataFrame(columns=['id', 'stock_id', 'title', 'description', 'content', 'url', 'source', 'published_at', 'created_at'])
        df.to_csv(CSV_FILE, index=False, encoding='utf-16')
        print(f"📁 Created new CSV file: {CSV_FILE}")
    else:
        try:
            df_existing = pd.read_csv(CSV_FILE, encoding='utf-16')
            if 'url' in df_existing.columns:
                EXISTING_URLS = set(df_existing['url'].dropna().tolist())
                print(f"📊 Loaded {len(EXISTING_URLS)} existing URLs from CSV to skip duplicates.")
        except Exception as e:
            print(f"⚠️ Error loading existing CSV (might be empty): {e}")

def clean_html(html_content):
    if not html_content: return ""
    soup = BeautifulSoup(html_content, "html.parser")
    return soup.get_text(separator="\n").strip()

def clean_and_validate_content(text, description, title):
    if not text or len(text) < 20:
        cleaned_desc = clean_html(description) if description else ""
        return "" if cleaned_desc.strip() == title.strip() else cleaned_desc

    text = re.sub(r'<[^>]+>', '', text)
    
    stop_markers = [
        r"جريدة المال هي جريدة", r"تقدم تغطية شاملة لآخر أخبار", 
        r"إيكونومي بلس عبر واتس اب", r"اضغط هنا", r"حقوق النشر محفوظة", 
        r"مواضيع متعلقة", r"اقرأ أيضاً", r"إقرأ أيضاً", r"قد يعجبك أيضاً", 
        r"الأكثر قراءة", r"©", r"تم التصميم والتطوير", r"كلمات دالة",
        r"تابعوا آخر أخبار اليوم السابع", r"أرشيفية\s*:\s*مشاركة الخبر"
    ]
    
    for marker in stop_markers:
        parts = re.split(marker, text, flags=re.IGNORECASE)
        text = parts[0]

    if title and title.strip() in text[:150]:
        text = text.replace(title.strip(), "", 1).strip()

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

def build_smart_query(company_name):
    query = f'"{company_name}" AND (سهم OR بورصة OR أرباح OR تداول OR اقتصاد OR جنيه)'
    return quote(query)

def is_fresh_news(entry, max_days=365): 
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

def save_news_to_csv(stock_id, title, description, content, url, source, pub_date):
    global EXISTING_URLS
    try:
        if url in EXISTING_URLS:
            return

        final_description = clean_html(description)
        if final_description.strip() == title.strip(): final_description = ""

        final_content = clean_and_validate_content(content, description, title)
        
        if not final_content or len(final_content) < 120:
            final_content = final_description if len(final_description) > 50 else ""

        if not final_content: return 

        new_row = {
            "id": int(time.time() * 1000), 
            "stock_id": stock_id,
            "title": title,
            "description": final_description[:500],
            "content": final_content,
            "url": url,
            "source": source,
            "published_at": pub_date.isoformat(),
            "created_at": datetime.now().isoformat()
        }

        df_new = pd.DataFrame([new_row])
        df_new.to_csv(CSV_FILE, mode='a', header=not os.path.exists(CSV_FILE), index=False, encoding='utf-16')
        
        EXISTING_URLS.add(url)
        print(f"      ✅ Saved to CSV! ({len(final_content)} chars)")
        
    except Exception as e:
        print(f"      ❌ CSV Save Error: {e}")

# ==============================================================================
# 3. Engines
# ==============================================================================

def setup_stock_driver():
    print("🌐 Starting Headless Chrome Driver...")
    chrome_options = Options()
    chrome_options.add_argument("--headless=new")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
    return webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=chrome_options)

def resolve_url_with_selenium(google_url, driver):
    try:
        driver.get(google_url)
        time.sleep(1.5)
        return driver.current_url
    except: return google_url

def process_stocks():
    init_csv() 
    driver = setup_stock_driver()
    try:
        print(f"\n{'='*50}\n🇪🇬 EGX30 MASSIVE DATASET COLLECTOR STARTED 🚀\n{'='*50}")
        for stock in EGX_STOCKS:
            symbol, name_ar, stock_id = stock['symbol'], stock['name'], stock['id']
            encoded_query = build_smart_query(name_ar)
            rss_url = f"https://news.google.com/rss/search?q={encoded_query}&hl=ar&gl=EG&ceid=EG:ar"

            print(f"\n🔎 [{symbol}] Searching for 100 news items for '{name_ar}'...")
            feed = feedparser.parse(rss_url)
            
            entries = feed.entries[:100] 
            print(f"   Found {len(feed.entries)} total, processing top {len(entries)}")

            for entry in entries:
                title = entry.title
                
                # فحص سريع لعدم التكرار قبل حرق الموارد
                if entry.link in EXISTING_URLS:
                     continue

                fresh, pub_date = is_fresh_news(entry, max_days=365) 
                if not fresh:
                    continue
                
                print(f"\n   📰 Title: {title[:70]}...")
                print(f"      🚀 Resolving and Scraping...")
                final_url = resolve_url_with_selenium(entry.link, driver)

                content = None
                rss_desc = clean_html(entry.description) if 'description' in entry else ""

                try:
                    downloaded = trafilatura.fetch_url(final_url)
                    if downloaded:
                        content = trafilatura.extract(downloaded, include_formatting=True)
                except: pass

                if not content or len(content) < 400:
                    try:
                        content = BeautifulSoup(driver.page_source, "html.parser").get_text(separator="\n").strip()
                    except: pass

                save_news_to_csv(stock_id, title, rss_desc, content, final_url, "Google News", pub_date)
            
            time.sleep(5) 
    finally:
        driver.quit()

if __name__ == "__main__":
    start_time = datetime.now()
    process_stocks()
    print(f"\n✅ EGX30 Dataset Collection Finished! Total Time: {datetime.now() - start_time}")