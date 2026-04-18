
import os

from dotenv import load_dotenv
import pandas as pd
import time
import datetime
import logging
from tvDatafeed import TvDatafeed, Interval
from supabase import create_client, Client

# ==========================================
# Clean logs for TradingView 
# ==========================================
logging.getLogger("tvDatafeed").setLevel(logging.CRITICAL)

# ==========================================
#  Supabase
# ==========================================
env_path = os.path.join(os.path.dirname(__file__), '..', '.env')

load_dotenv(dotenv_path=env_path)

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")


# print(f"URL: {SUPABASE_URL}, KEY: {SUPABASE_KEY}")


supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# Get only stocks EG
def get_egx_stocks():
    response = supabase.table("stocks").select("symbol, sector, candle_table_name").execute()
    return [s for s in response.data if s['candle_table_name'] and s['candle_table_name'] != 'API' and s['sector'] not in ['Crypto', 'Materials']]

#==============================================================================================================================
# Time
EXCHANGE = "EGX"
TIMEFRAME_LABEL = "1m"
START_TIME = datetime.time(10, 0)
END_TIME = datetime.time(14, 30)

start_date = datetime.date(2026,4 , 14)
end_date = datetime.date.today()

all_days = pd.date_range(start=start_date, end=end_date)
trading_days = [d.date() for d in all_days if d.weekday() not in [4, 5]]

# ==============================================================================================================================
# ==========================================
tv = TvDatafeed()
egx_stocks = get_egx_stocks()

print(f"🚀 Starting Deep Backfill for {len(egx_stocks)} stocks.")
print(f"📅 Period: {start_date} to {end_date} (Excluding Fri/Sat)")

for stock in egx_stocks:
    symbol = stock['symbol']
    table_name = stock['candle_table_name']
    
    print(f"\n‌🚩 Stock: {symbol} --------------------------------")

    for current_day in trading_days:
        print(f"   📅 Processing Day: {current_day}...", end="", flush=True)
        
        attempt = 1
        max_attempts = 20
        day_success = False
        
        while attempt <= max_attempts and not day_success:
            try:
                data = tv.get_hist(
                    symbol=symbol, 
                    exchange=EXCHANGE, 
                    interval=Interval.in_1_minute, 
                    n_bars=5000
                )
                
                if data is not None and not data.empty:
                    data.reset_index(inplace=True)
                    data.columns = [col.split(':')[-1].lower() for col in data.columns]
                    data.rename(columns={'datetime': 'timestamp', 'date': 'timestamp', 'time': 'timestamp'}, inplace=True)
                    data['timestamp'] = pd.to_datetime(data['timestamp'])

                    mask = (data['timestamp'].dt.date == current_day) & \
                           (data['timestamp'].dt.time >= START_TIME) & \
                           (data['timestamp'].dt.time <= END_TIME)
                    
                    filtered_data = data.loc[mask].copy()

                    if not filtered_data.empty:
                        records = []
                        for _, row in filtered_data.iterrows():
                            records.append({
                                "timestamp": row['timestamp'].isoformat(),
                                "open": float(row['open']),
                                "high": float(row['high']),
                                "low": float(row['low']),
                                "close": float(row['close']),
                                "volume": int(row['volume']),
                                "timeframe": TIMEFRAME_LABEL
                            })
                        
                        supabase.table(table_name).upsert(records).execute()
                        print(f" | ✅ Success ({len(records)} candles) [Attempt {attempt}]")
                        day_success = True
                    else:
                        print(f" | ⚠️ No data found (Holiday?)")
                        day_success = True 
                else:
                    attempt += 1
                    time.sleep(3) 

            except Exception:
                tv = TvDatafeed()
                attempt += 1
                time.sleep(5)
        
        if not day_success:
            print(f" | 🛑 Failed after {max_attempts} attempts.")

    time.sleep(1)

print(f"\n🎉 Deep Backfill Completed!")