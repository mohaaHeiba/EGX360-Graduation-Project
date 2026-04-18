import pandas as pd
import time
import pytz
from datetime import datetime, timedelta
from tvDatafeed import TvDatafeed, Interval

# استيراد الإعدادات
from settings.config import supabase, TV_USERNAME, TV_PASSWORD
from settings.utils import is_market_open

# =========================================================
# CONFIG
# =========================================================
symbol = "egx70ewi"
exchange = "EGX"
table_name = "egx70ewi_candles"
UPDATE_FREQUENCY = 20
CAIRO_TZ = pytz.timezone('Africa/Cairo')

tv = TvDatafeed(TV_USERNAME, TV_PASSWORD)

# =========================================================
# ROBUST SYNC FUNCTION (Anti-Noise & Sanity Checks)
# =========================================================
def sync_data(n_bars_m=1, n_bars_d=1, label="Live"):
    try:
        live_1m = tv.get_hist(symbol, exchange, Interval.in_1_minute, n_bars=n_bars_m)
        live_1d = tv.get_hist(symbol, exchange, Interval.in_daily, n_bars=n_bars_d)

        # ---------------------------------------------------------
        # 1. معالجة شموع الدقيقة
        # ---------------------------------------------------------
        if live_1m is not None and not live_1m.empty:
            live_1m.reset_index(inplace=True)
            live_1m.columns = [c.split(":")[-1].lower() for c in live_1m.columns]

            records_m = []
            today_cairo = datetime.now(CAIRO_TZ).date()

            for _, row in live_1m.iterrows():
                utc_dt = row["datetime"].replace(tzinfo=pytz.utc)
                cairo_dt = utc_dt.astimezone(CAIRO_TZ)

                # === 🛡️ فلاتر التنظيف (Noise Filters) ===
                
                # 1. فلتر الحجم: لازم فيه تداول حقيقي
                if row["volume"] <= 0: continue

                # 2. فلتر الوقت: داخل حدود الجلسة (10:00 - 14:45)
                m_start = cairo_dt.replace(hour=10, minute=0, second=0, microsecond=0)
                m_end = cairo_dt.replace(hour=14, minute=45, second=0, microsecond=0)
                if not (m_start <= cairo_dt <= m_end): continue

                # 3. فلتر التاريخ: تجاهل الأيام السابقة في الوضع اللايف
                if label != "Initial Catch-up" and cairo_dt.date() != today_cairo: continue
                
                # === 🧠 فحوصات المنطق (Sanity Checks) ===
                _open = float(row["open"])
                _high = float(row["high"])
                _low = float(row["low"])
                _close = float(row["close"])
                
                # مستحيل الـ Low يكون أعلى من الـ High
                if _low > _high:
                    continue
                # مستحيل السعر يكون صفر أو سالب
                if _open <= 0 or _close <= 0:
                     continue
                # ===============================================

                # الفورمات المخادع (+00) عشان يظهر في الجدول 10:00
                exact_timestamp = cairo_dt.strftime("%Y-%m-%d %H:%M:%S+00")
                
                records_m.append({
                    "timestamp": exact_timestamp,
                    "open": _open,
                    "high": _high,
                    "low": _low,
                    "close": _close,
                    "volume": int(row["volume"]),
                    "timeframe": "1m"
                })

            if records_m:
                supabase.table(table_name).upsert(records_m).execute()
                print(f"✅ [{label}] Saved {len(records_m)} clean bars for {symbol}")

        # ---------------------------------------------------------
        # 2. معالجة اليومي
        # ---------------------------------------------------------
        if live_1d is not None and not live_1d.empty:
            row_d = live_1d.iloc[-1]
            day_dt = pd.to_datetime(live_1d.index[-1]).date()
            
            # تثبيت الوقت 10 صباحاً القاهرة
            cairo_fixed_time = datetime.combine(day_dt, datetime.min.time()).replace(tzinfo=CAIRO_TZ)
            cairo_fixed_time = cairo_fixed_time.replace(hour=10, minute=0)
            fixed_timestamp = cairo_fixed_time.strftime("%Y-%m-%d %H:%M:%S+00")

            _open = float(row_d["open"])
            _high = float(row_d["high"])
            _low = float(row_d["low"])
            _close = float(row_d["close"])

            if _low <= _high and _open > 0:
                record_d = {
                    "timestamp": fixed_timestamp,
                    "open": _open, "high": _high, "low": _low, "close": _close,
                    "volume": int(row_d["volume"]),
                    "timeframe": "1d"
                }
                supabase.table(table_name).upsert(record_d).execute()

    except Exception as e:
        print(f"⚠️ [{label}] Sync error: {e}")

# =========================================================
# MAIN LOOP
# =========================================================
print(f"🚀 Engine Started (Robust Mode). Target: {symbol}")

sync_data(n_bars_m=300, n_bars_d=5, label="Initial Catch-up")

market_was_open = False

while True:
    try:
        now_cairo = datetime.now(CAIRO_TZ)
        is_open = is_market_open()

        if is_open:
            market_was_open = True
            sync_data(n_bars_m=20, n_bars_d=1, label="Live")
            time.sleep(UPDATE_FREQUENCY)
        else:
            if market_was_open:
                print("🌙 Market Closed. Final Sync...")
                sync_data(n_bars_m=100, n_bars_d=1, label="Final Sync")
                market_was_open = False
            time.sleep(60)

    except Exception as e:
        print(f"⚠️ Loop Error: {e}")
        time.sleep(10)
