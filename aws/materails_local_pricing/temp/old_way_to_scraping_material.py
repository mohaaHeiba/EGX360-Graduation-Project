import cloudscraper
import firebase_admin
from firebase_admin import credentials, messaging
from bs4 import BeautifulSoup
from datetime import datetime
from supabase import create_client, Client

# --- 1. Configurations ---
SUPABASE_URL = "https://zlcddmhcxtxvgzxcfvxx.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpsY2RkbWhjeHR4dmd6eGNmdnh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyOTM0MTcsImV4cCI6MjA4MDg2OTQxN30.F5SxofdTfi9oBO3db1nygSXIiYEqoXgZ0OTW_Fu5Kew"
SERVICE_ACCOUNT_PATH = "/home/ubuntu/materails_local_pricing/service_account.json"
TABLE_NAME = "material_prices"
NOTIFICATION_THRESHOLD = 10.0  # تنبيه فقط عند تغير السعر بـ 5 جنيه أو أكثر

# --- 2. Initialization ---
if not firebase_admin._apps:
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    firebase_admin.initialize_app(cred)

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
scraper = cloudscraper.create_scraper()

# --- 3. Functions ---

def get_latest_price_from_db():
    """Fetch the most recent price from Supabase to compare"""
    try:
        res = supabase.table(TABLE_NAME).select("price_21k").order("timestamp", desc=True).limit(1).execute()
        if res.data:
            return float(res.data[0]['price_21k'])
    except Exception as e:
        print(f"   ❌ DB Fetch Error: {e}")
    return None

def get_gold_prices_web():
    """Scrape real-time prices from gold-price-live.com"""
    url = "https://gold-price-live.com"
    try:
        response = scraper.get(url, timeout=20)
        soup = BeautifulSoup(response.text, 'html.parser')
        prices = {}
        mapping = {"عيار 24": "price_24k", "عيار 21": "price_21k", "عيار 18": "price_18k"}

        for name, column in mapping.items():
            row = soup.find("td", string=lambda text: text and name in text)
            if row:
                price_text = row.find_next_sibling("td").text.strip().replace(",", "")
                prices[column] = float(price_text.split()[0])
        return prices
    except Exception as e:
        print(f"   ❌ Web Scraping Error: {e}")
        return None

def send_bulk_notification(current_price, diff):
    """Send professional minimalist gold alert via FCM"""
    try:
        # Get tokens for all users
        res = supabase.table("profiles").select("fcm_token").not_.is_("fcm_token", "null").execute()
        tokens = [item['fcm_token'] for item in res.data if item['fcm_token']]

        if not tokens:
            return

        # 1. Icons based on movement
        change_icon = "🔼" if diff > 0 else "🔽"

        # 2. Format Title & Body (Minimalist Style)
        display_title = "Gold Price Update | 21K 🟡"
        # Example Body: 21K is now 3,250 EGP (🔼 +15 EGP)
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
                    color='#DAA520' # Professional Goldenrod color
                )
            ),
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(aps=messaging.Aps(sound='default', badge=1))
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
    """Save current prices to Supabase history"""
    try:
        data = {
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "price_24k": prices_dict.get("price_24k"),
            "price_21k": prices_dict.get("price_21k"),
            "price_18k": prices_dict.get("price_18k"),
            "silver_999": 152.08,
            "silver_925": 140.81
        }
        supabase.table(TABLE_NAME).insert(data).execute()
        print(f"   ✅ Saved to DB: {prices_dict.get('price_21k')} EGP")
    except Exception as e:
        print(f"   ❌ DB Save Error: {e}")

# --- 4. Main Logic ---

def main():
    start_time = datetime.now()
    print(f"\n{'='*55}")
    print(f"💰 GOLD TRACKER CYCLE: {start_time.strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"{'='*55}")

    web_prices = get_gold_prices_web()

    if web_prices and web_prices.get("price_21k"):
        current_21k = web_prices["price_21k"]
        print(f"📊 Current 21K: {current_21k:,.0f} EGP")

        db_last_price = get_latest_price_from_db()

        if db_last_price is not None:
            diff = current_21k - db_last_price
            print(f"📝 Change: {diff:+.2f} EGP")

            if abs(diff) >= NOTIFICATION_THRESHOLD:
                print(f"🚀 Movement detected. Sending professional alerts...")
                send_bulk_notification(current_21k, diff)
            else:
                print(f"😴 Change below threshold. No alerts sent.")

        save_to_db(web_prices)
    else:
        print("❌ FAILED: Could not scrape web prices.")

    print(f"{'='*55}")
    print(f"🏁 Finished at: {datetime.now().strftime('%H:%M:%S')}")
    print(f"{'='*55}\n")

if __name__ == "__main__":
    main()
