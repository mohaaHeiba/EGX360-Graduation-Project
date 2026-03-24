import cloudscraper
import firebase_admin
from firebase_admin import credentials, messaging
from bs4 import BeautifulSoup
from datetime import datetime
import pytz
import re
from supabase import create_client, Client

# --- 1. Configurations ---
SUPABASE_URL = "https://zlcddmhcxtxvgzxcfvxx.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpsY2RkbWhjeHR4dmd6eGNmdnh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyOTM0MTcsImV4cCI6MjA4MDg2OTQxN30.F5SxofdTfi9oBO3db1nygSXIiYEqoXgZ0OTW_Fu5Kew"

# تأكد من صحة المسار واسم الفولدر (materials)
SERVICE_ACCOUNT_PATH = "/home/heiba/EGX360_Graduation_Project/aws/materials_local_pricing/service_account.json"
TABLE_NAME = "materials_prices"
NOTIFICATION_THRESHOLD = 5.0

# --- 2. Initialization ---
if not firebase_admin._apps:
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    firebase_admin.initialize_app(cred)

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
scraper = cloudscraper.create_scraper(browser={'browser': 'chrome', 'platform': 'linux', 'desktop': True})
cairo_tz = pytz.timezone('Africa/Cairo')

# --- 3. Functions ---

def clean_price(text):
    """الزتونة: بتشيل أي حروف عربي (جنيه، مصري، إلخ) وتسيب الأرقام بس"""
    try:
        # بنشيل الفواصل وأي حرف مش رقم أو نقطة
        cleaned = re.sub(r'[^\d.]', '', text.replace(',', ''))
        return float(cleaned) if cleaned else None
    except:
        return None

def get_latest_price_from_db():
    try:
        res = supabase.table(TABLE_NAME).select("p21_buy").order("timestamp", desc=True).limit(1).execute()
        if res.data:
            return float(res.data[0]['p21_buy'])
    except Exception as e:
        print(f"   ❌ DB Fetch Error: {e}")
    return None

def get_gold_prices_web():
    url = "https://gold-price-live.com/gold"
    try:
        response = scraper.get(url, timeout=20)
        soup = BeautifulSoup(response.text, 'html.parser')
        
        mapping = {
            "عيار 24": "p24", "عيار 21": "p21", "عيار 18": "p18",
            "أونصة": "ounce", "جنيه الذهب": "gold_pound",
            "50 جرام": "bar_50g", "100 جرام": "bar_100g", "250 جرام": "bar_250g"
        }
        
        prices = {}
        rows = soup.find_all("tr")
        
        print("\n🔍 --- جاري سحب الأسعار وتنظيف الداتا من 'مصري' و 'جنيه' ---")
        for row in rows:
            cells = row.find_all(["td", "th"])
            if len(cells) >= 2:
                label = cells[0].get_text(strip=True)
                for key, prefix in mapping.items():
                    if key in label:
                        # تنظيف السعر الأول
                        val_1 = clean_price(cells[1].get_text(strip=True))
                        
                        # لو فيه خانة تالتة ومفيهاش دولار، يبقى ده سعر شراء
                        if len(cells) >= 3 and "$" not in cells[2].get_text():
                            val_2 = clean_price(cells[2].get_text(strip=True))
                            if val_1 and val_2:
                                prices[f"{prefix}_sell"] = val_1
                                prices[f"{prefix}_buy"] = val_2
                        elif val_1:
                            # للسبايك اللي ليها سعر واحد مصري في الجدول
                            prices[f"{prefix}_sell"] = val_1
                            prices[f"{prefix}_buy"] = val_1
                        
                        if f"{prefix}_sell" in prices:
                            print(f"✅ {key.ljust(15)} | Sell: {prices[f'{prefix}_sell']} | Buy: {prices[f'{prefix}_buy']}")
        return prices
    except Exception as e:
        print(f"   ❌ Web Scraping Error: {e}")
        return None

def save_to_db_logic(prices_dict):
    try:
        now_cairo = datetime.now(cairo_tz)
        today_date = now_cairo.strftime("%Y-%m-%d")
        
        # البحث عن ريكورد النهاردة
        res = supabase.table(TABLE_NAME).select("id").gte("timestamp", f"{today_date}T00:00:00").execute()
        
        data = {
            "timestamp": now_cairo.isoformat(),
            **prices_dict
        }

        if res.data:
            record_id = res.data[0]['id']
            supabase.table(TABLE_NAME).update(data).eq("id", record_id).execute()
            print(f"🔄 [UPDATE]: تم تحديث سجل اليوم (ID: {record_id})")
        else:
            supabase.table(TABLE_NAME).insert(data).execute()
            print(f"🆕 [INSERT]: تم إضافة سجل جديد ليوم {today_date}")
            
    except Exception as e:
        print(f"   ❌ DB Logic Error: {e}")

def send_bulk_notification(current_price, diff):
    try:
        res = supabase.table("profiles").select("fcm_token").not_.is_("fcm_token", "null").execute()
        tokens = [item['fcm_token'] for item in res.data if item['fcm_token']]
        if not tokens: return

        change_icon = "🔼" if diff > 0 else "🔽"
        display_title = "تحديث سعر الذهب 🟡"
        display_body = f"عيار 21 الآن {current_price:,.0f} ج.م ({change_icon} {diff:+.0f} ج.م)"

        message = messaging.MulticastMessage(
            notification=messaging.Notification(title=display_title, body=display_body),
            android=messaging.AndroidConfig(priority='high', notification=messaging.AndroidNotification(channel_id='gold_price_alerts', color='#DAA520')),
            tokens=tokens
        )
        messaging.send_each_for_multicast(message)
        print(f"   🔔 FCM: تم إرسال التنبيهات.")
    except Exception as e:
        print(f"   ❌ FCM Error: {e}")

# --- 4. Main Logic ---

def main():
    print(f"\n{'='*55}\n💰 EGX360 TRACKER: {datetime.now(cairo_tz).strftime('%Y-%m-%d %H:%M:%S')}\n{'='*55}")

    web_prices = get_gold_prices_web()

    if web_prices and "p21_buy" in web_prices:
        current_21k = web_prices["p21_buy"]
        
        last_db_price = get_latest_price_from_db()
        if last_db_price:
            diff = current_21k - last_db_price
            if abs(diff) >= NOTIFICATION_THRESHOLD:
                send_bulk_notification(current_21k, diff)

        save_to_db_logic(web_prices)
    else:
        print("❌ فشل السحب: تأكد من اتجاه البيانات في الموقع.")

    print(f"{'='*55}\n")

if __name__ == "__main__":
    main()