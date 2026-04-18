import pandas as pd  # التعديل الأهم: استيراد بانداز صح
import yfinance as yf
import numpy as np
import os

# 1. تحميل الداتا اللي عملناها المرة اللي فاتت (اللي فيها عمود الدولار)
print("📂 Loading EGX30 data with USD rate...")
current_dir = os.getcwd()
input_path = os.path.join(current_dir, "data", "EGX30_1D_with_USD.csv")

if not os.path.exists(input_path):
    print(f"❌ Error: {input_path} not found! Run the USD script first.")
    exit()

df = pd.read_csv(input_path)
df['timestamp'] = pd.to_datetime(df['timestamp']).dt.normalize()
df.set_index('timestamp', inplace=True)

# 2. تنزيل داتا الذهب العالمية
print("🌍 Fetching Gold Futures data...")
# الرمز GC=F هو الذهب العالمي
gold_data = yf.download('GC=F', start='1998-01-01')

if gold_data.empty:
    print("❌ Failed to download gold data. Check your internet or upgrade yfinance.")
    exit()

# تظبيط داتا الذهب
gold_df = gold_data[['Close']].copy()

# التعامل مع الـ MultiIndex لو موجود في النسخ الجديدة من yfinance
if isinstance(gold_df.columns, pd.MultiIndex):
    gold_df.columns = gold_df.columns.get_level_values(0)

gold_df.columns = ['gold_usd']
gold_df.index = pd.to_datetime(gold_df.index).tz_localize(None).normalize()

# 3. دمج الذهب مع الداتا الأساسية
print("🔗 Merging Gold data with EGX data...")
df = df.join(gold_df, how='left')
df['gold_usd'] = df['gold_usd'].ffill().bfill()

# 4. تحويل الذهب لجنيه مصري (عشان الموديل يفهم العلاقة بالسوق المحلي)
df['gold_egp'] = df['gold_usd'] * df['usd_egp_rate']

# 5. Feature Engineering للذهب (السر في الـ Accuracy العالية)
df['gold_log_ret'] = np.log((df['gold_egp'] + 1e-6) / (df['gold_egp'].shift(1) + 1e-6))
df['gold_velocity'] = df['gold_log_ret'].diff()
df['gold_ret_lag1'] = df['gold_log_ret'].shift(1)

# 6. حفظ الملف النهائي
output_path = os.path.join(current_dir, "data", "EGX30_Final_v9.csv")
df.to_csv(output_path)

print(f"✅ Success! Final dataset saved to: {output_path}")
print(df[['close', 'gold_egp', 'gold_log_ret']].tail())