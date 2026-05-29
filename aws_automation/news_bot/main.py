import time
import feedparser
import trafilatura
import random
import requests
from datetime import datetime, timezone, timedelta
from dateutil import parser
from urllib.parse import quote
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from difflib import SequenceMatcher
import re

from database import DatabaseManager
from ai_engine import AIEngine
from scrapers import NewsScraper

class EGX360Bot:
    def __init__(self):
        self.db = DatabaseManager()
        self.ai = AIEngine()
        self.scraper = NewsScraper()

    def setup_stock_driver(self):
        print("🌐 Starting Headless Chrome Driver...")
        chrome_options = Options()
        chrome_options.add_argument("--headless=new")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--blink-settings=imagesEnabled=false")
        chrome_options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
        return webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=chrome_options)

    def resolve_url_with_selenium(self, google_url, driver):
        try:
            driver.get(google_url)
            time.sleep(2)
            if "consent.google.com" in driver.current_url:
                try:
                    btns = driver.find_elements('tag name', 'button')
                    for btn in btns:
                        if btn.text in ['Accept all', 'I agree', 'موافق']:
                            btn.click(); time.sleep(1); break
                except: pass
            return driver.current_url
        except: return google_url

    def build_smart_query(self, company_name, symbol, lang='ar'):
        clean_name = company_name.replace("المصرية", "").replace("القابضة", "").strip()
        
        # Negative keywords to exclude sports/football
        neg_ar = "-كرة -قدم -رياضة -مباراة -لاعب -نادي -دوري -كأس -بطولة"
        neg_en = "-football -soccer -sports -match -player -club -league -cup -tournament"
        
        if lang == 'ar':
            # Removed exact quotes around clean_name for Arabic. 
            # Arabic has many spelling variations (أ/ا, ة/ه, spaces), so quotes block 80% of valid news.
            query = f'{clean_name} (سهم OR بورصة OR أرباح OR تداول OR اقتصاد OR جنيه) {neg_ar} when:5d'
        else:
            query = f'("{clean_name}" OR "{symbol}") (stock OR market OR finance OR earnings OR trading) {neg_en} when:5d'
            
        return quote(query)

    def is_fresh_news(self, entry, max_days=3):
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

    def process_and_save_news(self, stock_id, symbol, title, description, content, url, source, pub_date, is_api, send_alert, use_finbert=False):
        if self.db.is_url_duplicate(stock_id, url): return False 
        if self.db.is_title_duplicate(stock_id, title): return False

        base_content = self.scraper.clean_and_validate_content(content, description, title)

        if not is_api:
            if not base_content or len(base_content) < 150:
                print(f"      ⏩ Skipped: Content too short for Scraper ({len(base_content) if base_content else 0} chars)")
                return False
        else:
            if not base_content or len(base_content) < 20:
                base_content = title

        if use_finbert:
            sentiment = self.ai.process_english(title, base_content)
            is_valid = True
            final_content = f"{title}. {base_content}"
        elif self.ai.is_arabic(title + base_content):
            is_valid, sentiment, final_content = self.ai.process_arabic(title, base_content)
        else:
            is_valid, sentiment, final_content = self.ai.process_english_llm(title, base_content)

        if not is_valid: 
            print(f"      🚫 AI: News marked as invalid or irrelevant (e.g. sports/spam)")
            return False
        formatted_date = pub_date.isoformat() if hasattr(pub_date, 'isoformat') else str(pub_date)
        data = {
            "stock_id": stock_id, "title": title, "description": description[:500] if description else "", 
            "content": final_content, "url": url, "source": source,
            "sentiment_label": sentiment, "published_at": formatted_date
        }
        
        
        is_inserted = self.db.insert_news(data)   

        if is_inserted:
            if send_alert: self.db.send_notification(symbol, title, url)
            print(f"      ✅ DB: Saved [{sentiment}] news for [{symbol}] from {source}")
            return True 
            
        return False
        
       

    def process_stocks(self, stocks_list):
        driver = self.setup_stock_driver()
        try:
            print(f"\n{'='*50}\n🇪🇬 STOCK ENGINE: Processing {len(stocks_list)} items\n{'='*50}")
            for stock in stocks_list:
                symbol, name_ar, stock_id = stock['symbol'], stock['company_name_ar'], stock['id']
                notified_this_run = False 
                
                # Search only Arabic sources for EGX Stocks
                search_configs = [
                    {'lang': 'ar', 'hl': 'ar', 'gl': 'EG', 'ceid': 'EG:ar', 'label': 'Google News (AR)'}
                ]

                for config in search_configs:
                    name_to_use = name_ar if config['lang'] == 'ar' else stock.get('company_name_en', symbol)
                    encoded_query = self.build_smart_query(name_to_use, symbol, lang=config['lang'])
                    rss_url = f"https://news.google.com/rss/search?q={encoded_query}&hl={config['hl']}&gl={config['gl']}&ceid={config['ceid']}"

                    print(f"\n🔎 [{symbol}] Scanning RSS ({config['label']})...")
                    feed = feedparser.parse(rss_url)
                    
                    entries = feed.entries[:5]
                    print(f"   Found {len(feed.entries)} entries, taking top {len(entries)}")

                    for entry in entries:
                        title = entry.title
                        print(f"\n   📰 Title: {title[:60]}...")
                        
                        fresh, pub_date = self.is_fresh_news(entry, max_days=5)
                        if not fresh:
                            print(f"      ⏩ Skipped: Too old ({pub_date})")
                            continue

                        if self.scraper.is_blacklisted(entry.link, title):
                            print(f"      ⏩ Skipped: Blacklisted domain")
                            continue

                        if self.db.is_title_duplicate(stock_id, title):
                            print(f"      🚫 Skipped: Duplicate title detected in DB")
                            continue

                        print(f"      🚀 Resolving URL with Selenium...")
                        final_url = self.resolve_url_with_selenium(entry.link, driver)
                        print(f"      🔗 Final URL: {final_url[:50]}...")

                        if self.scraper.is_blacklisted(final_url, title):
                            print(f"      ⏩ Skipped: Blacklisted domain (After Resolving)")
                            continue

                        
                        content = None
                        rss_desc = self.scraper.clean_html(entry.description) if 'description' in entry else ""

                        try:
                            print(f"      📥 Attempting Trafilatura...")
                            downloaded = trafilatura.fetch_url(final_url)
                            if downloaded:
                                content = trafilatura.extract(downloaded, include_formatting=True, include_links=False)
                        except Exception as e:
                            print(f"      ⚠️ Trafilatura Error: {e}")

                        if not content or len(content) < 400:
                            try:
                                content = self.scraper.extract_smart_content(final_url, driver.page_source)
                            except Exception as e: 
                                print(f"      ⚠️ Smart Extraction Error: {e}")

                        is_saved = self.process_and_save_news(
                            stock_id, symbol, title, rss_desc, content, final_url, config['label'], pub_date, 
                            is_api=False, send_alert=not notified_this_run 
                        )
                        
                        if is_saved: notified_this_run = True

                time.sleep(random.uniform(2, 4))
        finally:
            print("\n🛑 Closing Chrome Driver...")
            driver.quit()

    def process_crypto(self, crypto_list):
        print(f"\n{'='*50}\n💎 CRYPTO ENGINE: Check Top 5 Latest News Per Coin\n{'='*50}")
        driver = self.setup_stock_driver()
        session_processed_titles = [] 
        
        try:
            for coin in crypto_list:
                symbol = coin['symbol'].upper()
                name_en = coin['company_name_en']
                notified_this_run = False 
                
                query = f'"{name_en}" OR "{symbol}" AND (crypto OR market OR price) when:3d'
                encoded_query = quote(query)
                rss_url = f"https://news.google.com/rss/search?q={encoded_query}&hl=en-US&gl=US&ceid=US:en"

                print(f"\n🔎 [{symbol}] Scanning RSS...")
                feed = feedparser.parse(rss_url)
                
                sorted_entries = sorted(feed.entries, key=lambda x: x.get('published_parsed', 0), reverse=True)
                entries_to_check = sorted_entries[:5]
                print(f"   Found {len(feed.entries)} entries, checking top {len(entries_to_check)} only.")
                
                for index, entry in enumerate(entries_to_check, start=1):
                    title = entry.title
                    link = entry.link
                    
                    print(f"   📰 Checking ({index}/5): {title[:50]}...")
                    
                    if self.scraper.is_blacklisted(link, title):
                        print("      ⏩ Skipped: Blacklisted domain")
                        continue 

                    is_session_duplicate = False
                    clean_new_title = re.sub(r'[^\w\s]', '', title).lower()
                    for past_title in session_processed_titles:
                        if SequenceMatcher(None, clean_new_title, past_title).ratio() > 0.80:
                            is_session_duplicate = True
                            break
                            
                    if is_session_duplicate:
                        print("      🚫 Skipped: Found similar news in this session")
                        continue
                    
                    fresh, pub_date = self.is_fresh_news(entry, max_days=3)
                    if not fresh:
                        print("      ⏩ Skipped: Too old")
                        continue

                    if self.db.is_title_duplicate(coin['id'], title):
                        continue

                    print("      🚀 Resolving URL...")
                    final_url = self.resolve_url_with_selenium(link, driver)
                    
                    if self.scraper.is_blacklisted(final_url, title):
                        print("      ⏩ Skipped: Blacklisted domain (After Resolving)")
                        continue
                
                    rss_desc = self.scraper.clean_html(entry.description) if 'description' in entry else ""
                    content_for_ai = f"{title}. {rss_desc}"

                    print("      ⚡ Fast processing (Local FinBERT Sentiment)...")

                    is_saved = self.process_and_save_news(
                        stock_id=coin['id'], symbol=symbol, title=title, description=rss_desc[:500], 
                        content=content_for_ai, url=final_url, source="Google Crypto News", 
                        pub_date=pub_date, is_api=True, send_alert=not notified_this_run,
                        use_finbert=True
                    )
                    
                    if is_saved:
                        session_processed_titles.append(clean_new_title)
                        notified_this_run = True 
                
                time.sleep(random.uniform(1, 2))
                
        except Exception as e:
            print(f"      🚨 Crypto Engine Error: {e}")
        finally:
            print("\n🛑 Closing Chrome Driver (Crypto)...")
            driver.quit()

    def process_finnhub(self, finnhub_list):
        print(f"\n{'='*50}\n🇺🇸 US STOCKS/ETFs ENGINE: Direct API & Offline BERT\n{'='*50}")
        import config
        
        try:
            today = datetime.now().strftime("%Y-%m-%d")
            yesterday = (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")
            
            for item in finnhub_list:
                symbol = item['symbol']
                notified_this_run = False 
                
                print(f"\n🔎 [{symbol}] Fetching directly from Finnhub API...")
                url = f"https://finnhub.io/api/v1/company-news?symbol={symbol}&from={yesterday}&to={today}&token={config.FINNHUB_API_KEY}"
                
                response = requests.get(url, timeout=10)
                if response.status_code != 200:
                    print(f"      ⚠️ Finnhub HTTP {response.status_code}")
                    continue
                    
                news_data = response.json()
                if not news_data:
                    print("      ⚠️ No recent news found via API.")
                    continue
                    
                print(f"   Found {len(news_data)} API articles, checking top 3.")
                
                for index, article in enumerate(news_data[:3], start=1):
                    headline = article.get("headline", "")
                    summary = article.get("summary", "")
                    link = article.get("url", "")
                    unix_time = article.get("datetime")
                    
                    if not headline or not link: continue
                    
                    print(f"   📰 Checking ({index}/3): {headline[:50]}...")
                    
                    pub_date = datetime.fromtimestamp(unix_time, timezone.utc)
                    if (datetime.now(timezone.utc) - pub_date).days > 3:
                        print("      ⏩ Skipped: Too old")
                        continue
                    
                    if self.db.is_url_duplicate(item['id'], link) or self.db.is_title_duplicate(item['id'], headline):
                        print("      🚫 Skipped: Duplicate detected in DB")
                        continue

                    content_for_ai = summary if summary else headline
                    
                    print("      ⚡ Fast processing (Local FinBERT Sentiment)...")

                    is_saved = self.process_and_save_news(
                        stock_id=item['id'], symbol=symbol, title=headline, description=summary[:500], 
                        content=content_for_ai, url=link, source=article.get("source", "Finnhub API"), 
                        pub_date=pub_date, is_api=True, send_alert=not notified_this_run,
                        use_finbert=True
                    )
                    
                    if is_saved:
                        notified_this_run = True 
                
                time.sleep(1)
                
        except Exception as e:
            print(f"      🚨 Finnhub API Engine Error: {e}")

    def run(self):
        start_time = datetime.now()
        print(f"🚀 Job Started: {start_time}")
        try:
            print("📥 Loading stocks from Supabase...")
            all_stocks = self.db.get_all_stocks()
            print(f"✅ Loaded {len(all_stocks)} items from DB")

            crypto = [s for s in all_stocks if 'Crypto' in s.get('sector', '')]
            finnhub = [s for s in all_stocks if s.get('candle_table_name') == 'API_FINNHUB' or 'US ' in s.get('sector', '')]
            stocks = [s for s in all_stocks if 'Crypto' not in s.get('sector', '') and s.get('candle_table_name') != 'API_FINNHUB' and 'US ' not in s.get('sector', '')]

            if crypto: self.process_crypto(crypto)
            if finnhub: self.process_finnhub(finnhub)
            if stocks: self.process_stocks(stocks)

        except Exception as e: 
            print(f"\n🚨 CRITICAL ERROR: {e}")
        
        end_time = datetime.now()
        print(f"\n✅ Job Finished: {end_time}")
        print(f"⏱️ Total Duration: {end_time - start_time}")

if __name__ == "__main__":
    bot = EGX360Bot()
    bot.run()