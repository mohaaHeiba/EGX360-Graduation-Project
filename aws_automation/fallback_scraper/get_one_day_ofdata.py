import os

from dotenv import load_dotenv
import pandas as pd
import time
import datetime
from tvDatafeed import TvDatafeed, Interval
from supabase import create_client, Client

# ==========================================
# Setup
# ==========================================

env_path = os.path.join(os.path.dirname(__file__), '..', '.env')

load_dotenv(dotenv_path=env_path)

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")


# print(f"URL: {SUPABASE_URL}, KEY: {SUPABASE_KEY}")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def fetch_stocks_metadata():
    response = supabase.table("stocks").select("symbol, sector, candle_table_name").execute()
    return [s for s in response.data if s.get('candle_table_name') not in ['API', 'API_FINNHUB'] and s.get('sector') not in ['Crypto', 'US Stocks', 'US ETFs']]

# ==============================================================================================================================

TIMEFRAME_LABEL = "1d"
start_date = datetime.date(2025, 10, 25)
end_date = datetime.date.today()
date_range = pd.date_range(start=start_date, end=end_date)

# ==============================================================================================================================
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
            
            if data is not None and not data.empty:
                print(f"   ✅ Data fetched successfully on attempt {attempt}")
                break
            else:
                print(f"   ⚠️ Attempt {attempt}: No data or empty response. Retrying in 5s...")
        
        except Exception as e:
            print(f"   ❌ Attempt {attempt} failed (Error: {e}). Retrying in 5s...")
            tv = TvDatafeed() 
        
        attempt += 1
        time.sleep(5) # Wait 5 seconds for block
        
        if attempt > 10:
            print(f"   🛑 Giving up on {symbol} after 10 failed attempts.")
            break

    if data is None or data.empty:
        continue

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