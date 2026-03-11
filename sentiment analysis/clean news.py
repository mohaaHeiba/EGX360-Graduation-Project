import pandas as pd
from datasets import Dataset
from sklearn.model_selection import train_test_split

# 1. سحب الداتا من الملف اللي إنت رافعه بالظبط
df = pd.read_csv("labeled_news_cerebras.csv")

# 2. إزالة الألغام (مسح الـ 3 صفوف الفاضيين)
df = df.dropna(subset=['sentiment_label'])

# 3. تحويل الكلام لأرقام عشان AraBERT يفهمها (سلبي 0، محايد 1، إيجابي 2)
label_mapping = {"Negative": 0, "Neutral": 1, "Positive": 2}
df['label'] = df['sentiment_label'].map(label_mapping)

# 4. التقسيم الجديد (80% تدريب - 20% اختبار) بشكل عادل (Stratified)
train_df, test_df = train_test_split(df, test_size=0.2, random_state=42, stratify=df['label'])

# 5. التحديث الحقيقي والنهائي لمتغيرات الـ Hugging Face
train_dataset = Dataset.from_pandas(train_df)
test_dataset = Dataset.from_pandas(test_df)

print("✅ تم تفريغ الميموري وتحديث الداتا بنجاح!")
print(f"عدد عينات التدريب الحقيقية: {len(train_dataset)}")
print(f"عدد عينات الاختبار الحقيقية: {len(test_dataset)}")
print(f"\nتوزيع الفئات في التدريب:\n{train_df['label'].value_counts()}")