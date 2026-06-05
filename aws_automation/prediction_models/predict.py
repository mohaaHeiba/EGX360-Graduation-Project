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
import time

warnings.filterwarnings('ignore')

# ==========================================
# 1. Configuration
# ==========================================
env_path = os.path.join(os.path.dirname(__file__), '..', '.env')
SERVICE_ACCOUNT_PATH = os.path.join(os.path.dirname(__file__), '..', 'service_account.json')

load_dotenv(dotenv_path=env_path)

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY") # تأكد إنه Service Role Key
MASSIVE_API_KEY = os.getenv("MASSIVE_API_KEY")
FINNHUB_API_KEY = os.getenv("FINNHUB_API_KEY")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# ==========================================
# 1.5. Robust Network Fetcher
# ==========================================
def fetch_with_retry(url, params=None, timeout=10, max_retries=3):
    last_err = None
    for attempt in range(max_retries):
        try:
            r = requests.get(url, params=params, timeout=timeout)
            return r
        except Exception as e:
            last_err = e
            print(f"   ⚠️ Network glitch. Retrying {attempt+1}/{max_retries} in 3 seconds...")
            time.sleep(3)
    raise last_err

if not firebase_admin._apps:
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    firebase_admin.initialize_app(cred)

MODEL_DIR = "/home/heiba/EGX360-Graduation-Project/aws_automation/prediction_models"
GENERAL_MODEL_PATH = os.path.join(MODEL_DIR, "egx360_stack_model.pkl")
GENERAL_SCALER_PATH = os.path.join(MODEL_DIR, "egx360_scaler.pkl")

# ==========================================
# 2. Advanced Feature Engineering
# ==========================================
def fetch_macro_data():
    print("🌍 Fetching Global Macro Data (Gold & USD)...")
    try:
        gold = yf.Ticker("GC=F").history(period="10d", interval="1d")
        usd = yf.Ticker("EGP=X").history(period="10d", interval="1d")
        return gold, usd
    except Exception as e:
        print(f"⚠️ Macro Fetch Failed: {e}")
        return None, None

def calculate_technical_features(df, gold_data, usd_data):
    if gold_data is not None and not gold_data.empty and usd_data is not None and not usd_data.empty:
        usd_rate = float(usd_data['Close'].iloc[-1])
        gold_usd = float(gold_data['Close'].iloc[-1])
        usd_vel = float((usd_data['Close'].pct_change().diff()).iloc[-1])
        gold_ret = float(np.log(gold_data['Close'] / gold_data['Close'].shift(1)).iloc[-1])
        gold_vel_val = float((gold_data['Close'].pct_change().diff()).iloc[-1])
        gold_lag = float(np.log(gold_data['Close'] / gold_data['Close'].shift(1)).iloc[-2])
    else:
        usd_rate, gold_usd, usd_vel, gold_ret, gold_vel_val, gold_lag = 50.7, 2300.0, 0.0, 0.0, 0.0, 0.0

    # 1. Macro Mapping
    df['usd_egp_rate'] = usd_rate
    df['gold_egp'] = gold_usd * usd_rate
    df['gold_usd'] = gold_usd
    df['close_usd'] = df['close'] / (usd_rate + 1e-9)

    # 2. Basic Technicals
    df['log_ret'] = np.log((df['close'] + 1e-6) / (df['close'].shift(1) + 1e-6))
    df['price_velocity'] = df['log_ret'].diff()
    df['log_ret_lag1'] = df['log_ret'].shift(1)
    df['price_velocity_usd'] = usd_vel
    df['log_ret_usd'] = np.log(usd_rate / (usd_rate - usd_vel + 1e-9))
    df['log_ret_usd_lag1'] = df['log_ret_usd']
    df['gold_log_ret'] = gold_ret
    df['gold_velocity'] = gold_vel_val
    df['gold_ret_lag1'] = gold_lag

    # 3. Moving Averages & Volume
    for period in [9, 10, 20, 21, 31, 50]:
        df[f'EMA_{period}'] = df['close'].ewm(span=period).mean()
        df[f'dist_EMA_{period}'] = (df['close'] - df[f'EMA_{period}']) / (df[f'EMA_{period}'] + 1e-9)

    df['Volume_SMA_50'] = df['volume'].rolling(window=50).mean()
    df['RVOL_50'] = (df['volume'] / (df['Volume_SMA_50'] + 1e-9)).clip(upper=5.0)
    
    # 4. Momentum & Volatility
    delta = df['close'].diff()
    gain, loss = (delta.where(delta > 0, 0)).rolling(14).mean(), (-delta.where(delta < 0, 0)).rolling(14).mean()
    df['RSI'] = 100 - (100 / (1 + gain/(loss + 1e-9)))
    df['RSI_diff'], df['RSI_lag1'] = df['RSI'].diff(), df['RSI'].shift(1)
    
    macd = df['close'].ewm(span=12).mean() - df['close'].ewm(span=26).mean()
    df['MACD_Hist'] = macd - macd.ewm(span=9).mean()
    
    tr = pd.concat([df['high']-df['low'], abs(df['high']-df['close'].shift()), abs(df['low']-df['close'].shift())], axis=1).max(axis=1)
    df['ATR_pct'] = tr.rolling(14).mean() / (df['close'] + 1e-9)
    df['BB_Width'] = (df['close'].rolling(20).std() * 4) / (df['close'].rolling(20).mean() + 1e-9)

    # 5. Composite Indicators
    low_14, high_14 = df['low'].rolling(14).min(), df['high'].rolling(14).max()
    stoch_k = 100 * ((df['close'] - low_14) / (high_14 - low_14 + 1e-9))
    df['Composite_Momentum'] = (df['RSI'] + stoch_k) / 2

    # 6. Sensors & Misc
    df['below_EMA9'] = (df['close'] < df['EMA_9']).astype(int)
    df['EMA_Spread'] = (df['EMA_10'] - df['EMA_20']) / (df['EMA_20'] + 1e-9)
    df['EMA_Cross_Signal'] = (df['EMA_10'] > df['EMA_20']).astype(int)
    df['Interest_Rate'], df['IR_Change'], df['USD_Shock'] = 19.0, 0.0, (1.0 if usd_vel > 0.02 else 0.0)
    df['Rate_Hike_Flag'], df['Rate_Drop_Flag'] = 0.0, 0.0
    df['noise'] = df['close'] - df['EMA_10']
    df['day_sin'] = np.sin(2 * np.pi * df.index.dayofweek / 7)
    df['day_cos'] = np.cos(2 * np.pi * df.index.dayofweek / 7)

    df = df.replace([np.inf, -np.inf], np.nan)
    return df.ffill().bfill().fillna(0)

