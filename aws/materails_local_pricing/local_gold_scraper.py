import requests
import firebase_admin
from firebase_admin import credentials, messaging
from bs4 import BeautifulSoup
from datetime import datetime
from supabase import create_client, Client
import re

# --- 1. Configurations ---
SUPABASE_URL = "https://zlcddmhcxtxvgzxcfvxx.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpsY2RkbWhjeHR4dmd6eGNmdnh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyOTM0MTcsImV4cCI6MjA4MDg2OTQxN30.F5SxofdTfi9oBO3db1nygSXIiYEqoXgZ0OTW_Fu5Kew"
SERVICE_ACCOUNT_PATH = "/home/ubuntu/materails_local_pricing/service_account.json"
TABLE_NAME = "material_prices"
NOTIFICATION_THRESHOLD = 10.0  # تنبيه عند تغير السعر بـ 5 جنيه

# --- 2. Initialization ---
if not firebase_admin._apps:
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    firebase_admin.initialize_app(cred)

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# --- 3. Helper Functions ---

def clean_price(text):
    """تنظيف النص وتحويله لرقم (float)"""
    try:
        # حذف أي شيء ليس رقماً أو نقطة عشرية
        clean_str = re.sub(r'[^\d.]', '', text)
        return float(clean_str)
    except:
        return 0.0

def get_latest_price_from_db():
    """جلب آخر سعر مسجل في قاعدة البيانات للمقارنة"""
    try:
        res = supabase.table(TABLE_NAME).select("price_21k").order("timestamp", desc=True).limit(1).execute()
        if res.data:
            return float(res.data[0]['price_21k'])
    except Exception as e:
        print(f"   ❌ DB Fetch Error: {e}")
    return None

def get_prices_from_safehaven():
    """
    Scrape Gold AND Silver from SafeHavenHub
    """
    url = "https://safehavenhub.com/pages/%D8%A7%D8%B3%D8%B9%D8%A7%D8%B1-%D8%A7%D9%84%D8%B0%D9%87%D8%A8-%D9%88%D8%A7%D9%84%D9%81%D8%B6%D8%A9"
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }

    try:
        response = requests.get(url, headers=headers, timeout=20)
        if response.status_code != 200:
            return None

        soup = BeautifulSoup(response.content, "html.parser")
        tables = soup.find_all("table")

        prices_data = {}

        for table in tables:
            rows = table.find_all("tr")
            for row in rows:
                cols = row.find_all(["td", "th"])
                cols_text = [ele.text.strip() for ele in cols]

                if not cols_text or len(cols_text) < 2:
                    continue

                # --- استخراج الذهب ---
                if "عيار 24" in cols_text[0]:
                    prices_data["price_24k"] = clean_price(cols_text[1])
                elif "عيار 21" in cols_text[0]:
                    prices_data["price_21k"] = clean_price(cols_text[1])
                elif "عيار 18" in cols_text[0]:
                    prices_data["price_18k"] = clean_price(cols_text[1])

                # --- استخراج الفضة ---
                elif "عيار 999" in cols_text[0]:
                    prices_data["silver_999"] = clean_price(cols_text[1])
                elif "عيار 925" in cols_text[0]:
                    prices_data["silver_925"] = clean_price(cols_text[1])

        return prices_data

    except Exception as e:
        print(f"   ❌ Web Scraping Error: {e}")
        return None

def send_bulk_notification(current_price, diff):
    """إرسال الإشعارات"""
    try:
        res = supabase.table("profiles").select("fcm_token").not_.is_("fcm_token", "null").execute()
        tokens = [item['fcm_token'] for item in res.data if item['fcm_token']]

        if not tokens:
            return

        change_icon = "🔼" if diff > 0 else "🔽"
        display_title = "Gold Price Update | 21K 🟡"
        display_body = f"21K is now {current_price:,.0f} EGP ({change_icon} {diff:+.0f} EGP)"

        message = messaging.MulticastMessage(
            notification=messaging.Notification(
                title=display_title,
                body=display_body
            ),
            android=messaging.AndroidConfig(
                priority='high',
                notification=messaging.AndroidNotification(
                    sound='default',
                    channel_id='gold_price_alerts',
                    color='#DAA520'
                )
            ),
            data={
                'type': 'gold_update',
                'price': str(current_price),
                'click_action': 'FLUTTER_NOTIFICATION_CLICK'
            },
            tokens=tokens
        )

        result = messaging.send_each_for_multicast(message)
        print(f"   🔔 FCM: Delivered to {result.success_count} devices.")
    except Exception as e:
        print(f"   ❌ FCM Error: {e}")

def save_to_db(prices_dict):
    """حفظ البيانات في Supabase"""
    try:
        data = {
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "price_24k": prices_dict.get("price_24k"),
            "price_21k": prices_dict.get("price_21k"),
            "price_18k": prices_dict.get("price_18k"),
            "silver_999": prices_dict.get("silver_999"),
            "silver_925": prices_dict.get("silver_925")
        }
        # إزالة القيم الفارغة
        data = {k: v for k, v in data.items() if v is not None}

        supabase.table(TABLE_NAME).insert(data).execute()
        print(f"   ✅ Saved to DB: {prices_dict.get('price_21k')} EGP | Silver: {prices_dict.get('silver_999')}")
    except Exception as e:
        print(f"   ❌ DB Save Error: {e}")

# --- 4. Main Logic ---

def main():
    start_time = datetime.now()
    print(f"\n{'='*55}")
    print(f"💰 MARKET TRACKER CYCLE: {start_time.strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"{'='*55}")

    # 1. جلب الأسعار من الموقع الجديد
    market_prices = get_prices_from_safehaven()

    if market_prices:
        # عرض تفاصيل البيانات المسحوبة (الذهب والفضة)
        print("\n🔎 Retrieved Data Details:")
        for key, value in market_prices.items():
            print(f"   🔹 {key.ljust(12)} : {value} EGP")
        print("-" * 30)

        if market_prices.get("price_21k"):
            current_21k = market_prices["price_21k"]
            print(f"📊 Current 21K: {current_21k:,.0f} EGP")

            # 2. مقارنة السعر بالداتا بيز
            db_last_price = get_latest_price_from_db()

            if db_last_price is not None:
                diff = current_21k - db_last_price
                print(f"📝 Change: {diff:+.2f} EGP")

                if abs(diff) >= NOTIFICATION_THRESHOLD:
                    print(f"🚀 Movement detected. Sending alerts...")
                    send_bulk_notification(current_21k, diff)
                else:
                    print(f"😴 Change below threshold. No alerts sent.")

            # 3. حفظ البيانات الجديدة (شاملة الفضة)
            save_to_db(market_prices)
    else:
        print("❌ FAILED: Could not scrape prices from SafeHavenHub.")

    print(f"{'='*55}")
    print(f"🏁 Finished at: {datetime.now().strftime('%H:%M:%S')}")
    print(f"{'='*55}\n")

if __name__ == "__main__":
    main()
