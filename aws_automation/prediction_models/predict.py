from dotenv import load_dotenv
from firebase_admin import credentials, messaging
import firebase_admin
import pandas as pd
import numpy as np
import joblib
import yfinance as yf
from supabase import create_client, Client
import warnings
import os
import requests  

warnings.filterwarnings('ignore')

# ==========================================
# 1. Configuration
# ==========================================

env_path = os.path.join(os.path.dirname(__file__), '..', '.env')

SERVICE_ACCOUNT_PATH = os.path.join(os.path.dirname(__file__), '..', 'service_account.json')

load_dotenv(dotenv_path=env_path)

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

if not firebase_admin._apps:
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    firebase_admin.initialize_app(cred)


GENERAL_MODEL_PATH = "EGX360_Final_Model_v8.pkl"
GENERAL_SCALER_PATH = "EGX360_Scaler_v8.pkl"


# ==========================================
# 2. Helper Functions
# ==========================================
def fetch_macro_data():
    print("🌍 Fetching Global Macro Data (Gold & USD)...")
    try:
        gold = yf.Ticker("GC=F").history(period="10d", interval="1d")
        usd = yf.Ticker("EGP=X").history(period="10d", interval="1d")
        return gold, usd
    except Exception as e:
        print(f"⚠️ Failed to fetch macro data: {e}")
        return None, None

def calculate_technical_features(df, gold_data, usd_data):
    if gold_data is not None and not gold_data.empty and usd_data is not None and not usd_data.empty:
        gold_ret = float(np.log(gold_data['Close'] / gold_data['Close'].shift(1)).iloc[-1])
        gold_vel = float((gold_data['Close'].pct_change().diff()).iloc[-1])
        gold_lag = float(np.log(gold_data['Close'] / gold_data['Close'].shift(1)).iloc[-2])
        usd_ret = float(np.log(usd_data['Close'] / usd_data['Close'].shift(1)).iloc[-1])
        usd_vel = float((usd_data['Close'].pct_change().diff()).iloc[-1])
    else:
        gold_ret = gold_vel = gold_lag = usd_ret = usd_vel = 0.0

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
# 3. Processing Engines
# ==========================================
def predict_asset(df, symbol):
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
        scaled_data = scaler.transform(df)
        prob = model.predict_proba(scaled_data)[0][1]
        return prob
    except Exception as e:
        print(f"   ❌ Prediction Error: {e}")
        return None

def send_prediction_alert(symbol, current_price, prob):
    HIGH_THRESHOLD = 0.80  
    LOW_THRESHOLD = 0.20   

    if prob >= HIGH_THRESHOLD:
        display_title = f"🚀 Strong Signal: {symbol}"
        display_body = f"Model predicts an uptrend! Current Price: {current_price:,.2f}, Probability: {prob:.0%}"
        icon = "🚀"
    elif prob <= LOW_THRESHOLD:
        display_title = f"⚠️ Downtrend Warning: {symbol}"
        display_body = f"High probability of a downtrend. Current Price: {current_price:,.2f}, Uptrend Probability: {prob:.0%}"
        icon = "⚠️"
    else:
        return 

    try:
        res = supabase.table("user_watchlist").select("profiles(fcm_token)").eq("stock_symbol", symbol).execute()
        tokens = list(set([i['profiles']['fcm_token'] for i in res.data if i.get('profiles') and i['profiles'].get('fcm_token')]))
        
        if not tokens: 
            return

        message = messaging.MulticastMessage(
            notification=messaging.Notification(title=display_title, body=display_body),
            android=messaging.AndroidConfig(
                priority='high', 
                notification=messaging.AndroidNotification(channel_id='ai_predictions_alerts')
            ),
            data={'type': 'ai_alert', 'symbol': symbol},
            tokens=tokens
        )
        messaging.send_each_for_multicast(message)
        print(f"   🔔 Alert Sent for {symbol} to {len(tokens)} users: {icon} {prob:.0%}")
        
    except Exception as e:
        print(f"   ❌ FCM Alert Error for {symbol}: {e}")

def process_egx(stock_info, gold, usd):
    symbol = stock_info['symbol']
    table_name = stock_info['candle_table_name']
    print(f"\n🔄 [EGX] Processing {symbol}...")

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
        send_prediction_alert(symbol, close_price, prob)

def process_crypto(stock_info, gold, usd):
    symbol = stock_info['symbol']
    binance_symbol = f"{symbol}USDT"
    print(f"\n🔄 [CRYPTO] Processing {symbol} via Binance API...")

    try:
        url = "https://api.binance.com/api/v3/klines"
        params = {
            "symbol": binance_symbol,
            "interval": "1d",
            "limit": 100
        }
        response = requests.get(url, params=params)
        data = response.json()
        
        if not data or isinstance(data, dict):
            print(f"   ❌ No data found for {binance_symbol} on Binance")
            return
            
        df = pd.DataFrame(data, columns=[
            'timestamp', 'open', 'high', 'low', 'close', 'volume',
            'close_time', 'quote_asset_volume', 'number_of_trades',
            'taker_buy_base_asset_volume', 'taker_buy_quote_asset_volume', 'ignore'
        ])
        
        df['timestamp'] = pd.to_datetime(df['timestamp'], unit='ms')
        df.set_index('timestamp', inplace=True)
        
        for col in ['open', 'high', 'low', 'close', 'volume']:
            df[col] = df[col].astype(float)
            
    except Exception as e:
        print(f"   ❌ Failed to fetch Crypto data from Binance: {e}")
        return

    close_price = float(df['close'].iloc[-1])
    input_data = calculate_technical_features(df, gold, usd)
    
    prob = predict_asset(input_data, symbol)
    if prob is not None:
        push_to_db(symbol, close_price, prob)
        send_prediction_alert(symbol, close_price, prob)

# ==========================================
# 4. Main Pipeline
# ==========================================
if __name__ == "__main__":
    print("🚀 EGX360 AI Engine Started...\n" + "="*40)
    
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