# ==========================================
# 3. Core Engine (Prediction & Mapping)
# ==========================================
def predict_and_generate_payload(df, symbol, is_finnhub=False):
    try:
        model = joblib.load(GENERAL_MODEL_PATH)
        scaler = joblib.load(GENERAL_SCALER_PATH)
        
        expected_features = [
            'log_ret', 'price_velocity', 'log_ret_usd', 'price_velocity_usd', 'log_ret_usd_lag1', 
            'gold_log_ret', 'gold_velocity', 'gold_ret_lag1', 'Volume_SMA_50', 'RVOL_50', 
            'day_sin', 'day_cos', 'dist_EMA_9', 'dist_EMA_10', 
            'dist_EMA_20', 'dist_EMA_21', 'dist_EMA_31', 
            'dist_EMA_50', 'below_EMA9', 'EMA_Spread', 'EMA_Cross_Signal', 
            'RSI', 'RSI_diff', 'MACD_Hist', 'ATR_pct', 'BB_Width', 'log_ret_lag1', 
            'RSI_lag1', 'USD_Shock', 'Rate_Hike_Flag', 'Rate_Drop_Flag', 'Composite_Momentum', 
            'gold_usd', 'Interest_Rate', 'IR_Change'
        ]

        for col in expected_features:
            if col not in df.columns: df[col] = 0.0

        # Run Prediction
        latest_row = df[expected_features].iloc[-1:].values
        X_scaled = scaler.transform(latest_row)
        prob = float(model.predict_proba(X_scaled)[0][1])
        ml_signal = "UP" if prob > 0.5 else "DOWN"
        
        last_day = df.iloc[-1]
        
        # ⚠️ Logic Fix: UI Statuses & Consensus
        mom = float(last_day['Composite_Momentum'])
        momentum_status = "High" if mom > 70 else ("Low" if mom < 30 else "Normal")
        
        macd_val = float(last_day['MACD_Hist'])
        macd_status = "Bullish" if macd_val > 0 else "Bearish"
        
        # --- 🔥 Real-Time Reality Check (V5 - Pure Contradiction Filter) ---
        # Step 1: Calculate the instantaneous percentage change
        current_close = float(last_day['close'])
        
        if is_finnhub and FINNHUB_API_KEY:
            try:
                r = fetch_with_retry(f"https://finnhub.io/api/v1/quote?symbol={symbol}&token={FINNHUB_API_KEY}", timeout=10)
                data = r.json()
                actual_pct_change = float(data.get('dp', 0.0))
                if data.get('c'):
                    current_close = float(data['c']) # Update close to real-time price
            except Exception as e:
                print(f"⚠️ Finnhub Real-time Fetch Error for {symbol}: {e}")
                prev_close = float(df.iloc[-2]['close']) if len(df) > 1 else current_close
                actual_pct_change = ((current_close - prev_close) / prev_close) * 100 if prev_close else 0.0
        else:
            prev_close = float(df.iloc[-2]['close']) if len(df) > 1 else current_close
            actual_pct_change = ((current_close - prev_close) / prev_close) * 100 if prev_close else 0.0
            
        # Step 2: Smart Contradiction Filter (Only intervene if ML is WRONG)
        final_prob = prob # Start with 100% pure ML probability
        
        # Case 1: Model is optimistic (>= 50%), but stock is crashing (False Bullish)
        if prob >= 0.5 and actual_pct_change <= -1.5:
            penalty = actual_pct_change * 0.25 # e.g. -3% * 0.25 = -0.75
            penalty = max(-0.80, penalty) # Cap penalty at -80%
            final_prob += penalty
            
        # Case 2: Model is pessimistic (< 50%), but stock is pumping (False Bearish)
        elif prob < 0.5 and actual_pct_change >= 1.5:
            boost = actual_pct_change * 0.25 # e.g. 3% * 0.25 = +0.75
            boost = min(0.80, boost) # Cap boost at +80%
            final_prob += boost
            
        # Step 3: Finalize and Cap (Prevent absolute 0% or 100% for realism)
        final_prob = max(0.02, min(0.98, final_prob))
        up_pct = round(final_prob * 100, 1)
        
        # Override original ML probability and signal to match the truth
        prob = final_prob
        ml_signal = "UP" if prob > 0.5 else "DOWN"
        
        # Step 4: Define the Overall Trend
        if up_pct >= 60.0:
            overall_trend = "BULLISH"
        elif up_pct <= 40.0:
            overall_trend = "BEARISH"
        else:
            overall_trend = "NEUTRAL"
        
        payload = {
            "symbol": symbol.upper(),
            "prediction_date": str(df.index[-1].date()),
            "close_price": current_close,
            "probability": prob,
            "ml_signal": ml_signal,
            "model_version": "EGX360_v8.5",
            "open_price": float(last_day.get('open', last_day['close'])),
            "high_price": float(last_day.get('high', last_day['close'])),
            "low_price": float(last_day.get('low', last_day['close'])),
            "volume": float(last_day['volume']),
            "usd_egp_rate": float(last_day['usd_egp_rate']),
            "gold_egp": float(last_day['gold_egp']),
            "close_usd": float(last_day['close_usd']),
            "momentum_status": momentum_status,
            "macd_status": macd_status,
            "volatility_status": "High" if last_day['ATR_pct'] > 0.015 else "Low",
            "consensus_up_pct": up_pct,
            "consensus_down_pct": round(100.0 - up_pct, 1),
            "overall_trend": overall_trend,
            "noise": float(last_day['noise'])
        }

        # Auto-map the 41 Technical features (Convert to Lowercase for Postgres)
        for col in expected_features:
            payload[col.lower()] = float(last_day[col])
            
        # Map raw EMAs that the DB expects but ML doesn't use directly
        for ema in [9, 10, 20, 21, 31, 50]:
            payload[f'ema_{ema}'] = float(last_day[f'EMA_{ema}'])
            
        return payload
    except Exception as e:
        print(f"❌ Mapping Error for {symbol}: {e}")
        return None

