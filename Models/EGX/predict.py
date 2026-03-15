import pandas as pd
import numpy as np
import joblib
import yfinance as yf
from supabase import create_client, Client
import warnings
import os

# إخفاء التحذيرات المزعجة في الـ Terminal
warnings.filterwarnings('ignore')

# ==========================================
# 1. إعدادات النظام (Configuration)
# ==========================================
URL = "https://zlcddmhcxtxvgzxcfvxx.supabase.co"
# ⚠️ تأكد إن ده الـ Service Role Key عشان يقدر يكتب في الـ Database من غير مشاكل RLS
KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpsY2RkbWhjeHR4dmd6eGNmdnh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyOTM0MTcsImV4cCI6MjA4MDg2OTQxN30.F5SxofdTfi9oBO3db1nygSXIiYEqoXgZ0OTW_Fu5Kew"
supabase: Client = create_client(URL, KEY)

# مسار الموديل العام (Fallback)
GENERAL_MODEL_PATH = "EGX360_Final_Model_v8.pkl"
GENERAL_SCALER_PATH = "EGX360_Scaler_v8.pkl"

# ==========================================
# 2. الدوال المساعدة (Helper Functions)
# ==========================================
def fetch_macro_data():
    """جلب بيانات الذهب والدولار مرة واحدة لتوفير وقت الـ Loop"""
    print("🌍 Fetching Global Macro Data (Gold & USD)...")
    try:
        gold = yf.download("GC=F", period="10d", interval="1d", progress=False)
        usd = yf.download("EGP=X", period="10d", interval="1d", progress=False)
        return gold, usd
    except Exception as e:
        print(f"⚠️ Failed to fetch macro data: {e}")
        return None, None

def calculate_technical_features(df, gold_data, usd_data):
    """محرك الحسابات الكمية (Quant Engine) لتجهيز الـ Features"""
    # أ. معالجة الماكرو بحماية ضد أخطاء yfinance
    try:
        if gold_data is not None and not gold_data.empty and usd_data is not None and not usd_data.empty:
            gold_ret = float(np.log(gold_data['Close'] / gold_data['Close'].shift(1)).iloc[-1])
            gold_vel = float((gold_data['Close'].pct_change().diff()).iloc[-1])
            gold_lag = float(np.log(gold_data['Close'] / gold_data['Close'].shift(1)).iloc[-2])
            usd_ret = float(np.log(usd_data['Close'] / usd_data['Close'].shift(1)).iloc[-1])
            usd_vel = float((usd_data['Close'].pct_change().diff()).iloc[-1])
        else:
            raise ValueError("Empty data from yfinance")
    except Exception as e:
        # لو حصل أي خطأ في الداتا، هنحط أصفار عشان الموديل يكمل شغل
        gold_ret = gold_vel = gold_lag = usd_ret = usd_vel = 0.0

    # ب. معالجة الفنيات
    df['log_ret'] = np.log(df['close'] / df['close'].shift(1))
    df['price_velocity'] = df['log_ret'].diff()
    
    for period in [9, 21, 50]:
        ema_col = f'EMA_{period}'
        df[ema_col] = df['close'].ewm(span=period).mean()
        df[f'dist_EMA_{period}'] = (df['close'] - df[ema_col]) / (df[ema_col] + 1e-9)

    delta = df['close'].diff()
    gain = delta.where(delta > 0, 0).rolling(14).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(14).mean()
    df['RSI'] = 100 - (100 / (1 + gain/(loss + 1e-9)))
    
    macd = df['close'].ewm(span=12).mean() - df['close'].ewm(span=26).mean()
    df['MACD_Hist'] = macd - macd.ewm(span=9).mean()
    
    df['day_sin'] = np.sin(2 * np.pi * df.index.dayofweek / 7)
    df['day_cos'] = np.cos(2 * np.pi * df.index.dayofweek / 7)

    # ج. دمج المتغيرات
    df['log_ret_usd'] = usd_ret
    df['price_velocity_usd'] = usd_vel
    df['gold_log_ret'] = gold_ret
    df['gold_velocity'] = gold_vel
    df['gold_ret_lag1'] = gold_lag
    df['RVOL_50'] = 1.0 
    df['Interest_Rate'] = 19.0 
    df['IR_Change'] = 0.0

    features = [
        'log_ret', 'log_ret_usd', 'price_velocity', 'price_velocity_usd', 'RVOL_50', 
        'day_sin', 'day_cos', 'dist_EMA_9', 'dist_EMA_21', 'dist_EMA_50', 
        'RSI', 'MACD_Hist', 'Interest_Rate', 'IR_Change',
        'gold_log_ret', 'gold_velocity', 'gold_ret_lag1'
    ]
    
    return df[features].tail(1)
