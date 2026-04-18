import time
import requests
from datetime import datetime, timedelta
import pytz
from settings.config import supabase
from firebase_admin import messaging

# --- الإعدادات ---
CHECK_INTERVAL = 60
CAIRO_TZ = pytz.timezone('Africa/Cairo')
ALERT_COOLDOWN_MINUTES = 30

def get_current_price(symbol):
    """جلب السعر اللحظي (سواء من جداول SQL للبورصة أو API Binance للكريبتو)"""
    try:
        stock_info = supabase.table("stocks").select("candle_table_name").eq("symbol", symbol).execute()
        if not stock_info.data: return None

        table_name = stock_info.data[0]['candle_table_name']

        if table_name == 'API':
            binance_symbol = f"{symbol}USDT"
            binance_url = f"https://api.binance.com/api/v3/ticker/price?symbol={binance_symbol}"
            response = requests.get(binance_url, timeout=10)
            if response.status_code == 200:
                return float(response.json()['price'])
            return None

        res = supabase.table(table_name).select("close").order("timestamp", desc=True).limit(1).execute()
        if res.data:
            return float(res.data[0]['close'])
    except Exception as e:
        print(f"   ❌ Error fetching price for {symbol}: {e}")
    return None

# --- الدوال المساعدة (تأكد من وجودها في الكود الأصلي) ---
# [send_guardian_notification, execute_auto_sell]

def run_guardian():
    print(f"\n{'='*70}")
    print(f"🛡️  GUARDIAN ENGINE V2.0 (EGX + CRYPTO + DUAL-SWITCHES)")
    print(f"📅 Start Time: {datetime.now(CAIRO_TZ).strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"{'='*70}")

    while True:
        try:
            now_str = datetime.now(CAIRO_TZ).strftime('%H:%M:%S')
            print(f"\n🔄 [Cycle Start: {now_str}]")

            # 1. جلب القواعد: أي قاعدة مشغل فيها إما التنبيه أو البيع
            # استخدمنا فلتر 'or' الخاص بـ Supabase
            rules = supabase.table("user_protection_rules")\
                .select("*")\
                .or_("is_alert_enabled.eq.true,is_sell_enabled.eq.true")\
                .execute()

            print(f"   📋 Found {len(rules.data)} users with active protection.")

            if not rules.data:
                print("   😴 No active rules to check. Waiting...")

            for rule in rules.data:
                user_id = rule['user_id']
                symbol = rule['symbol']

                # 2. السعر اللحظي
                current_price = get_current_price(symbol)
                if current_price is None:
                    continue

                # 3. بيانات المحفظة
                holding = supabase.table("user_holdings").select("quantity, average_price")\
                    .eq("user_id", user_id).eq("symbol", symbol).execute()

                if not holding.data or holding.data[0]['quantity'] <= 0:
                    continue

                avg_price = float(holding.data[0]['average_price'])
                qty = float(holding.data[0]['quantity'])
                loss_percent = ((avg_price - current_price) / avg_price) * 100

                # طباعة تفاصيل الفحص وحالة "الزراير"
                alert_status = "🔔" if rule['is_alert_enabled'] else "🔕"
                sell_status = "🤖" if rule['is_sell_enabled'] else "👤"
                print(f"   {alert_status}{sell_status} {symbol.ljust(6)} | Price: {current_price:<8} | Loss: {loss_percent:>5.2f}%")

                # --- 4. منطق اتخاذ القرار المنفصل ---

                # أ. البيع التلقائي (له الأولوية القصوى)
                if rule['is_sell_enabled'] and loss_percent >= float(rule['liquidation_percentage']):
                    print(f"      🚨 [AUTO-SELL] Loss {loss_percent:.2f}% >= {rule['liquidation_percentage']}%")
                    # execute_auto_sell(user_id, symbol, qty, current_price)
                    # send_guardian_notification(...)

                # ب. التنبيه (يشتغل لو البيع مش مفعل أو لسه موصلناش لنسبة البيع)
                elif rule['is_alert_enabled'] and loss_percent >= float(rule['alert_percentage']):
                    # فحص الـ Cooldown
                    last_alert = rule.get('last_alert_sent_at')
                    should_notify = True
                    if last_alert:
                        last_alert_dt = datetime.fromisoformat(last_alert.replace('Z', '+00:00'))
                        if datetime.now(pytz.utc) - last_alert_dt < timedelta(minutes=ALERT_COOLDOWN_MINUTES):
                            should_notify = False

                    if should_notify:
                        print(f"      ⚠️ [ALERT SENT] Loss {loss_percent:.2f}% >= {rule['alert_percentage']}%")
                        # send_guardian_notification(...)
                        # تحديث last_alert_sent_at في الداتا بيز

            print(f"🏁 Cycle finished. Waiting {CHECK_INTERVAL}s...")

        except Exception as e:
            print(f"⚠️ Guardian Loop Error: {e}")

        time.sleep(CHECK_INTERVAL)

if __name__ == "__main__":
    run_guardian()
