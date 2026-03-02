import time
from datetime import datetime, timezone, timedelta
import firebase_admin
from firebase_admin import credentials, messaging
from supabase import create_client, Client

# ==============================================================================
# 1. CONFIGURATION (الإعدادات)
# ==============================================================================
SUPABASE_URL = "https://zlcddmhcxtxvgzxcfvxx.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpsY2RkbWhjeHR4dmd6eGNmdnh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyOTM0MTcsImV4cCI6MjA4MDg2OTQxN30.F5SxofdTfi9oBO3db1nygSXIiYEqoXgZ0OTW_Fu5Kew" # ⚠️ يجب استخدام Service Role للبيع
SERVICE_ACCOUNT_PATH = "service_account.json"

# إعدادات المحرك
GLOBAL_PROFIT_THRESHOLD = 5.0  # تنبيه ربح عند 5% ثابتة للجميع
REGULAR_COOLDOWN = 1800        # 30 دقيقة في الوقت العادي
HOT_ZONE_COOLDOWN = 600        # 10 دقائق في الافتتاح والإغلاق (لأن الحركة سريعة)

# تهيئة Firebase و Supabase
if not firebase_admin._apps:
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    firebase_admin.initialize_app(cred)

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# ==============================================================================
# 2. UTILITY FUNCTIONS (وظائف مساعدة)
# ==============================================================================

def is_market_hot_zone():
    """التحقق مما إذا كنا في أول أو آخر 30 دقيقة من جلسة البورصة المصرية (10:00 - 14:30)"""
    # توقيت مصر (UTC +2)
    now_egypt = datetime.now(timezone.utc) + timedelta(hours=2)
    current_time = now_egypt.time()
    
    opening_start, opening_end = datetime.strptime("10:00", "%H:%M").time(), datetime.strptime("10:30", "%H:%M").time()
    closing_start, closing_end = datetime.strptime("14:00", "%H:%M").time(), datetime.strptime("14:30", "%H:%M").time()
    
    return (opening_start <= current_time <= opening_end) or (closing_start <= current_time <= closing_end)

def send_fcm(token, title, body):
    if not token: return
    try:
        message = messaging.Message(
            notification=messaging.Notification(title=title, body=body),
            token=token,
            data={'type': 'protection_alert'}
        )
        messaging.send(message)
        print(f"   🔔 Notification: {title}")
    except Exception as e:
        print(f"   ❌ FCM Error: {e}")

def get_live_price(symbol):
    try:
        stock = supabase.table("stocks").select("candle_table_name").eq("symbol", symbol).single().execute()
        table_name = stock.data['candle_table_name']
        res = supabase.table(table_name).select("close").order("timestamp", desc=True).limit(1).execute()
        return float(res.data[0]['close']) if res.data else None
    except: return None

# ==============================================================================
# 3. CORE LOGIC (المحرك)
# ==============================================================================

def execute_protection():
    print(f"\n--- Cycle Started: {datetime.now().strftime('%H:%M:%S')} ---")
    
    # تحديد مدة الـ Cooldown الحالية بناءً على توقيت السوق
    current_cooldown = HOT_ZONE_COOLDOWN if is_market_hot_zone() else REGULAR_COOLDOWN
    if is_market_hot_zone(): print("🔥 Market Hot Zone Detected! Increased Sensitivity Enabled.")

    # جلب كل القواعد النشطة
    rules = supabase.table("user_protection_rules").select("*, profiles(fcm_token)").execute()

    for rule in rules.data:
        user_id, symbol = rule['user_id'], rule['symbol']
        fcm_token = rule['profiles'].get('fcm_token')

        # جلب بيانات المحفظة
        holding = supabase.table("user_holdings").select("average_price, quantity").eq("user_id", user_id).eq("symbol", symbol).single().execute()
        if not holding.data or holding.data['quantity'] <= 0: continue

        avg_price, qty = float(holding.data['average_price']), float(holding.data['quantity'])
        market_price = get_live_price(symbol)
        if market_price is None: continue

        # حساب التغير بنسبة مئوية
        # $$Change \% = \frac{\text{Current} - \text{Avg}}{\text{Avg}} \times 100$$
        change_pct = ((market_price - avg_price) / avg_price) * 100
        
        # إدارة التوقيت (Cooldown)
        last_alert = rule.get('last_alert_sent_at')
        seconds_since = (datetime.now(timezone.utc) - datetime.fromisoformat(last_alert.replace('Z', '+00:00'))).seconds if last_alert else 999999

        # --- أ. تنبيه الأرباح (تلقائي 5% لكل الناس) ---
        if change_pct >= GLOBAL_PROFIT_THRESHOLD and seconds_since >= current_cooldown:
            send_fcm(fcm_token, f"🚀 {symbol} Profit!", f"Your position is up {change_pct:.1f}%. Price: {market_price} EGP")
            supabase.table("user_protection_rules").update({"last_alert_sent_at": datetime.now(timezone.utc).isoformat()}).eq("id", rule['id']).execute()

        # --- ب. تنبيه الخسارة (بناءً على إعدادات المستخدم) ---
        elif rule['is_alert_enabled'] and change_pct <= -float(rule['alert_percentage']):
            if seconds_since >= current_cooldown:
                send_fcm(fcm_token, f"📉 {symbol} Drop Alert", f"{symbol} decreased by {abs(change_pct):.1f}%. Price: {market_price} EGP")
                supabase.table("user_protection_rules").update({"last_alert_sent_at": datetime.now(timezone.utc).isoformat()}).eq("id", rule['id']).execute()

        # --- ج. البيع التلقائي (الخسارة العنيفة) ---
        if rule['is_sell_enabled'] and change_pct <= -float(rule['liquidation_percentage']):
            # استدعاء دالة البيع في الـ SQL
            try:
                supabase.rpc("execute_trade", {
                    "p_user_id": user_id, "p_symbol": symbol, "p_type": "sell",
                    "p_quantity": qty, "p_price": market_price
                }).execute()
                send_fcm(fcm_token, "⚠️ Auto-Sell Executed", f"Sold {qty} {symbol} at {market_price} to stop loss.")
                print(f"✅ Executed Auto-Sell for {user_id[:8]}")
            except Exception as e: print(f"❌ Sell Error: {e}")

if __name__ == "__main__":
    while True:
        try:
            execute_protection()
        except Exception as e: print(f"🚨 Engine Error: {e}")
        time.sleep(60) # فحص كل دقيقة