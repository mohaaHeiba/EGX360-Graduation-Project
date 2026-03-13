import pandas as pd
import os

print("🚀 Loading Final Dataset (EGX + USD + Gold)...")
current_dir = os.getcwd()

# 1. قراءة الملف اللي فيه الذهب والدولار
file_path = os.path.join(current_dir, "stock_news.csv")
df = pd.read_csv(file_path)

# 1. قراءة الملف اللي فيه الـ 3800 خبر

# 2. قائمة بعبارات الحظر المشهورة (عشان نصطادهم كلهم)
blocked_phrases = [
    "Your request has been blocked",
    "for security reasons",
    "reference ID",
    "contact support",
    "Access Denied",
    "Cloudflare",
    "captcha",
    "unusual traffic"
]

print(f"📊 عدد الأخبار قبل إزالة البلوك: {len(df)}")

# 3. عمل فلتر (Mask) يدور على العبارات دي جوه عمود content
# | معناها OR (يعني لو لقى أي عبارة منهم)
# case=False عشان يتجاهل الحروف كابيتال أو سمول
# na=False عشان يتجاهل الصفوف الفاضية
mask = df['content'].str.contains('|'.join(blocked_phrases), case=False, na=False)

# 4. تطبيق الفلتر (علامة ~ معناها اعكس الشرط، يعني هاتلي الأخبار السليمة بس)
df_clean = df[~mask]

# 5. النتيجة
dropped_count = len(df) - len(df_clean)
print(f"✅ عدد الأخبار الحقيقية السليمة: {len(df_clean)}")
print(f"🗑️ تم حذف {dropped_count} خبر مضروب (صفحات بلوك).")

# 6. حفظ الداتا السليمة في ملف جديد عشان تكمل عليه شغلك
df_clean.to_csv("stocks_news_filtered.csv", index=False, encoding='utf-8-sig')
print("\nتم حفظ الملف الجديد باسم: stocks_news_filtered.csv")