import requests
import pandas as pd
import numpy as np

print("🚀 جاري سحب بيانات مؤشر الخوف والطمع (Fear & Greed)...")

# API مجاني بيجيب الداتا التاريخية كلها
url = "https://api.alternative.me/fng/?limit=0"
try:
    response = requests.get(url)
    data = response.json()['data']

    # تحويل الداتا لـ DataFrame
    df_fng = pd.DataFrame(data)

    # 🔥 الحل هنا: تحويل الـ timestamp لرقم صحيح (int) الأول
    df_fng['timestamp'] = df_fng['timestamp'].astype(int)

    # دلوقتي نحول التاريخ من نظام الـ Unix لـ Datetime عادي
    df_fng['datetime'] = pd.to_datetime(df_fng['timestamp'], unit='s')

    # تحويل القيمة لرقم (float)
    df_fng['value'] = df_fng['value'].astype(float)

    # تظبيط الأعمدة والترتيب
    df_fng = df_fng[['datetime', 'value']]
    df_fng.rename(columns={'value': 'Fear_Greed_Index'}, inplace=True)
    df_fng.sort_values('datetime', inplace=True)

    # حذف أي داتا مستقبلية لو موجودة (عشان نضمن دقة الداتا)
    df_fng = df_fng[df_fng['datetime'] <= pd.Timestamp.now()]

    # حفظ الملف
    file_name = "Fear_Greed_Daily.csv"
    df_fng.to_csv(file_name, index=False)
    
    print(f"✅ تم بنجاح! الملف جاهز في: {file_name}")
    print(f"📊 عدد الأيام المسحوبة: {len(df_fng)}")
    print(df_fng.tail())

except Exception as e:
    print(f"❌ حصلت مشكلة: {e}")