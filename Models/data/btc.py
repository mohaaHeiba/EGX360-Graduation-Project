from binance.client import Client
import pandas as pd

print("🚀 جاري الاتصال بسيرفرات Binance لسحب كل بيانات BTC التاريخية (فريم الساعة)...")
print("⏳ الموضوع هياخد كام ثانية لأننا بنسحب عشرات الآلاف من الساعات...")

# الاتصال بباينانس (مش محتاج API Key للداتا العامة)
client = Client()

# سحب الداتا لزوج BTC/USDT فريم الساعة، من أغسطس 2017 (بداية باينانس)
symbol = 'BTCUSDT'
interval = Client.KLINE_INTERVAL_1HOUR
start_date = "1 Aug 2017"

klines = client.get_historical_klines(symbol, interval, start_date)

# تحويل البيانات لـ DataFrame
cols = ['datetime', 'open', 'high', 'low', 'close', 'volume', 'close_time', 
        'quote_av', 'trades', 'tb_base_av', 'tb_quote_av', 'ignore']
df_btc = pd.DataFrame(klines, columns=cols)

# تظبيط الأعمدة عشان تشتغل على كود الموديل بتاعك فوراً
# 1. تظبيط التاريخ
df_btc['datetime'] = pd.to_datetime(df_btc['datetime'], unit='ms')

# 2. تحويل الأرقام من Text لـ Float
for col in ['open', 'high', 'low', 'close', 'volume']:
    df_btc[col] = df_btc[col].astype(float)

# 3. فلترة الأعمدة اللي مشروعك محتاجها بس
final_cols = ['datetime', 'open', 'high', 'low', 'close', 'volume']
df_btc = df_btc[final_cols]

# حفظ الداتا في ملف CSV
file_name = "BTC_ALL_HOURLY.csv"
df_btc.to_csv(file_name, index=False)

print(f"✅ تم بنجاح جبار! تم حفظ البيانات في: {file_name}")
print(f"📊 إجمالي عدد الساعات (الصفوف): {df_btc.shape[0]:,}")
print(f"📅 الداتا بتبدأ من: {df_btc['datetime'].min()} لحد: {df_btc['datetime'].max()}")
print("-" * 30)
print(df_btc.head())