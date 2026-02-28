from supabase import create_client

# --- Supabase Config ---
SUPABASE_URL = "https://zlcddmhcxtxvgzxcfvxx.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpsY2RkbWhjeHR4dmd6eGNmdnh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyOTM0MTcsImV4cCI6MjA4MDg2OTQxN30.F5SxofdTfi9oBO3db1nygSXIiYEqoXgZ0OTW_Fu5Kew"

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)  

# --- TradingView Login ---
TV_USERNAME =None #"mohameHeiba"
TV_PASSWORD =None #"Karm88998899"

# --- Common Settings ---
UPDATE_INTERVAL = 15  # seconds
MARKET_OPEN_HOUR = 10
MARKET_CLOSE_HOUR = 15
MARKET_CLOSE_MIN = 30
