# import time
# import random
# import feedparser
# import trafilatura
# import re
# import pandas as pd
# import os
# from bs4 import BeautifulSoup
# from datetime import datetime, timezone, timedelta
# from dateutil import parser
# from urllib.parse import quote
# from selenium import webdriver
# from selenium.webdriver.chrome.options import Options
# from selenium.webdriver.chrome.service import Service
# from webdriver_manager.chrome import ChromeDriverManager

# # ==============================================================================
# # 1. Config & Local Data
# # ==============================================================================
# CSV_FILE = "egx360_historical_news.csv"

# # نفس قائمة الشركات الخاصة بك
# EGX_STOCKS = [
#     {'id': 1, 'symbol': 'TMGH', 'name': 'مجموعة طلعت مستطفى'},
#     {'id': 2, 'symbol': 'COMI', 'name': 'البنك التجاري الدولي'},
#     # ... (يمكنك إضافة باقي القائمة هنا)
# ]

# EXISTING_URLS = set()

# # ==============================================================================
# # 2. Helpers
# # ==============================================================================

# def init_csv():
#     global EXISTING_URLS
#     if not os.path.exists(CSV_FILE):
#         df = pd.DataFrame(columns=['stock_id', 'title', 'description', 'content', 'url', 'source', 'published_at'])
#         df.to_csv(CSV_FILE, index=False, encoding='utf-16')
#     else:
#         try:
#             df_existing = pd.read_csv(CSV_FILE, encoding='utf-16')
#             EXISTING_URLS = set(df_existing['url'].dropna().tolist())
#             print(f"📊 Loaded {len(EXISTING_URLS)} existing URLs.")
#         except: pass

# def clean_and_validate_content(text, description, title):
#     # (نفس دالة التنظيف القوية التي كتبتها أنت في الكود السابق)
#     if not text or len(text) < 20: return description if description else ""
#     text = re.sub(r'<[^>]+>', '', text)
#     return text.strip()

# def build_historical_query(company_name, start_date, end_date):
#     """بناء استعلام جوجل مع تحديد الفترة الزمنية بدقة"""
#     query = f'"{company_name}" (سهم OR بورصة OR أرباح) after:{start_date} before:{end_date}'
#     return quote(query)

# # ==============================================================================
# # 3. Engines
# # ==============================================================================

# def setup_stock_driver():
#     chrome_options = Options()
#     chrome_options.add_argument("--headless=new")
#     chrome_options.add_argument("--no-sandbox")
#     chrome_options.add_argument("--disable-dev-shm-usage")
#     return webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=chrome_options)

# def save_to_csv(stock_id, title, desc, content, url, pub_date):
#     global EXISTING_URLS
#     if url in EXISTING_URLS: return
    
#     new_row = {
#         "stock_id": stock_id,
#         "title": title,
#         "description": desc[:500] if desc else "",
#         "content": content,
#         "url": url,
#         "source": "Google News Historical",
#         "published_at": pub_date
#     }
#     pd.DataFrame([new_row]).to_csv(CSV_FILE, mode='a', header=False, index=False, encoding='utf-16')
#     EXISTING_URLS.add(url)

# def process_historical_scraping(years_list):
#     init_csv()
#     driver = setup_stock_driver()
    
#     try:
#         for year in years_list:
#             # تقسيم السنة لشهور لزيادة دقة النتائج وتفادي قيود جوجل
#             for month in range(1, 13):
#                 start_date = f"{year}-{month:02d}-01"
#                 # تحديد نهاية الشهر (تبسيطاً سنعتبره 28 يوم)
#                 end_date = f"{year}-{month:02d}-28"
                
#                 print(f"\n📅 Period: {start_date} to {end_date}")
                
#                 for stock in EGX_STOCKS:
#                     query = build_historical_query(stock['name'], start_date, end_date)
#                     rss_url = f"https://news.google.com/rss/search?q={query}&hl=ar&gl=EG&ceid=EG:ar"
                    
#                     feed = feedparser.parse(rss_url)
#                     print(f"   🔎 {stock['symbol']}: Found {len(feed.entries)} entries")
                    
#                     for entry in feed.entries[:10]: # نكتفي بأهم 10 أخبار لكل شهر لكل شركة لتجنب الحظر
#                         if entry.link in EXISTING_URLS: continue
                        
