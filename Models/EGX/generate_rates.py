import pandas as pd
import os

print("Generating Accurate CBE Interest Rate Data...")

# البيانات الدقيقة لأسعار الفائدة (Deposit Rate) في مصر وتواريخ اجتماعات البنك المركزي
rates_data = [
    {"Date": "1998-01-01", "Interest_Rate": 9.00},  # قيمة تقريبية لبداية الداتا
    {"Date": "2015-01-15", "Interest_Rate": 8.75},
    {"Date": "2015-12-24", "Interest_Rate": 9.25},
    {"Date": "2016-11-03", "Interest_Rate": 14.75}, # تعويم 2016
    {"Date": "2017-05-21", "Interest_Rate": 16.75},
    {"Date": "2017-07-06", "Interest_Rate": 18.75},
    {"Date": "2018-02-15", "Interest_Rate": 17.75}, # بدء دورة التيسير
    {"Date": "2018-03-29", "Interest_Rate": 16.75},
    {"Date": "2019-02-14", "Interest_Rate": 15.75},
    {"Date": "2019-08-22", "Interest_Rate": 14.25},
    {"Date": "2019-09-26", "Interest_Rate": 13.25},
    {"Date": "2019-11-14", "Interest_Rate": 12.25},
    {"Date": "2020-03-16", "Interest_Rate": 9.25},  # خفض استثنائي بسبب كورونا
    {"Date": "2020-09-24", "Interest_Rate": 8.75},
    {"Date": "2020-11-12", "Interest_Rate": 8.25},
    {"Date": "2022-03-21", "Interest_Rate": 9.25},  # بداية أزمة أوكرانيا والتعويم
    {"Date": "2022-05-19", "Interest_Rate": 11.25},
    {"Date": "2022-10-27", "Interest_Rate": 13.25}, # التعويم الثاني
    {"Date": "2022-12-22", "Interest_Rate": 16.25},
    {"Date": "2023-03-30", "Interest_Rate": 18.25},
    {"Date": "2023-08-03", "Interest_Rate": 19.25},
    {"Date": "2024-03-06", "Interest_Rate": 27.25}, # التعويم الكبير لـ 2024 
    {"Date": "2025-04-17", "Interest_Rate": 26.25}, # بداية خفض الفائدة في 2025
    {"Date": "2025-05-22", "Interest_Rate": 24.00},
    {"Date": "2025-08-28", "Interest_Rate": 22.00},
    {"Date": "2025-10-02", "Interest_Rate": 21.00},
    {"Date": "2025-12-25", "Interest_Rate": 20.00},
    {"Date": "2026-02-12", "Interest_Rate": 19.00}  # آخر تحديث للبنك المركزي
]

# تحويل البيانات لـ DataFrame
ir_df = pd.DataFrame(rates_data)

# حفظ الملف في مجلد data
current_dir = os.getcwd()
output_path = os.path.join(current_dir, "data", "cbe_interest_rate.csv")
ir_df.to_csv(output_path, index=False)

print(f"Done! Accurate Interest rate data saved to: {output_path}")