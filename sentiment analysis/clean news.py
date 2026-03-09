import pandas as pd

df = pd.read_csv("labeled_news_cerebras.csv")
# مسح أي سطر بيحتوي على كلمة CAPTCHA أو JavaScript في المحتوى
clean_df = df[~df['content'].astype(str).str.contains('CAPTCHA|JavaScript|verify that you', case=False, na=False)]

clean_df.to_csv("final_clean_dataset.csv", index=False, encoding='utf-8-sig')
print(f"تم التنظيف! عدد الأخبار الصافية: {len(clean_df)}")