def send_prediction_fcm(token, symbol, trend, prob):
    if not token: return
    try:
        title = f"🤖 AI Prediction Update: {symbol}"
        trend_emoji = "🚀" if trend == "BULLISH" else ("📉" if trend == "BEARISH" else "⚖️")
        body = f"EGX360 AI changed {symbol} trend to {trend} {trend_emoji} with {prob:.1%} confidence."
        message = messaging.Message(
            notification=messaging.Notification(title=title, body=body),
            token=token,
            data={'type': 'prediction_alert', 'symbol': symbol}
        )
        messaging.send(message)
        print(f"   🔔 Notification sent for {symbol}")
    except Exception as e:
        print(f"   ❌ FCM Error for {symbol}: {e}")

def notify_watchers(symbol, trend, prob):
    try:
        res = supabase.table("user_watchlist").select("profiles(fcm_token)").eq("stock_symbol", symbol).execute()
        if res.data:
            for item in res.data:
                # Handle case where profiles could be a list (due to foreign key setup) or a dictionary
                profiles = item.get('profiles')
                if not profiles:
                    continue
                if isinstance(profiles, list) and len(profiles) > 0:
                    token = profiles[0].get('fcm_token')
                elif isinstance(profiles, dict):
                    token = profiles.get('fcm_token')
                else:
                    token = None
                    
                if token:
                    send_prediction_fcm(token, symbol, trend, prob)
    except Exception as e:
        print(f"⚠️ Error notifying watchers for {symbol}: {e}")

