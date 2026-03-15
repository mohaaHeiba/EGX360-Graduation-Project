import pandas as pd
import numpy as np
import joblib
import plotly.graph_objects as go
import yfinance as yf
from supabase import create_client, Client
import warnings

warnings.filterwarnings('ignore')

# --- Supabase Config ---
URL = "https://zlcddmhcxtxvgzxcfvxx.supabase.co"
KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpsY2RkbWhjeHR4dmd6eGNmdnh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyOTM0MTcsImV4cCI6MjA4MDg2OTQxN30.F5SxofdTfi9oBO3db1nygSXIiYEqoXgZ0OTW_Fu5Kew"
supabase: Client = create_client(URL, KEY)

# Load Model & Scaler
model = joblib.load("EGX360_Final_Model_v8.pkl")
scaler = joblib.load("EGX360_Scaler_v8.pkl")

def get_signal_label(prob):
    if prob >= 0.85: return "Strong Buy 🚀", "green"
    elif prob >= 0.60: return "Buy ✅", "lightgreen"
    elif prob > 0.40: return "Neutral ⚖️", "gray"
    elif prob > 0.15: return "Sell ⚠️", "orange"
    else: return "Strong Sell 🛑", "red"

def fetch_and_predict(symbol="EGX30"):
    # 1. Fetch 1D Data
    print(f"🔄 Fetching DAILY (1D) data for {symbol}...")
    response = supabase.table(f"{symbol.lower()}_candles") \
        .select("*") \
        .eq("timeframe", "1d") \
        .order("timestamp", desc=True) \
        .limit(100).execute()
    
    if not response.data:
        print("❌ No data found!")
        return

    df = pd.DataFrame(response.data)
    df['timestamp'] = pd.to_datetime(df['timestamp'])
    df = df.sort_values('timestamp')
    df.set_index('timestamp', inplace=True)

    # 2. Macro Data Integration
    gold_data = yf.download("GC=F", period="10d", interval="1d", progress=False)
    usd_data = yf.download("EGP=X", period="10d", interval="1d", progress=False)
    
    gold_ret = np.log(gold_data['Close'] / gold_data['Close'].shift(1)).iloc[-1].values[0]
    gold_vel = (gold_data['Close'].pct_change().diff()).iloc[-1].values[0]
    gold_lag = np.log(gold_data['Close'] / gold_data['Close'].shift(1)).iloc[-2].values[0]
    usd_ret = np.log(usd_data['Close'] / usd_data['Close'].shift(1)).iloc[-1].values[0]
    usd_vel = (usd_data['Close'].pct_change().diff()).iloc[-1].values[0]

    # 3. Technical Engineering
    df['log_ret'] = np.log(df['close'] / df['close'].shift(1))
    df['price_velocity'] = df['log_ret'].diff()
    
    for period in [9, 21, 50]:
        df[f'EMA_{period}'] = df['close'].ewm(span=period).mean()
        df[f'dist_EMA_{period}'] = (df['close'] - df[f'EMA_{period}']) / (df[f'EMA_{period}'] + 1e-9)

    delta = df['close'].diff()
    gain = delta.where(delta > 0, 0).rolling(14).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(14).mean()
    df['RSI'] = 100 - (100 / (1 + gain/(loss + 1e-9)))
    
    macd = df['close'].ewm(span=12).mean() - df['close'].ewm(span=26).mean()
    df['MACD_Hist'] = macd - macd.ewm(span=9).mean()
    
    df['day_sin'] = np.sin(2 * np.pi * df.index.dayofweek / 7)
    df['day_cos'] = np.cos(2 * np.pi * df.index.dayofweek / 7)

    # 4. Finalizing Input
    df['log_ret_usd'] = usd_ret
    df['price_velocity_usd'] = usd_vel
    df['gold_log_ret'] = gold_ret
    df['gold_velocity'] = gold_vel
    df['gold_ret_lag1'] = gold_lag
    df['RVOL_50'] = 1.0 
    df['Interest_Rate'] = 19.0
    df['IR_Change'] = 0.0

    final_features_list = [
        'log_ret', 'log_ret_usd', 'price_velocity', 'price_velocity_usd', 'RVOL_50', 
        'day_sin', 'day_cos', 'dist_EMA_9', 'dist_EMA_21', 'dist_EMA_50', 
        'RSI', 'MACD_Hist', 'Interest_Rate', 'IR_Change',
        'gold_log_ret', 'gold_velocity', 'gold_ret_lag1'
    ]
    
    input_data = df[final_features_list].tail(1)
    
    # 5. Prediction
    latest_data_scaled = scaler.transform(input_data)
    prob = model.predict_proba(latest_data_scaled)[0][1]
    signal, color = get_signal_label(prob)

    # 6. Professional Console Output
    close_price = df['close'].iloc[-1]
    print("\n" + "╔" + "═"*58 + "╗")
    print(f"║ {'EGX360 DEEP QUANT ENGINE - PREDICTION':^56} ║")
    print("╠" + "═"*58 + "╣")
    print(f"║ 📊 ASSET      : {symbol:<43} ║")
    print(f"║ 📅 DATE       : {df.index[-1].strftime('%Y-%m-%d'):<43} ║")
    print(f"║ 💰 CLOSE PRICE: {close_price:<43.2f} ║")
    print(f"║ ✨ CONFIDENCE : {prob:<43.2%} ║")
    print(f"║ 🚦 SIGNAL     : {signal:<43} ║")
    print("╚" + "═"*58 + "╝\n")

    # 7. Charting
    fig = go.Figure()
    fig.add_trace(go.Scatter(x=df.index, y=df['close'], name='Close Price', line=dict(color='black', width=2)))
    fig.add_trace(go.Scatter(x=df.index, y=df['EMA_9'], name='EMA 9', line=dict(color='blue', dash='dot')))
    
    fig.add_annotation(
        x=df.index[-1], y=close_price,
        text=f"<b>{signal}</b><br>Price: {close_price:.2f}",
        showarrow=True, arrowhead=2, bgcolor=color, font=dict(color="white")
    )

    fig.update_layout(title=f"EGX360 Prediction: {symbol}", template='plotly_white')
    
    # Save chart as HTML to avoid Linux Display errors
    fig.write_html("egx_prediction.html")
    print("💾 Chart saved as 'egx_prediction.html'. Open it in your browser!")
    fig.show()

if __name__ == "__main__":
    fetch_and_predict("COMI")