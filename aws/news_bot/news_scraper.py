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
    """استخدام Cerebras لتنظيف الخبر العربي وفلترته وتصنيفه بصرامة تامة"""
    prompt = f"""
    أنت آلة برمجية صارمة لتنظيف وتصنيف البيانات. لا تمتلك آراء شخصية. لا تقم بكتابة أي مقدمات أو نهايات أو تحليلات.
    مهمتك محددة في 3 نقاط فقط:
    1. VALID: هل النص يمثل خبر مقروء ومفهوم؟ (True/False). إذا كان النص عبارة عن حروف عشوائية، أو بيانات ملتصقة ببعضها (مثل: كودالترقيمالشركة)، أو لا يحمل معنى، اكتب False.
    2. SENTIMENT: صنف الخبر (Positive أو Negative أو Neutral).
    3. TEXT: أعد كتابة النص الأصلي كما هو تماماً، ولكن احذف منه فقط (الإعلانات، الروابط، الكلمات المفتاحية، جمل مثل "اقرأ أيضا"). 
    
    تحذير صارم: ممنوع منعاً باتاً إضافة أي رأي، أو تحليل، أو تلخيص للخبر. النص المنظف يجب أن يكون مطابقاً للأصلي بدون الزيادات الإعلانية.
    
    الخبر الأصلي:
    Title: {title}
    Content: {str(content)[:2500]}
    
    يجب أن يكون الرد حصرياً داخل هذا القالب، وبدون أي كلمة قبله أو بعده:
    [START]
    VALID: <True or False>
    SENTIMENT: <Positive or Negative or Neutral>
    TEXT: <النص الكامل النظيف هنا>
    [END]
    """
    try:
        response = cerebras_client.chat.completions.create(
            messages=[
                # غيرنا دور الـ System عشان يبقى آلة مش بني آدم
                {"role": "system", "content": "You are a strict data extraction machine. ONLY output the requested format. NEVER add opinions, summaries, or conversational text."},
                {"role": "user", "content": prompt}
            ],
            model="llama3.1-8b",
            temperature=0.01, # 👈 قللنا الـ Temperature جداً عشان نلغي الإبداع والتأليف تماماً
            max_tokens=3000 
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
            
        # لو الـ AI غبي ومردش بالقالب، بنعتبر الخبر سليم وبنرجع النص زي ما هو عشان منخسروش
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

def is_blacklisted(url, title=""):
    url_lower = url.lower()
    
    bad_domains = ["facebook.com", "twitter.com", "instagram.com", "youtube.com", "google.com/search"]
    for domain in bad_domains:
        if domain in url_lower: 
            return True
            
    # 👈 فلترة العناوين المضروبة (إفصاحات البورصة الخام اللي بتيجي من مباشر)
    if title:
        bad_title_patterns = ["كود الترقيم", "الشركةاسم", "نموذج تقرير إفصاح", "EFG HOLDING", "إفصاح مكمل"]
        for pattern in bad_title_patterns:
            if pattern in title:
                print(f"      🚫 Skipped: Raw Exchange Disclosure (Bad Title)")
                return True
                
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



def scrape_vetogate(soup):
    """استخراج النص الصافي من موقع فيتو"""
    # المحتوى الفعلي لخبر "فيتو" موجود دايماً جوه div الكلاس بتاعه paragraph-list
    content_div = soup.find('div', class_='paragraph-list')
    
    if not content_div:
        return None # بنرجع None عشان الروتر يفهم إنه فشل ويشغل الطريقة القديمة
        
    # تنظيف أي صور أو سكربتات جوه النص نفسه
    for tag in content_div.find_all(['figure', 'script', 'style']):
        tag.decompose()
        
    # استخراج النص مع وضع مسافات بين الفقرات
    text = content_div.get_text(separator="\n\n").strip()
    
    # تنظيف المسافات الفاضية الزيادة
    text = re.sub(r'\n\s*\n', '\n\n', text)
    
    return text




def scrape_almasryalyoum(soup):
    """استخراج النص الصافي من موقع المصري اليوم"""
    # المصري اليوم غالباً بيحط الخبر جوه div الكلاس بتاعه article-body أو id اسمه NewsStory
    content_div = soup.find('div', id='NewsStory') or soup.find('div', class_='article-body')
    
    # لو ملقناش الحاوية دي لأي سبب، هنشتغل على الـ HTML كله
    if not content_div:
        content_div = soup

    # 1. تنظيف الفخاخ (الإعلانات والأخبار الجانبية)
    junk_classes = ['related-article-inside-body', 'article-body-ad', 'no-print']
    for junk in junk_classes:
        for tag in content_div.find_all('div', class_=junk):
            tag.decompose()

    # تنظيف أي أكواد Style أو Script جوا النص
    for tag in content_div.find_all(['script', 'style']):
        tag.decompose()

    # 2. تنظيف لينكات "اقرأ أيضاً" اللي بتبقى في آخر الخبر
    # الفكرة: لو البراجراف <p> مفيش جواه غير لينك <a> ونفس النص، يبقى ده ترويج ونمسحه
    for p_tag in content_div.find_all('p'):
        a_tag = p_tag.find('a')
        if a_tag:
            # بنقارن نص البراجراف بنص اللينك، لو متطابقين يبقى ده مجرد لينك ترويجي
            if p_tag.get_text(strip=True) == a_tag.get_text(strip=True):
                p_tag.decompose()

    # 3. استخراج النص الصافي (هنسحب العناوين والبراجرافات بس عشان نتجنب أي داتا عشوائية)
    text_parts = []
    for tag in content_div.find_all(['p', 'h1', 'h2', 'h3']):
        text = tag.get_text(separator=" ").strip()
        # هنتجاهل الكلمات الصريحة اللي بتفضل زي "قد يهمك"
        if text and text != "قد يهمك":
            text_parts.append(text)

    final_text = "\n\n".join(text_parts)
    
    # فلترة أخيرة للمسافات الزيادة
    final_text = re.sub(r'\n\s*\n', '\n\n', final_text)
    
    return final_text if len(final_text) > 100 else None


def scrape_fintechgate(soup):
    """استخراج النص الصافي من موقع فنتيك جيت"""
    # الحاوية الرئيسية للخبر في فنتيك جيت
    content_div = soup.find('div', id='penci-post-entry-inner') or soup.find('div', class_='inner-post-entry')
    
    if not content_div:
        return None

    # 1. تنظيف الفخاخ (الإعلانات، الروابط المختصرة، الكلمات الدالة، بوكس قد يعجبك)
    junk_classes = [
        'code-block', 'penci-custom-html-inside-content', 
        'penci-ilrltpost-beaf', 'shorten_url', 'post-tags', 
        'penci-single-link-pages'
    ]
    for junk in junk_classes:
        for tag in content_div.find_all('div', class_=junk):
            tag.decompose()

    # تنظيف أي أكواد ستايل أو سكربتات
    for tag in content_div.find_all(['style', 'script']):
        tag.decompose()

    # 2. تنظيف جزء "روابط ذات صلة:" واللينكات اللي تحتها
    for h4 in content_div.find_all(['h4', 'h3', 'p']):
        if 'روابط ذات صلة' in h4.get_text():
            # بندور على القائمة اللي بعد الكلمة دي ونمسحها
            next_node = h4.find_next_sibling()
            if next_node and next_node.name == 'ul':
                next_node.decompose()
            h4.decompose() # نمسح العنوان نفسه

    # 3. تجميع النص الصافي
    text_parts = []
    # هنسحب البراجرافات والعناوين بس
    for tag in content_div.find_all(['p', 'h1', 'h2', 'h3', 'h4']):
        text = tag.get_text(separator=" ").strip()
        if text:
            text_parts.append(text)

    final_text = "\n\n".join(text_parts)
    
    # تنظيف المسافات الفاضية
    final_text = re.sub(r'\n\s*\n', '\n\n', final_text)
    
    return final_text if len(final_text) > 100 else None

def scrape_masrawy(soup):
    """استخراج النص الصافي من موقع مصراوي"""
    # الحاوية الأساسية للخبر في مصراوي
    content_div = soup.find('div', class_='ArticleDetails details')
    
    if not content_div:
        return None

    # 1. مسح بوكس "أخبار ذات صلة" المدمج في وسط الخبر
    for tag in content_div.find_all('section', class_='pattern01'):
        tag.decompose()

    # 2. تجميع النص وتجاهل أي لينكات ترويجية أو "اقرأ أيضا"
    text_parts = []
    for tag in content_div.find_all(['p', 'h1', 'h2', 'h3']):
        text = tag.get_text(separator=" ").strip()
        
        # تجاهل كلمة "اقرأ أيضًا" أو "اقرأ أيضا"
        if "اقرأ أيضًا" in text or "اقرأ أيضا" in text:
            continue
            
        # لو البراجراف عبارة عن لينك بس (زي اللي بييجوا بعد اقرأ أيضا)، نتجاهله
        a_tag = tag.find('a')
        if a_tag and tag.get_text(strip=True) == a_tag.get_text(strip=True):
            continue
            
        if text:
            text_parts.append(text)

    final_text = "\n\n".join(text_parts)
    
    # تنظيف المسافات الفاضية
    final_text = re.sub(r'\n\s*\n', '\n\n', final_text)
    
    return final_text if len(final_text) > 100 else None


def scrape_masrtimes(soup):
    """استخراج النص الصافي من موقع مصر تايمز"""
    # الحاوية الأساسية للخبر
    content_div = soup.find('div', class_='paragraph-list')
    
    if not content_div:
        return None

    # مسح الصور والتعليقات اللي تحتها (اللي بتكرر العنوان) وأي إعلانات
    for tag in content_div.find_all(['figure', 'img', 'figcaption', 'script', 'style']):
        tag.decompose()
        
    # تجميع النص (براجرافات، عناوين فرعية، وعناصر القوائم زي الأسهم)
    text_parts = []
    for tag in content_div.find_all(['p', 'h2', 'h3', 'li']):
        text = tag.get_text(separator=" ").strip()
        if text:
            text_parts.append(text)
            
    final_text = "\n\n".join(text_parts)
    
    # تنظيف المسافات الفاضية
    final_text = re.sub(r'\n\s*\n', '\n\n', final_text)
    
    return final_text if len(final_text) > 100 else None

def scrape_mubasher(soup):
    """استخراج النص الصافي من موقع مباشر (Mubasher)"""
    # الحاوية الأساسية للخبر
    content_div = soup.find('div', itemprop='articleBody') or soup.find('div', class_='article__content-text')
    
    if not content_div:
        return None

    # 1. تنظيف الفخاخ (ويدجت الأسهم، الإعلانات، وأي أكواد برمجية)
    junk_classes = ['mi-article__stocks', 'outstream-ad-container', 'stock-price-block']
    for junk in junk_classes:
        for tag in content_div.find_all('div', class_=junk):
            tag.decompose()

    for tag in content_div.find_all(['script', 'style', 'iframe']):
        tag.decompose()

    # 2. تجميع النص الصافي
    text_parts = []
    # هنسحب البراجرافات والعناوين الفرعية بس
    for tag in content_div.find_all(['p', 'h2', 'h3']):
        text = tag.get_text(separator=" ").strip()
        if text:
            text_parts.append(text)

    final_text = "\n\n".join(text_parts)
    
    # تنظيف المسافات الفاضية
    final_text = re.sub(r'\n\s*\n', '\n\n', final_text)
    
    return final_text if len(final_text) > 100 else None


def scrape_amwalalghad(soup):
    """استخراج النص الصافي من موقع أموال الغد"""
    # الحاوية الأساسية للخبر
    content_div = soup.find('div', id='penci-post-entry-inner') or soup.find('div', class_='inner-post-entry')
    
    if not content_div:
        return None

    # 1. تنظيف الفخاخ (الإعلانات، الأخبار المتعلقة، الروابط المختصرة، أكواد التتبع)
    junk_classes = [
        'penci-ilrltpost-insert', 'shorten_url', 'post-tags', 
        'penci-single-link-pages', 'penci-post-countview-number-check',
        'penci-google-adsense-1'
    ]
    for junk in junk_classes:
        for tag in content_div.find_all(['div', 'i'], class_=junk):
            tag.decompose()

    # تنظيف أي ستايل أو سكريبتات
    for tag in content_div.find_all(['style', 'script']):
        tag.decompose()

    # 2. تجميع النص الصافي
    text_parts = []
    # هنسحب البراجرافات والعناوين الفرعية
    for tag in content_div.find_all(['p', 'h2', 'h3']):
        text = tag.get_text(separator=" ").strip()
        if text:
            text_parts.append(text)

    final_text = "\n\n".join(text_parts)
    
    # تنظيف المسافات الفاضية
    final_text = re.sub(r'\n\s*\n', '\n\n', final_text)
    
    return final_text if len(final_text) > 100 else None


def scrape_arabfinance(soup):
    """استخراج النص الصافي من موقع آراب فاينانس"""
    # هنشتغل على الـ HTML كله وننظف منه الأجزاء اللي مش عايزينها
    content_div = soup

    # 1. تنظيف الفخاخ (الإعلانات، العلامات، والأخبار المشابهة)
    junk_classes = ['details-tags', 'video-section-title', 'news-single-category']
    for junk in junk_classes:
        for tag in content_div.find_all('div', class_=re.compile(junk)):
            tag.decompose()

    # مسح إعلانات جوجل الصريحة
    for tag in content_div.find_all('div', id=re.compile(r'^div-gpt-ad')):
        tag.decompose()

    # تنظيف أي أكواد ستايل أو سكربتات
    for tag in content_div.find_all(['style', 'script']):
        tag.decompose()

    # 2. تجميع النص الصافي
    text_parts = []
    # هنسحب البراجرافات والعناوين الفرعية
    for tag in content_div.find_all(['p', 'h2', 'h3']):
        text = tag.get_text(separator=" ").strip()
        if text:
            text_parts.append(text)

    final_text = "\n\n".join(text_parts)
    
    # تنظيف المسافات الفاضية
    final_text = re.sub(r'\n\s*\n', '\n\n', final_text)
    
    return final_text if len(final_text) > 100 else None


def scrape_petronews(soup):
    """استخراج النص الصافي من موقع بترو نيوز"""
    # الحاوية الرئيسية للخبر في قالب Jannah
    content_div = soup.find('div', class_='entry-content entry')
    
    if not content_div:
        return None

    # 1. تنظيف الفخاخ (أيقونات المشاركة، عداد المشاهدات، الروابط المختصرة، والأخبار المتعلقة)
    junk_classes = [
        'post-views', 'post-shortlink', 'share-buttons',
        'about-author', 'post-components', 'related-posts'
    ]
    for junk in junk_classes:
        for tag in content_div.find_all('div', class_=re.compile(junk)):
            tag.decompose()

    # مسح أي صور (figure) أو سكربتات
    for tag in content_div.find_all(['figure', 'img', 'script', 'style']):
        tag.decompose()

    # 2. تجميع النص الصافي
    text_parts = []
    # هنسحب البراجرافات والعناوين الفرعية
    for tag in content_div.find_all(['p', 'h2', 'h3']):
        text = tag.get_text(separator=" ").strip()
        # تجاهل البراجرافات اللي بتبدأ بـ "مصدر الخبر:"
        if text and not text.startswith("مصدر الخبر:"):
            text_parts.append(text)

    final_text = "\n\n".join(text_parts)
    
    # تنظيف المسافات الفاضية
    final_text = re.sub(r'\n\s*\n', '\n\n', final_text)
    
    return final_text if len(final_text) > 100 else None


def scrape_msn(soup):
    """استخراج النص الصافي من موقع MSN"""
    # MSN بيحط المحتوى جوه كلاسات زي article-content أو tags مخصصة زي cp-article
    content_div = soup.find('div', class_='article-content') or soup.find('cp-article') or soup
    
    if not content_div:
        return None

    # تنظيف الإعلانات والوصف المتكرر للصور
    for tag in content_div.find_all(['display-ads', 'figcaption', 'script', 'style']):
        tag.decompose()
        
    text_parts = []
    seen = set() # 👈 بنعمل Set عشان نخزن فيها الجمل ونمنع تكرارها
    
    for tag in content_div.find_all(['p', 'h2', 'h3']):
        text = tag.get_text(separator=" ").strip()
        # لو النص موجود ومش متكرر قبل كده في الـ Set، ضيفه
        if text and text not in seen:
            seen.add(text)
            text_parts.append(text)
            
    final_text = "\n\n".join(text_parts)
    return final_text if len(final_text) > 100 else None

def scrape_youm7(soup):
    """استخراج النص الصافي من موقع اليوم السابع (يدعم نسخة الويب والـ AMP)"""
    # ضفنا article-body عشان ندعم روابط الـ AMP
    content_div = soup.find('div', id='articleBody') or soup.find('div', class_='articleCont') or soup.find('div', class_='article-body')
    
    if not content_div:
        return None

    # تنظيف الفخاخ (إعلانات، أيقونات، كاتب، كلمات دالة)
    junk_classes = ['tags', 'writeBy', 'wirte-by', 'img-text', 'breadcumb', 'social-share-bar']
    for junk in junk_classes:
        for tag in content_div.find_all('div', class_=re.compile(junk, re.IGNORECASE)):
            tag.decompose()

    for tag in content_div.find_all(['script', 'style', 'img', 'figure', 'amp-img', 'center']):
        tag.decompose()

    # مسح الروابط الترويجية 
    for a_tag in content_div.find_all('a'):
        link_text = a_tag.get_text(strip=True)
        if "Google News" in link_text or "واتساب" in link_text:
            a_tag.decompose()

    for tag in content_div.find_all('div', id=re.compile(r'taboola|div-gpt-ad')):
        tag.decompose()

    # مسح اسم الكاتب والتاريخ
    for tag in content_div.find_all(['span', 'div'], class_=re.compile(r'writeBy|wirte-by|news-date')):
        tag.decompose()

    # تجميع النص الصافي
    text_parts = []
    for tag in content_div.find_all(['p', 'h2', 'h3']):
        text = tag.get_text(separator=" ").strip()
        if text:
            text_parts.append(text)

    final_text = "\n\n".join(text_parts)
    final_text = re.sub(r'\n\s*\n', '\n\n', final_text)
    
    return final_text if len(final_text) > 100 else None

def scrape_alboslanews(soup):
    """استخراج النص الصافي من موقع البوصلة نيوز"""
    # الحاوية المخصصة للنص فقط في موقع البوصلة
    content_div = soup.find('div', class_='news-content')
    
    if not content_div:
        return None

    # تنظيف أي صور أو سكريبتات مستخبية جوه النص
    for tag in content_div.find_all(['script', 'style', 'img']):
        tag.decompose()

    # هنا مش محتاجين نفلتر كتير لأن الحاوية نظيفة بطبيعتها
    final_text = content_div.get_text(separator="\n\n").strip()
    
    # تنظيف المسافات والسطور الفاضية الزيادة
    final_text = re.sub(r'\n\s*\n', '\n\n', final_text)
    
    return final_text if len(final_text) > 100 else None



def scrape_almalnews(soup):
    """استخراج النص الصافي من جريدة المال"""
    # الحاوية الرئيسية للخبر في جريدة المال
    content_div = soup.find('div', class_='article-content')
    
    if not content_div:
        return None

    # تنظيف الإعلانات الجانبية المخفية جوه النص وأي سكربتات أو صور
    junk_classes = ['news-side-column']
    for junk in junk_classes:
        for tag in content_div.find_all('div', class_=junk):
            tag.decompose()

    for tag in content_div.find_all(['script', 'style', 'img', 'figure', 'iframe']):
        tag.decompose()

    # تجميع النص الصافي
    text_parts = []
    # هنسحب البراجرافات والعناوين الفرعية
    for tag in content_div.find_all(['p', 'h2', 'h3']):
        text = tag.get_text(separator=" ").strip()
        if text:
            text_parts.append(text)

    final_text = "\n\n".join(text_parts)
    
    # تنظيف المسافات الفاضية
    final_text = re.sub(r'\n\s*\n', '\n\n', final_text)
    
    return final_text if len(final_text) > 100 else None



# قاموس بيربط الدومين بالدالة بتاعته
SCRAPERS = {
    "vetogate.com": scrape_vetogate,
    "almasryalyoum.com": scrape_almasryalyoum, # 👈 ضفنا المصري اليوم هنا
    # هنضيف باقي المواقع هنا تباعاً
    "fintechgate.net": scrape_fintechgate, # 👈 ضفنا فنتيك جيت هنا
    "masrawy.com": scrape_masrawy, # 👈 ضفنا مصراوي هنا
    "masrtimes.com": scrape_masrtimes, # 👈 ضفنا مصر تايمز هنا عشان يمنع التكرار
    "mubasher.info": scrape_mubasher, # 👈 ضفنا موقع مباشر هنا
    "amwalalghad.com": scrape_amwalalghad, # 👈 ضفنا أموال الغد هنا
    "arabfinance.com": scrape_arabfinance, # 👈 ضفنا آراب فاينانس هنا
    "petro-news.com": scrape_petronews, # 👈 ضفنا بترو نيوز هنا
    "youm7.com": scrape_youm7, # 👈 ضفنا اليوم السابع هنا
    "msn.com": scrape_msn, # 👈 ضفنا MSN هنا
    "alboslanews.com": scrape_alboslanews, # 👈 ضفنا البوصلة نيوز هنا
    "almalnews.com": scrape_almalnews, # 👈 ضفنا جريدة المال هنا
}

def extract_smart_content(url, html_content):
    """
    مُوجّه ذكي: بيفحص الرابط وبيشغل الدالة المخصصة لو موجودة،
    أو بيرجع يشتغل بالطريقة العامة المحدثة المانعة للتكرار.
    """

    if "arabfinance.com" in url.lower() and "companyprofile" in url.lower():
        print(f"      🚫 Skipped: Arab Finance Company Profile (Not a news article)")
        return None
    
    soup = BeautifulSoup(html_content, "html.parser")
    
    # 1. البحث عن طريقة مخصصة للموقع
    for domain, scraper_func in SCRAPERS.items():
        if domain in url:
            extracted_text = scraper_func(soup)
            if extracted_text and len(extracted_text) > 100:
                print(f"      🎯 Custom Scraper Used for: {domain}")
                return extracted_text
                
    # 2. الطريقة القديمة (Fallback) المحدثة (Anti-Duplication)
    print(f"      🔄 Using General Fallback Scraper (Anti-Duplication)...")
    
    # 🧹 أ. إزالة العناصر الهيكلية اللي بتجيب تكرار (عناوين الـ Meta، وصف الصور، الهيدر، الفوتر)
    for tag in soup.find_all(['header', 'footer', 'nav', 'aside', 'figcaption', 'title', 'meta', 'script', 'style']):
        tag.decompose()
        
    # 🧹 ب. إزالة الكلاسات المزعجة (إعلانات، أخبار متعلقة، مشاركة)
    junk_classes = re.compile(r'(related|widget|more|ad|social|share|tags|comments)', re.IGNORECASE)
    for tag in soup.find_all(class_=junk_classes):
        tag.decompose()
        
    # 🧠 ج. سحب النص بذكاء لمنع التكرار نهائياً
    text_parts = []
    seen_paragraphs = set() # ذاكرة السكريبت عشان ميحطش حاجة مرتين
    
    # هنسحب البراجرافات والعناوين بس (مش هنسحب الصفحة كلها عمياني)
    for tag in soup.find_all(['p', 'h1', 'h2', 'h3']):
        text = tag.get_text(separator=" ").strip()
        
        # لو النص مش فاضي، ومقرأناهوش قبل كده، ضيفه
        if text not in seen_paragraphs or len(text) < 35:
            seen_paragraphs.add(text)
            text_parts.append(text)
            
    final_text = "\n\n".join(text_parts)
    return final_text





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

                if is_blacklisted(entry.link, title):
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
                    try:
                        # هنبعت اللينك وكود الصفحة للروتر الذكي بتاعنا
                        content = extract_smart_content(final_url, driver.page_source)
                    except Exception as e: 
                        print(f"      ⚠️ Smart Extraction Error: {e}")

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

                if is_blacklisted(entry.link, title):
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
                        # استدعاء الروتر الذكي حتى للأخبار الإنجليزية
                        content = extract_smart_content(final_url, driver.page_source)
                    except Exception as e: 
                        print(f"      ⚠️ Smart Extraction Error (Crypto): {e}")

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

        # crypto = [s for s in all_stocks if 'Crypto' in s.get('sector', '')]
        stocks = [s for s in all_stocks if 'Crypto' not in s.get('sector', '')]

        # if crypto: process_crypto(crypto)
        if stocks: process_stocks(stocks)

    except Exception as e: 
        print(f"\n🚨 CRITICAL ERROR: {e}")
    
    end_time = datetime.now()
    print(f"\n✅ Job Finished: {end_time}")
    print(f"⏱️ Total Duration: {end_time - start_time}")