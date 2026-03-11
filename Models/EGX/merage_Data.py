import pandas as pd

def clean_and_merge_data(supabase_file, local_file, output_file):
    print("جاري قراءة الملفات...")
    # 1. قراءة الداتا من الملفات (افترضت إنهم CSV)
    df_supa = pd.read_csv(supabase_file)
    df_local = pd.read_csv(local_file)

    print("جاري التنظيف وتوحيد الوقت...")
    # 2. مسح الأعمدة الزيادة من داتا Supabase
    df_supa = df_supa.drop(columns=['timeframe', 'created_at'], errors='ignore')

    # 3. توحيد صيغة الوقت (أهم خطوة)
    # تحويل العمودين لـ datetime
    df_supa['timestamp'] = pd.to_datetime(df_supa['timestamp'], utc=True)
    df_local['timestamp'] = pd.to_datetime(df_local['timestamp'])

    # إزالة الـ timezone من داتا Supabase عشان تبقى زي الداتا القديمة بالظبط
    df_supa['timestamp'] = df_supa['timestamp'].dt.tz_localize(None)

    print("جاري الدمج وإزالة التكرار...")
    # 4. الدمج (Concatenation)
    df_merged = pd.concat([df_local, df_supa], ignore_index=True)

    # 5. الترتيب الزمني وإزالة أي صفوف متكررة (لو فيه تداخل في التواريخ)
    df_merged = df_merged.sort_values(by='timestamp')
    df_merged = df_merged.drop_duplicates(subset=['timestamp'], keep='last')

    # إعادة ضبط الـ Index عشان يبقى مترتب صح
    df_merged = df_merged.reset_index(drop=True)

    # 6. حفظ النتيجة النهائية
    df_merged.to_csv(output_file, index=False)
    print(f"✅ تم الدمج بنجاح! الملف النهائي جاهز وفيه {len(df_merged)} صف.")
    
    return df_merged

# تشغيل الفانكشن (غير أسماء الملفات باللي عندك)
# افترضت إن الداتا القديمة اسمها local_data.csv والجديدة supa_data.csv
df_final = clean_and_merge_data(
    supabase_file="EGX/data/egx70ewi_1d_data.csv", 
    local_file="EGX/data/EGX70EWID_processed.csv", 
    output_file="EGX/data/EGX70EWI_1D.csv"
)

# عرض أول 5 صفوف للتأكد
print(df_final.head())