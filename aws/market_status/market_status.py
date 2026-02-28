import time
import re
import undetected_chromedriver as uc
from selenium.webdriver.common.by import By
from webdriver_manager.chrome import ChromeDriverManager
from datetime import datetime, timezone
from supabase import create_client, Client

# ==============================================================================
# 1. SETUP
# ==============================================================================
SUPABASE_URL = "https://zlcddmhcxtxvgzxcfvxx.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpsY2RkbWhjeHR4dmd6eGNmdnh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyOTM0MTcsImV4cCI6MjA4MDg2OTQxN30.F5SxofdTfi9oBO3db1nygSXIiYEqoXgZ0OTW_Fu5Kew"
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# ==============================================================================
# 2. SETUP DRIVER
# ==============================================================================
def setup_driver():
    print("🔧 Setting up Undetected Chrome...")
    options = uc.ChromeOptions()
    # options.add_argument('--headless=new') # فعلها لما ترفعه عالسيرفر
    
    driver_path = ChromeDriverManager().install()
    driver = uc.Chrome(options=options, driver_executable_path=driver_path, version_main=144) 
    return driver

# ==============================================================================
# 3. FORMATTING (Updated to M, B, T)
# ==============================================================================
def format_large_number(num_str, multiply_by_1000=False):
    """تنسيق الأرقام (T, B, M) بالإنجليزية"""
    try:
        clean = float(re.sub(r'[^\d.]', '', num_str))
        if multiply_by_1000:
            clean *= 1000 
            
        if clean >= 1_000_000_000_000:
            return f"{clean / 1_000_000_000_000:.2f}T EGP"
        elif clean >= 1_000_000_000:
            return f"{clean / 1_000_000_000:.2f}B EGP"
        elif clean >= 1_000_000:
            return f"{clean / 1_000_000:.2f}M EGP"
        else:
            return f"{clean:,.0f} EGP"
    except:
        return num_str

# ==============================================================================
# 4. DATABASE LOGIC (Upsert) - Removed Market Status
# ==============================================================================
def save_to_supabase(market_cap, value_traded):
    try:
        now_utc = datetime.now(timezone.utc)
        today_date_str = now_utc.strftime('%Y-%m-%d') 
        
        # البيانات بدون market_status
        data_payload = {
            "market_cap": market_cap,
            "value_traded": value_traded,
            "updated_at": now_utc.isoformat(),
            "trade_date": today_date_str 
        }

        print(f"\n💾 Checking DB for date: {today_date_str}...")

        response = supabase.table("market_history").select("id").eq("trade_date", today_date_str).execute()
        
        if response.data and len(response.data) > 0:
            record_id = response.data[0]['id']
            supabase.table("market_history").update(data_payload).eq("id", record_id).execute()
            print(f"   🔄 UPDATE: Record ID {record_id} updated.")
        else:
            supabase.table("market_history").insert(data_payload).execute()
            print(f"   ✅ INSERT: New record created.")

    except Exception as e:
        print(f"   ❌ Database Error: {e}")

# ==============================================================================
# 5. MAIN LOGIC
# ==============================================================================
def fetch_market_data():
    driver = setup_driver()
    try:
        url = "https://www.egx.com.eg/ar/homepage.aspx"
        print(f"🌍 Connecting to: {url}")
        
        driver.get(url)
        print("⏳ Waiting 15s for page load...")
        time.sleep(15)
        
        market_cap_final = "0"
        value_traded_final = "0"

        # --- 1. Market Cap ---
        try:
            cap_element = driver.find_element(By.ID, "ctl00_C_HomeMarketsummary2_lclTotalMC")
            market_cap_final = format_large_number(cap_element.text)
            print(f"   💰 Market Cap: {market_cap_final}")
        except: print("   ❌ Market Cap Error")

        # --- 2. Value Traded ---
        try:
            row_element = driver.find_element(By.XPATH, "//tr[td//div[contains(text(), 'داخل المقصورة')]]")
            parts = row_element.text.split()
            numbers = [p for p in parts if re.match(r'^[\d,]+$', p)]
            
            if len(numbers) >= 3:
                value_traded_final = format_large_number(numbers[2], multiply_by_1000=True)
                print(f"   📈 Value Traded: {value_traded_final}")
        except: print("   ❌ Value Traded Error")

        # --- 3. Save ---
        if market_cap_final != "0":
            save_to_supabase(market_cap_final, value_traded_final)
        else:
            print("\n⚠️ Extraction failed.")

    except Exception as e:
        print(f"\n🚨 Error: {e}")
        
    finally:
        driver.quit()
        print("🛑 Done.")

if __name__ == "__main__":
    fetch_market_data()