#                         try:
#                             # جلب المحتوى باستخدام trafilatura
#                             downloaded = trafilatura.fetch_url(entry.link)
#                             content = trafilatura.extract(downloaded) if downloaded else ""
                            
#                             if content and len(content) > 200:
#                                 save_to_csv(stock['id'], entry.title, entry.description, content, entry.link, entry.published)
#                                 print(f"      ✅ Saved: {entry.title[:50]}...")
#                         except:
#                             continue
                    
#                     # توقف عشوائي بين كل شركة وأخرى (هام جداً)
#                     time.sleep(random.uniform(5, 10))
                
#                 # توقف أطول بين كل شهر وأخر
#                 print("⏳ Sleeping between months to avoid detection...")
#                 time.sleep(random.uniform(20, 40))
                
#     finally:
#         driver.quit()

# if __name__ == "__main__":
#     # حدد السنوات التي تريد جمع بياناتها لمشروع EGX360
#     target_years = [2022, 2023, 2024, 2025] 
#     process_historical_scraping(target_years)

import yfinance as yf
import pandas as pd
import numpy as np
import os

def fetch_macro_data_no_api(interest_csv_path="data/egy_interest.csv", start_date="2000-01-01"):
    print("🚀 Starting EGX360 Macro Engine (Fixed Levels)...")
    
    # --- 1. جلب سعر صرف الدولار (USD/EGP) ---
    print("💵 Fetching USD/EGP from Yahoo Finance...")
    try:
        # أضفنا auto_adjust و multi_index=False لمحاولة تبسيط الجدول
        usd_data = yf.download('EGP=X', start=start_date)
        
        # حل مشكلة الـ MultiIndex: بنخلي الأعمدة مستوى واحد بس
        if isinstance(usd_data.columns, pd.MultiIndex):
            usd_data.columns = usd_data.columns.get_level_values(0)
            
        usd_df = usd_data[['Close']].rename(columns={'Close': 'usd_rate'})
        usd_df.index = pd.to_datetime(usd_df.index)
    except Exception as e:
        print(f"❌ Error fetching USD data: {e}")
        return None

    # --- 2. قراءة بيانات الفائدة ---
    print(f"🏦 Loading Interest Rates...")
    if os.path.exists(interest_csv_path):
        interest_df = pd.read_csv(interest_csv_path)
        interest_df['DATE'] = pd.to_datetime(interest_df['DATE'])
        interest_df.set_index('DATE', inplace=True)
        # تأكد من اسم العمود في ملف الـ CSV اللي حملته
        if 'EGYINTANM' in interest_df.columns:
            interest_df.rename(columns={'EGYINTANM': 'interest_rate'}, inplace=True)
    else:
        print("⚠️ Warning: Interest CSV not found! Using last known Egypt rate (27.25%).")
        # إنشاء جدول فائدة افتراضي بنفس طول جدول الدولار لتجنب الـ Crash
        interest_df = pd.DataFrame(index=usd_df.index)
        interest_df['interest_rate'] = 27.25 # سعر الفائدة الحالي في مصر تقريباً

    # --- 3. الدمج (Merging) ---
    # بنحول الـ Index لاسم موحد 'timestamp' عشان نضمن الدمج صح
    usd_df.index.name = 'timestamp'
    interest_df.index.name = 'timestamp'

    # [Image of Pandas MultiIndex vs SingleIndex dataframe structure]
    
    # الدمج الآن هيتم بسلاسة لأن الاتنين Single Level
    macro_df = usd_df.join(interest_df, how='outer').sort_index()

    # ملء الفراغات (Forward Fill)
    macro_df['usd_rate'] = macro_df['usd_rate'].ffill()
    macro_df['interest_rate'] = macro_df['interest_rate'].ffill()

    # --- 4. Feature Engineering ---
    macro_df['usd_pct_change'] = macro_df['usd_rate'].pct_change()
    macro_df['interest_diff'] = macro_df['interest_rate'].diff()

    # تنظيف
    macro_df.dropna(subset=['usd_rate'], inplace=True)
    
    output_path = "data/egypt_macro_historical.csv"
    if not os.path.exists("data"): os.makedirs("data")
    macro_df.to_csv(output_path)
    
    print(f"✅ Success! Macro data saved. Total rows: {len(macro_df)}")
    return macro_df

if __name__ == "__main__":
    macro_data = fetch_macro_data_no_api()
    if macro_data is not None:
        print(macro_data.tail())