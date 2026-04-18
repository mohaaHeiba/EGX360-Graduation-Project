import yfinance as yf

symbol = "EFID.CA" 

df = yf.download(symbol, period="max")

df.to_csv(f"{symbol}_historical_data.csv")

print(f"Done! Saved all available data for {symbol}")