def push_to_supabase(payload):
    try:
        supabase.table("ai_predictions").upsert(payload, on_conflict="symbol,prediction_date").execute()
        print(f"✅ Success: {payload['symbol']} | Prob: {payload['probability']:.1%} | Trend: {payload['overall_trend']}")
        notify_watchers(payload['symbol'], payload['overall_trend'], payload['probability'])
    except Exception as e:
        print(f"❌ DB Error: {e}")

# ==========================================
# 4. Main Pipeline Execution
# ==========================================
def process_symbol(symbol, table, gold, usd, is_crypto=False, is_finnhub=False):
    print(f"🔄 Processing {symbol}...")
    try:
        if is_crypto:
            url = "https://api.binance.com/api/v3/klines"
            r = fetch_with_retry(url, params={"symbol": f"{symbol}USDT", "interval": "1d", "limit": 100})
            data = r.json()
            if not data or 'code' in data: return
            df = pd.DataFrame(data, columns=['ts','open','high','low','close','volume','ct','qav','not','tbbav','tbqav','i'])
            df['timestamp'] = pd.to_datetime(df['ts'], unit='ms')
            df.set_index('timestamp', inplace=True)
            for c in ['open','high','low','close','volume']: df[c] = df[c].astype(float)
        elif is_finnhub:
            import datetime
            to_dt = datetime.datetime.now()
            from_dt = to_dt - datetime.timedelta(days=150)
            url = f"https://api.massive.com/v2/aggs/ticker/{symbol}/range/1/day/{from_dt.strftime('%Y-%m-%d')}/{to_dt.strftime('%Y-%m-%d')}"
            r = fetch_with_retry(url, params={"apiKey": MASSIVE_API_KEY})
            data = r.json()
            if 'results' not in data or not data['results']: return
            df = pd.DataFrame(data['results'])
            df.rename(columns={'o': 'open', 'h': 'high', 'l': 'low', 'c': 'close', 'v': 'volume', 't': 'timestamp'}, inplace=True)
            df['timestamp'] = pd.to_datetime(df['timestamp'], unit='ms')
            df.set_index('timestamp', inplace=True)
            for c in ['open','high','low','close','volume']: df[c] = df[c].astype(float)
        else:
            res = supabase.table(table).select("*").eq("timeframe", "1d").order("timestamp", desc=True).limit(100).execute()
            if not res.data: return
            df = pd.DataFrame(res.data)
            df['timestamp'] = pd.to_datetime(df['timestamp'])
            df.sort_values('timestamp', inplace=True)
            df.set_index('timestamp', inplace=True)

        processed_df = calculate_technical_features(df, gold, usd)
        payload = predict_and_generate_payload(processed_df, symbol, is_finnhub)
        if payload: push_to_supabase(payload)
    except Exception as e:
        print(f"⚠️ Process Failed for {symbol}: {e}")

if __name__ == "__main__":
    print("🚀 EGX360 AI Engine Started...")
    stocks = supabase.table("stocks").select("symbol, sector, candle_table_name").execute()
    if stocks.data:
        gold_data, usd_data = fetch_macro_data()
        for s in stocks.data:
            is_crypto = (s['sector'] == 'Crypto' or s['candle_table_name'] == 'API')
            is_finnhub = (s['candle_table_name'] == 'API_FINNHUB')
            process_symbol(s['symbol'], s['candle_table_name'], gold_data, usd_data, is_crypto, is_finnhub)
            
            if is_finnhub:
                time.sleep(13) # Massive API rate limit (5 calls per minute)
            else:
                time.sleep(1) # Safe delay for Supabase and Binance
    print("\n🏁 Pipeline Completed!")