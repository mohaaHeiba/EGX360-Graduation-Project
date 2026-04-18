import yfinance as yf
import pandas as pd
import numpy as np
import os

# 1. قراءة الداتا الأساسية بتاعتك من ملف الـ CSV
print("Loading EGX30 local data...")
# عدل المسار لو الملف في مكان تاني


print(" Loading Daily Data")
current_dir = os.getcwd()
file_path = os.path.join(current_dir, "data", "EGX30_1D.csv")
print(f"File path: {file_path}")
df = pd.read_csv(file_path)



# توحيد شكل التاريخ (هنشيل الساعات والـ Timezone عشان الدمج يظبط)
df['timestamp'] = pd.to_datetime(df['timestamp']).dt.tz_localize(None).dt.normalize()
df.set_index('timestamp', inplace=True)

# 2. تحميل داتا الدولار من ياهو فاينانس
print("Fetching USD/EGP data from Yahoo Finance...")
usd_data = yf.download('EGP=X', start='1998-01-01', end='2026-03-10')

# تظبيط داتا الدولار
usd_df = usd_data[['Close']].copy()
# لو بتستخدم نسخة yfinance جديدة جداً، السطر اللي جاي بيشيل الـ MultiIndex
if isinstance(usd_df.columns, pd.MultiIndex):
    usd_df.columns = usd_df.columns.get_level_values(0)
    
usd_df.columns = ['usd_egp_rate'] # تغيير اسم العمود
usd_df.index = pd.to_datetime(usd_df.index).tz_localize(None).normalize() # توحيد التاريخ

# 3. دمج الداتا
print("Merging Data...")
df = df.join(usd_df, how='left')

# 4. معالجة الفراغات (عشان إجازات البنوك والويك إند)
df['usd_egp_rate'] = df['usd_egp_rate'].ffill()
df['usd_egp_rate'] = df['usd_egp_rate'].bfill()

# 5. الحسبة السحرية: تسعير المؤشر بالدولار
df['close_usd'] = df['close'] / df['usd_egp_rate']

# 6. حساب المؤشرات الجديدة
df['log_ret_usd'] = np.log((df['close_usd'] + 1e-6) / (df['close_usd'].shift(1) + 1e-6))
df['price_velocity_usd'] = df['log_ret_usd'].diff()

print("Done! Here is your Data:")
print(df[['close', 'usd_egp_rate', 'close_usd', 'log_ret_usd']].tail(10))

# حفظ الداتا الجديدة في ملف CSV جوه مجلد data
output_path = os.path.join(current_dir, "data", "EGX30_1D_with_USD.csv")
df.to_csv(output_path)

print(f"Data saved successfully to: {output_path}")