def push_to_db(symbol, close_price, prob):
    """رفع النتيجة النهائية لقاعدة البيانات"""
    data = {
        "symbol": symbol.upper(),
        "close_price": float(close_price),
        "probability": float(prob)
    }
    try:
        supabase.table("ai_predictions").insert(data).execute()
        print(f"   ✅ DB Push Success | Prob: {prob:.2%} | Price: {close_price:,.2f}")
    except Exception as e:
        print(f"   ❌ DB Push Failed: {e}")

# ==========================================
# 3. محركات المعالجة (Processing Engines)
# ==========================================
def predict_asset(df, symbol):
    """تحميل الموديل المناسب وتوقع الاتجاه"""
    specific_model = f"{symbol}_Model_v8.pkl"
    specific_scaler = f"{symbol}_Scaler_v8.pkl"
    
    if os.path.exists(specific_model) and os.path.exists(specific_scaler):
        print(f"   ✔️ Using SPECIFIC model for {symbol}")
        model = joblib.load(specific_model)
        scaler = joblib.load(specific_scaler)
    else:
        print(f"   ⚠️ Specific model missing. Using GENERAL Fallback model.")
        try:
            model = joblib.load(GENERAL_MODEL_PATH)
            scaler = joblib.load(GENERAL_SCALER_PATH)
        except Exception as e:
            print(f"   ❌ CRITICAL: General Model missing! {e}")
            return None
            
    try:
        # إرسال DataFrame كامل للمحافظة على أسامي الـ Features
        scaled_data = scaler.transform(df)
        prob = model.predict_proba(scaled_data)[0][1]
        return prob
    except Exception as e:
        print(f"   ❌ Prediction Error: {e}")
        return None

def process_egx(stock_info, gold, usd):
    """معالجة الأسهم المصرية والمؤشرات من Supabase"""
    symbol = stock_info['symbol']
    table_name = stock_info['candle_table_name']
    print(f"\n🔄 [EGX] Processing {symbol}...")

    # سحب الداتا من Supabase
    response = supabase.table(table_name).select("*").eq("timeframe", "1d").order("timestamp", desc=True).limit(100).execute()
    if not response.data:
        print(f"   ❌ No 1D data found in {table_name}")
        return

    df = pd.DataFrame(response.data)
    df['timestamp'] = pd.to_datetime(df['timestamp'])
    df = df.sort_values('timestamp')
    df.set_index('timestamp', inplace=True)
    
    close_price = float(df['close'].iloc[-1])
    input_data = calculate_technical_features(df, gold, usd)
    
    prob = predict_asset(input_data, symbol)
    if prob is not None:
        push_to_db(symbol, close_price, prob)

def process_crypto(stock_info, gold, usd):
    """معالجة العملات الرقمية من Yahoo Finance"""
    symbol = stock_info['symbol']
    yf_symbol = f"{symbol}-USD"
    print(f"\n🔄 [CRYPTO] Processing {symbol} via yfinance...")

    try:
        df = yf.download(yf_symbol, period="100d", interval="1d", progress=False)
        if df.empty:
            print(f"   ❌ No data found for {yf_symbol}")
            return
            
        # توحيد أسماء الأعمدة لتطابق توقعات الموديل
        df.rename(columns={'Open': 'open', 'High': 'high', 'Low': 'low', 'Close': 'close', 'Volume': 'volume'}, inplace=True)
        # إزالة الـ MultiIndex لو yfinance رجعه
        if isinstance(df.columns, pd.MultiIndex):
            df.columns = df.columns.get_level_values(0)
            
    except Exception as e:
        print(f"   ❌ Failed to fetch Crypto data: {e}")
        return

    close_price = float(df['close'].iloc[-1])
    input_data = calculate_technical_features(df, gold, usd)
    
    prob = predict_asset(input_data, symbol)
    if prob is not None:
        push_to_db(symbol, close_price, prob)

# ==========================================
# 4. نقطة الانطلاق (Main Pipeline)
# ==========================================
if __name__ == "__main__":
    print("🚀 EGX360 AI Engine Started...\n" + "="*40)
    
    # سحب كل الرموز من الداتابيز
    response = supabase.table("stocks").select("symbol, sector, candle_table_name").execute()
    stocks = response.data
    
    if stocks:
        gold_data, usd_data = fetch_macro_data()
        
        for stock in stocks:
            sector = stock.get('sector', '')
            table_name = stock.get('candle_table_name', '')
            
            if sector == 'Crypto' or table_name == 'API':
                process_crypto(stock, gold_data, usd_data)
            else:
                process_egx(stock, gold_data, usd_data)
                
    else:
        print("❌ Could not fetch symbols from database. Check connection.")
        
    print("\n" + "="*40 + "\n🏁 AI Pipeline Completed Successfully!")