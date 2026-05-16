import time
import logging
import pytz
import threading
from collections import deque
from datetime import datetime, timedelta, time as dtime
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import List, Dict, Any, Optional, Set

import pandas as pd
from tvDatafeed import TvDatafeed, Interval
from supabase import Client

# Import settings
from settings.config import supabase, TV_USERNAME, TV_PASSWORD
from settings.utils import is_market_open

# =========================================================
# 1. CONSTANTS & PRODUCTION CONFIG (v9.0)
# =========================================================
CAIRO_TZ = pytz.timezone('Africa/Cairo')
EXCHANGE = "EGX"

# Safest Setup for 35 stocks to avoid TV bans
UPDATE_FREQUENCY = 60  
BATCH_DELAY = 1.5      
REQUEST_DELAY = 0.5    
MAX_WORKERS = 3        
BATCH_SIZE = 3         

# Optimized Intervals
DAILY_SYNC_INTERVAL = 600 # 10 Minutes (Less pressure)
BARS_LIVE_M = 2           # Only current + previous candle
BARS_INITIAL_M = 300
BARS_INITIAL_D = 5
BARS_FINAL_M = 100
BARS_FINAL_D = 1

# Logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger("EGX360_v9")

# =========================================================
# 2. THREAD-LOCAL STORAGE (Real Parallelism)
# =========================================================
thread_local = threading.local()

def get_tv_instance():
    """Returns or creates a thread-specific TvDatafeed instance."""
    if not hasattr(thread_local, "tv"):
        logger.info(f"🧵 Thread-{threading.get_ident()} initializing private TvDatafeed...")
        thread_local.tv = TvDatafeed(TV_USERNAME, TV_PASSWORD)
    return thread_local.tv

# Global Executor
executor = ThreadPoolExecutor(max_workers=MAX_WORKERS)

# Precise Sliding Window Cache
# {table_name: deque([ts1, ts2, ...], maxlen=20)}
last_saved_timestamps: Dict[str, deque] = {}

# Performance Metrics
engine_stats = {
    "successful_syncs": 0, "failed_syncs": 0, "db_upserts": 0,
    "skipped_duplicates": 0, "tv_retries": 0, "last_cycle_duration": 0.0
}

# =========================================================
# 3. CORE UTILITY FUNCTIONS
# =========================================================

def fetch_stock_metadata() -> List[Dict[str, Any]]:
    try:
        response = supabase.table("stocks").select("id, symbol, sector, candle_table_name").execute()
        return [s for s in response.data if s['candle_table_name'] and s['candle_table_name'] != 'API' and s['sector'] not in ['Crypto', 'Materials']]
    except Exception as e:
        logger.error(f"❌ Metadata Error: {e}")
        return []

def chunk_batches(data: List[Any], size: int) -> List[List[Any]]:
    return [data[i:i + size] for i in range(0, len(data), size)]

def fetch_tv_data(symbol: str, interval: Interval, n_bars: int) -> Optional[pd.DataFrame]:
    """Uses thread-local TV instance with NO global locks."""
    tv_client = get_tv_instance()
    for attempt in range(1, 6):
        try:
            data = tv_client.get_hist(symbol, EXCHANGE, interval, n_bars=n_bars)
            if data is not None and not data.empty:
                return data
        except Exception as e:
            engine_stats["tv_retries"] += 1
            if attempt >= 3:
                # Re-init this specific thread's instance if it keeps failing
                thread_local.tv = TvDatafeed(TV_USERNAME, TV_PASSWORD)
                tv_client = thread_local.tv
        time.sleep(REQUEST_DELAY * attempt)
    return None

# =========================================================
# 4. OPTIMIZED PROCESSING
# =========================================================

def clean_1m_data(df: pd.DataFrame, table_name: str, label: str) -> List[Dict[str, Any]]:
    df = df.reset_index()
    df.columns = [c.split(":")[-1].lower() for c in df.columns]
    
    records = []
    today_cairo = datetime.now(CAIRO_TZ).date()
    
    if table_name not in last_saved_timestamps:
        last_saved_timestamps[table_name] = deque(maxlen=20)

    for _, row in df.iterrows():
        # Sanity & Session
        if row["volume"] <= 0 or row["low"] > row["high"] or row["open"] <= 0: continue
        
        utc_dt = row["datetime"].replace(tzinfo=pytz.utc)
        cairo_dt = utc_dt.astimezone(CAIRO_TZ)
        
        if not (dtime(10, 0) <= cairo_dt.time() <= dtime(14, 46)): continue
        if "Initial" not in label and cairo_dt.date() != today_cairo: continue

        # Deduplication using True UTC ISO
        iso_ts = cairo_dt.astimezone(pytz.utc).isoformat()
        
        if iso_ts in last_saved_timestamps[table_name]:
            engine_stats["skipped_duplicates"] += 1
            continue
            
        records.append({
            "timestamp": iso_ts, "open": float(row["open"]), "high": float(row["high"]),
            "low": float(row["low"]), "close": float(row["close"]),
            "volume": int(row["volume"]), "timeframe": "1m"
        })
        last_saved_timestamps[table_name].append(iso_ts)

    return records

