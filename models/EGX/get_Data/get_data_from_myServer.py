import os
import pandas as pd
from supabase import create_client, Client

# حط بياناتك الجديدة هنا بعد ما تغير الـ Key اللي اتسرب
url = "https://zlcddmhcxtxvgzxcfvxx.supabase.co"
key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpsY2RkbWhjeHR4dmd6eGNmdnh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyOTM0MTcsImV4cCI6MjA4MDg2OTQxN30.F5SxofdTfi9oBO3db1nygSXIiYEqoXgZ0OTW_Fu5Kew"
supabase: Client = create_client(url, key)

def fetch_all_data(table_name):
    print(f"جاري سحب البيانات من جدول {table_name}...")
    all_data = []
    page_size = 20000  # أقصى عدد مسموح به في الطلب الواحد
    start = 0
    
    while True:
        # سحب البيانات بنظام التقسيط (Pagination)
        response = supabase.table(table_name) \
            .select("*") \
            .eq("timeframe", "1d") \
            .range(start, start + page_size - 1) \
            .execute()
        
        data = response.data
        all_data.extend(data)
        
        # لو الداتا اللي رجعت أقل من page_size، يبقى خلصنا الجدول
        if len(data) < page_size:
            break
        
        start += page_size
        print(f"تم سحب {len(all_data)} صف حتى الآن...")

    # تحويل البيانات لـ DataFrame
    df = pd.DataFrame(all_data)
    
    if not df.empty:
        # تظبيط صيغة الوقت للـ timestamp فقط
        df['timestamp'] = pd.to_datetime(df['timestamp'])
            
        # ==========================================
        # خطوة الترتيب (Sorting)
        # ==========================================
        print(f"جاري ترتيب بيانات {table_name} زمنيًا من الأقدم للأحدث...")
        df.sort_values(by='timestamp', ascending=True, inplace=True)
        df.reset_index(drop=True, inplace=True)
        
        # ==========================================
        # مسح الأعمدة غير المطلوبة
        # ==========================================
        print("جاري حذف أعمدة timeframe و created_at...")
        df.drop(columns=['timeframe', 'created_at'], errors='ignore', inplace=True)
    
    return df

# ==========================================
# إعداد مسار الحفظ وإنشاء الفولدر لو مش موجود
# ==========================================

# تحديد مسار فولدر data 
save_dir = "data"

# السطر ده هيكريت فولدر data أوتوماتيك لو مش موجود عشان ميضربش إيرور
os.makedirs(save_dir, exist_ok=True)

# ==========================================
# سحب وحفظ البيانات
# ==========================================

# سحب وحفظ بيانات الجدول الأول
df_30 = fetch_all_data("egx30_candles")
save_path_30 = os.path.join(save_dir, "egx30_1d_data.csv")
df_30.to_csv(save_path_30, index=False)
print(f"✅ خلصنا! تم حفظ {len(df_30)} صف مترتبين ومتنضفين في ملف: {save_path_30}")

# سحب وحفظ بيانات الجدول التاني
df_70 = fetch_all_data("egx70ewi_candles")
save_path_70 = os.path.join(save_dir, "egx70ewi_1d_data.csv")
df_70.to_csv(save_path_70, index=False)
print(f"✅ خلصنا! تم حفظ {len(df_70)} صف مترتبين ومتنضفين في ملف: {save_path_70}")