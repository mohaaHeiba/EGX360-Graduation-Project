import yfinance as yf
import pandas as pd

print("🚀 جاري سحب بيانات الاقتصاد العالمي (Macro Data)...")

# سحب مؤشر S&P 500 (سوق الأسهم) ومؤشر الدولار (DXY)
tickers = ["^GSPC", "DX-Y.NYB"]
macro_data = yf.download(tickers, start="2017-08-17", end="2026-03-07")['Close']

# تحديد ترتيب الأعمدة بوضوح عشان yfinance بترتب أبجدي وميحصلش لخبطة
macro_data = macro_data[["DX-Y.NYB", "^GSPC"]]
macro_data.columns = ['DXY', 'SP500']

macro_data.reset_index(inplace=True)
macro_data.rename(columns={'Date': 'datetime'}, inplace=True)

# تحويل التاريخ 
macro_data['datetime'] = pd.to_datetime(macro_data['datetime'])

# 🔥 الحل بتاع الإيرور: استخدام ffill() المباشرة للنسخ الجديدة من Pandas
macro_data.ffill(inplace=True)

# حفظ الملف
file_name = "Macro_Data_Daily.csv"
macro_data.to_csv(file_name, index=False)

print(f"✅ تم الحفظ بنجاح في ملف: {file_name}")
print(macro_data.tail())