def prepare_daily_record(df: pd.DataFrame) -> Optional[Dict[str, Any]]:
    if df is None or df.empty: return None
    row = df.iloc[-1]
    day_dt = pd.to_datetime(df.index[-1]).date()
    # Cairo 10:00 AM fixed
    iso_ts = datetime.combine(day_dt, dtime(10, 0)).replace(tzinfo=CAIRO_TZ).astimezone(pytz.utc).isoformat()
    
    if row["low"] <= row["high"] and row["open"] > 0:
        return {
            "timestamp": iso_ts, "open": float(row["open"]), "high": float(row["high"]),
            "low": float(row["low"]), "close": float(row["close"]),
            "volume": int(row["volume"]), "timeframe": "1d"
        }
    return None

# =========================================================
# 5. SYNC ORCHESTRATION
# =========================================================

def sync_stock(stock_meta: Dict[str, Any], n_bars_m: int, n_bars_d: int, label: str, do_daily: bool) -> bool:
    symbol = stock_meta['symbol']
    table_name = stock_meta['candle_table_name']
    
    try:
        df_1m = fetch_tv_data(symbol, Interval.in_1_minute, n_bars=n_bars_m)
        df_1d = fetch_tv_data(symbol, Interval.in_daily, n_bars=n_bars_d) if do_daily else None
            
        processed_m = clean_1m_data(df_1m, table_name, label) if df_1m is not None else []
        processed_d = prepare_daily_record(df_1d) if df_1d is not None else None
        
        payload = processed_m + ([processed_d] if processed_d else [])
        if payload:
            supabase.table(table_name).upsert(payload).execute()
            engine_stats["db_upserts"] += len(payload)
            return True
        return False
    except Exception as e:
        logger.error(f"❌ [{symbol}] Error: {e}")
        return False

def process_batch_sync(batch: List[Dict[str, Any]], n_bars_m: int, n_bars_d: int, label: str, do_daily: bool):
    """Wait for all futures in batch to complete (Strict Synchronization)."""
    futures = [executor.submit(sync_stock, stock, n_bars_m, n_bars_d, label, do_daily) for stock in batch]
    for future in as_completed(futures):
        if future.result():
            engine_stats["successful_syncs"] += 1
        else:
            engine_stats["failed_syncs"] += 1

# =========================================================
# 6. MAIN ENGINE LOOP
# =========================================================

def run_market_engine():
    logger.info("🚀 EGX360 v9.0 | High-Performance Multi-Threaded Engine")
    
    stocks = fetch_stock_metadata()
    if not stocks: return
    
    batches = chunk_batches(stocks, BATCH_SIZE)
    last_daily_sync = 0
    market_was_open = False
    
    # Initial Catch-up
    logger.info("⚡ Catching up...")
    for batch in batches:
        process_batch_sync(batch, BARS_INITIAL_M, BARS_INITIAL_D, "Initial", True)
        time.sleep(BATCH_DELAY)
    
    while True:
        try:
            is_open = is_market_open()
            if is_open:
                market_was_open = True
                cycle_start = time.time()
                
                # Check Daily Interval
                do_daily = (time.time() - last_daily_sync) >= DAILY_SYNC_INTERVAL
                if do_daily: last_daily_sync = time.time()

                for i, batch in enumerate(batches):
                    process_batch_sync(batch, BARS_LIVE_M, 1, "Live", do_daily)
                    if i < len(batches) - 1: time.sleep(BATCH_DELAY)
                
                duration = time.time() - cycle_start
                logger.info(f"📊 Cycle: {duration:.1f}s | DB: {engine_stats['db_upserts']} | Skip: {engine_stats['skipped_duplicates']}")
                time.sleep(max(0, UPDATE_FREQUENCY - duration))
            else:
                if market_was_open:
                    logger.info("🌙 Market Close. Final Sync...")
                    for batch in batches:
                        process_batch_sync(batch, BARS_FINAL_M, BARS_FINAL_D, "Final", True)
                        time.sleep(BATCH_DELAY)
                    market_was_open = False
                time.sleep(60)
        except KeyboardInterrupt:
            executor.shutdown(wait=True)
            break
        except Exception as e:
            logger.error(f"🚨 Loop Error: {e}")
            time.sleep(10)

if __name__ == "__main__":
    run_market_engine()
