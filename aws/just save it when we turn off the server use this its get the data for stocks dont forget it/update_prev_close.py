import os
import time
from datetime import datetime, timedelta
import pytz
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

def get_cairo_now():
    return datetime.now(pytz.timezone('Africa/Cairo'))

# --- Supabase Config ---
env_path = os.path.join(os.path.dirname(__file__), '..', '.env')

load_dotenv(dotenv_path=env_path)

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")


# print(f"URL: {SUPABASE_URL}, KEY: {SUPABASE_KEY}")


supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def update_prev_closes():
    now = get_cairo_now()
    today_start = now.replace(hour=0, minute=0, second=0, microsecond=0).isoformat()
    
    print(f"🚀 Starting prev_close update process...")
    print(f"📅 Today's Date (Cairo): {now.strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"🔍 Looking for the last candle before: {today_start}")

    try:
        response = supabase.table('stocks').select("id, symbol, candle_table_name").execute()
        stocks = response.data

        if not stocks:
            print("⚠️ No stocks found in 'stocks' table.")
            return

        for stock in stocks:
            stock_id = stock['id']
            symbol = stock['symbol']
            table_name = stock['candle_table_name']

            if table_name == 'API':
                continue

            print(f"🔍 Processing {symbol}...")

            try:
                candle_res = supabase.table(table_name)\
                    .select("close, timestamp")\
                    .lt("timestamp", today_start)\
                    .order("timestamp", desc=True)\
                    .limit(1)\
                    .execute()

                if candle_res.data and len(candle_res.data) > 0:
                    last_close_price = candle_res.data[0]['close']
                    last_date = candle_res.data[0]['timestamp']

                    supabase.table('stocks').update({
                        "prev_close": last_close_price
                    }).eq("id", stock_id).execute()

                    print(f"   ✅ Updated {symbol}: prev_close = {last_close_price} (From: {last_date})")
                else:
                    print(f"   ⚠️ No previous candle data found for {symbol} before today.")

            except Exception as e:
                print(f"   ❌ Error updating {symbol}: {str(e)}")
            
            time.sleep(0.1)

        print("\n🎉 All updates finished successfully!")

    except Exception as e:
        print(f"❌ Critical Error: {str(e)}")

if __name__ == "__main__":
    update_prev_closes()