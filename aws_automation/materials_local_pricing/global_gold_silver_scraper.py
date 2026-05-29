import os
import time
import datetime
import pytz
import logging
import pandas as pd
from dotenv import load_dotenv
from supabase import create_client, Client
from tvDatafeed import TvDatafeed, Interval

# ==========================================
# Configure Logging
# ==========================================
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger("GoldSilverScraper")
# Mute tvDatafeed internal logs
logging.getLogger("tvDatafeed").setLevel(logging.CRITICAL)

# ==========================================
# Supabase Setup
# ==========================================
env_path = os.path.join(os.path.dirname(__file__), '..', '.env')
load_dotenv(dotenv_path=env_path)

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

if not SUPABASE_URL or not SUPABASE_KEY:
    logger.error("Supabase credentials not found in .env file.")
    exit(1)

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# ==========================================
# Configuration
# ==========================================
UPDATE_INTERVAL = 300  # 5 minutes
TIMEFRAME_LABEL = "1d"
CAIRO_TZ = pytz.timezone('Africa/Cairo')

ASSETS = [
    {"db_symbol": "GOLD", "tv_symbol": "XAUUSD", "exchange": "oanda"},
    {"db_symbol": "SILVER", "tv_symbol": "XAGUSD", "exchange": "oanda"}
]

def fetch_table_names():
    """Fetches the specific table names for Gold and Silver from the stocks table."""
    table_names = {}
    try:
        response = supabase.table("stocks").select("symbol, candle_table_name").in_("symbol", ["GOLD", "SILVER"]).execute()
        for item in response.data:
            table_names[item['symbol']] = item['candle_table_name']
    except Exception as e:
        logger.error(f"Error fetching table names from Supabase: {e}")
    return table_names

def is_global_market_open():
    """
    Forex / Precious metals (Oanda) market hours:
    Opens: Sunday 5:00 PM EST
    Closes: Friday 5:00 PM EST
    
    Using Cairo time for a simple check:
    The market is essentially closed all of Saturday and most of Sunday.
    """
    now_cairo = datetime.datetime.now(CAIRO_TZ)
    weekday = now_cairo.weekday()
    
    # 5 = Saturday, 6 = Sunday
    if weekday == 5: 
        return False
    # Opens late Sunday night in Cairo (around midnight)
    if weekday == 6 and now_cairo.hour < 23: 
        return False
        
    return True

def sync_gold_silver():
    table_names = fetch_table_names()
    
    if not table_names or "GOLD" not in table_names or "SILVER" not in table_names:
        logger.error("Could not find candle table names for GOLD and SILVER. Check the 'stocks' table.")
        return

    logger.info("Initializing TvDatafeed...")
    tv = TvDatafeed()
    
    logger.info("🚀 Starting Gold & Silver Live Scraper Loop (Every 5 minutes)...")
    
    last_updated_date = {}
    
    while True:
        try:
            if not is_global_market_open():
                logger.info("🌙 Market is closed (Weekend). Sleeping for 1 hour...")
                time.sleep(3600)
                continue
                
            for asset in ASSETS:
                db_symbol = asset["db_symbol"]
                tv_symbol = asset["tv_symbol"]
                exchange = asset["exchange"]
                table_name = table_names.get(db_symbol)
                
                if not table_name:
                    continue
                
                # Fetch 2 bars:
                # 1. The previous day's closed candle (to ensure it is fully updated and finalized).
                # 2. The current day's live candle (to keep upserting it every 5 mins).
                data = tv.get_hist(symbol=tv_symbol, exchange=exchange, interval=Interval.in_daily, n_bars=2)
                
                if data is not None and not data.empty:
                    data.reset_index(inplace=True)
                    data.columns = [col.split(':')[-1].lower() for col in data.columns]
                    data.rename(columns={'datetime': 'timestamp', 'date': 'timestamp', 'time': 'timestamp'}, inplace=True)
                    data['timestamp'] = pd.to_datetime(data['timestamp'])
                    
                    records_to_upsert = []
                    for _, row in data.iterrows():
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
                        # Supabase UPSERT will update the existing day's candle or insert a new one if it's a new day
                        supabase.table(table_name).upsert(records_to_upsert).execute()
                        
                        # Update the prev_close in the stocks table only once per day
                        if len(records_to_upsert) >= 2:
                            # نجيب تاريخ اليوم الحالي بتوقيت القاهرة
                            current_day = datetime.datetime.now(CAIRO_TZ).date()
                            
                            # لو السهم ده لسه متحدثش النهارده، حدث الـ prev_close
                            if last_updated_date.get(db_symbol) != current_day:
                                prev_close_val = float(records_to_upsert[-2]['close'])
                                supabase.table("stocks").update({"prev_close": prev_close_val}).eq("symbol", db_symbol).execute()
                                
                                # احفظ إن التحديث بتاع اليوم ده تم خلاص
                                last_updated_date[db_symbol] = current_day
                                logger.info(f"✅ New Day Update! {db_symbol} | Prev Close locked for today: {prev_close_val}")
                            else:
                                # ده اللي هيحصل باقي اليوم (تحديث الشمعة اللايف بس)
                                logger.info(f"✅ Upserted {db_symbol} | Latest Live Close: {records_to_upsert[-1]['close']}")
                        else:
                            logger.info(f"✅ Upserted {db_symbol} | Latest Live Close: {records_to_upsert[-1]['close']}")
                else:
                    logger.warning(f"⚠️ No data returned for {db_symbol}. Re-initializing TV...")
                    tv = TvDatafeed()
                    time.sleep(2)
                    
        except Exception as e:
            logger.error(f"❌ Error in scraper loop: {e}")
            # Try to re-init on connection failures
            tv = TvDatafeed() 
            
        logger.info(f"⏳ Waiting {UPDATE_INTERVAL // 60} minutes until next update...")
        time.sleep(UPDATE_INTERVAL)

if __name__ == "__main__":
    sync_gold_silver()
