import os
import time
import re
import undetected_chromedriver as uc
from selenium.webdriver.common.by import By
from webdriver_manager.chrome import ChromeDriverManager
from datetime import datetime, timezone
from supabase import create_client, Client
from dotenv import load_dotenv

# ==============================================================================
# 1. SETUP
# ==============================================================================

env_path = os.path.join(os.path.dirname(__file__), '..', '.env')

load_dotenv(dotenv_path=env_path)

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")


print(f"URL: {SUPABASE_URL}, KEY: {SUPABASE_KEY}")

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
        
        # market_status
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
            print("   [DEBUG] Starting Market Cap extraction...")
            raw_text = ""
            # Wait up to 10 seconds for the element to load and have text
            for i in range(10):
                try:
                    print(f"   [DEBUG] ID poll {i+1}/10...")
                    cap_element = driver.find_element(By.ID, "ctl00_C_HomeMarketsummary2_lclTotalMC")
                    print("   [DEBUG] Found ID element, getting text...")
                    text_content = cap_element.get_attribute("textContent")
                    visible_text = cap_element.text
                    raw_text = (text_content or visible_text).strip()
                    if raw_text:
                        print(f"   [DEBUG] Got raw_text: {raw_text}")
                        break
                except Exception as e:
                    print(f"   [DEBUG] ID poll {i+1} failed: {type(e).__name__}")
                time.sleep(1)

            # Fallback if ID strategy completely fails or is empty
            if not raw_text:
                print("   [DEBUG] ID strategy empty, trying XPath fallback...")
                mc_labels = driver.find_elements(By.XPATH, "//*[contains(text(), 'رأس المال السوق')]")
                print(f"   [DEBUG] Found {len(mc_labels)} labels via XPath")
                for idx, label in enumerate(mc_labels):
                    print(f"   [DEBUG] Processing label {idx+1}/{len(mc_labels)}...")
                    parent_text = label.find_element(By.XPATH, "..").get_attribute("textContent")
                    parts = parent_text.split()
                    # Extract the last number in the parent element
                    numbers = [p for p in parts if re.match(r'^[\d,]+(\.\d+)?$', p)]
                    if numbers:
                        raw_text = numbers[-1]
                        print(f"   [DEBUG] Found raw_text in label: {raw_text}")
                        break

            print("   [DEBUG] Formatting number...")
            market_cap_final = format_large_number(raw_text) if raw_text else "0"
            print(f"   💰 Market Cap: {market_cap_final}")
        except Exception as e: 
            print(f"   ❌ Market Cap Error: {e}")

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