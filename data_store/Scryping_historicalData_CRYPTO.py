import ccxt
import pandas as pd
import os
import time
from datetime import datetime

crypto_symbols = [
    'BTC', 'ETH', 'SOL', 'XRP', 'DOGE', 'BNB', 'ADA', 'AVAX', 'DOT', 'LINK',
    'SHIB', 'PEPE', 'MATIC', 'LTC', 'UNI', 'TRX', 'ETC', 'FIL', 'AAVE', 'NEAR',
    'FET', 'RNDR', 'ARB', 'APT', 'ATOM'
]

output_dir = "crypto"
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

exchange = ccxt.binance({
    'enableRateLimit': True,  
})

def fetch_all_history(symbol):
    target_symbol = f"{symbol}/USDT"
    print(f"🔄 {target_symbol}...")
    
    all_ohlcv = []
    since = exchange.parse8601('2016-01-01T00:00:00Z')
    
    while True:
        try:
            ohlcv = exchange.fetch_ohlcv(target_symbol, timeframe='1d', since=since, limit=1000)
            
            if not ohlcv:
                break
            
            all_ohlcv.extend(ohlcv)
            
            since = ohlcv[-1][0] + 86400000 
            
            if len(ohlcv) < 1000:
                break
                
            print(f"Fetched {len(all_ohlcv)} rows for {symbol}...")
            time.sleep(0.5) 
            
        except Exception as e:
            print(f"❌ {symbol}: {e}")
            break

    if all_ohlcv:
        df = pd.DataFrame(all_ohlcv, columns=['datetime', 'open', 'high', 'low', 'close', 'volume'])
        df['datetime'] = pd.to_datetime(df['datetime'], unit='ms').dt.strftime('%Y-%m-%d %H:%M:%S')
        
        filename = f"{symbol.lower()}_candles.csv"
        df.to_csv(os.path.join(output_dir, filename), index=False)
        print(f"✅ {len(df)} day to {symbol} in {filename}\n")

for symbol in crypto_symbols:
    fetch_all_history(symbol)
