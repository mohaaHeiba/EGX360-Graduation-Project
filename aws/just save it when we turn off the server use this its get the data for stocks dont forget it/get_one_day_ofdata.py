import pandas as pd
import time
import datetime
from tvDatafeed import TvDatafeed, Interval
from supabase import create_client, Client

# ==========================================
# ⚙️ إعدادات الاتصال
# ==========================================

SUPABASE_URL = "https://zlcddmhcxtxvgzxcfvxx.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpsY2RkbWhjeHR4dmd6eGNmdnh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyOTM0MTcsImV4cCI6MjA4MDg2OTQxN30.F5SxofdTfi9oBO3db1nygSXIiYEqoXgZ0OTW_Fu5Kew"

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def fetch_stocks_metadata():
    response = supabase.table("stocks").select("symbol, sector, candle_table_name").execute()
    return [s for s in response.data if s['candle_table_name'] and s['candle_table_name'] != 'API']

TIMEFRAME_LABEL = "1d"
start_date = datetime.date(2026, 2, 25)
end_date = datetime.date.today()
date_range = pd.date_range(start=start_date, end=end_date)

# ==========================================
# 🏁 التنفيذ الرئيسي مع Retry Logic
# ==========================================
tv = TvDatafeed()
stocks_to_process = fetch_stocks_metadata()

for stock in stocks_to_process:
    symbol = stock['symbol']
    table_name = stock['candle_table_name']
    sector = stock['sector']

    current_exchange = "EGX"
    tv_symbol = symbol
    if symbol == "GOLD": tv_symbol, current_exchange = "XAUUSD", "oanda"
    elif symbol == "SILVER": tv_symbol, current_exchange = "XAGUSD", "oanda"
    elif sector == "Crypto": continue

    off_days = [5, 6] if current_exchange == "oanda" else [4, 5]
    trading_days = [d.date() for d in date_range if d.weekday() not in off_days]

    print(f"\n📥 Processing {symbol} | Exchange: {current_exchange}")

    # --- بداية جزء الـ Retry ---
    attempt = 1
    data = None
    
    while True:
        try:
            data = tv.get_hist(
                symbol=tv_symbol, 
                exchange=current_exchange, 
                interval=Interval.in_daily, 
                n_bars=50 
            )
            
            # لو الداتا جت والـ DataFrame مش فاضي نكسر اللوب ونكمل
            if data is not None and not data.empty:
                print(f"   ✅ Data fetched successfully on attempt {attempt}")
                break
            else:
                print(f"   ⚠️ Attempt {attempt}: No data or empty response. Retrying in 5s...")
        
        except Exception as e:
            print(f"   ❌ Attempt {attempt} failed (Error: {e}). Retrying in 5s...")
            # في حالة "Connection Lost" يفضل أحياناً إعادة تعريف الـ tv object
            tv = TvDatafeed() 
        
        attempt += 1
        time.sleep(5) # انتظر 5 ثواني قبل المحاولة القادمة لتجنب البلوك
        
        # اختيار اختياري: لو المحاولات زادت عن 10 مثلاً ممكن تسكب السهم ده
        if attempt > 10:
            print(f"   🛑 Giving up on {symbol} after 10 failed attempts.")
            break

    if data is None or data.empty:
        continue # لو فشل بعد كل المحاولات ادخل على السهم اللي بعده
    # --- نهاية جزء الـ Retry ---

    # تكملة الكود (نفس منطقك الأصلي)
    data.reset_index(inplace=True)
    data.columns = [col.split(':')[-1].lower() for col in data.columns]
    data.rename(columns={'datetime': 'timestamp', 'date': 'timestamp', 'time': 'timestamp'}, inplace=True)
    data['timestamp'] = pd.to_datetime(data['timestamp'])

    records_to_upsert = []
    for target_date in trading_days:
        day_data = data[data['timestamp'].dt.date == target_date]
        if not day_data.empty:
            row = day_data.iloc[0]
            records_to_upsert.append({
                "timestamp": row['timestamp'].isoformat(),
                "open": float(row['open']),
                "high": float(row['high']),
                "low": float(row['low']),
                "close": float(row['close']),
                "volume": int(row['volume']),
                "timeframe": TIMEFRAME_LABEL
            })

    if records_to_upsert:
        try:
            supabase.table(table_name).upsert(records_to_upsert).execute()
            print(f"   ✅ Upserted {len(records_to_upsert)} days.")
        except Exception as db_err:
            print(f"   ❌ DB Error: {db_err}")

    time.sleep(1.5)

print(f"\n🎉 Done!")