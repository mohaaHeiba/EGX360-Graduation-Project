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
        
        # لو الداتا اللي رجعت أقل من 1000، يبقى خلصنا الجدول
        if len(data) < page_size:
            break
        
        start += page_size
        print(f"تم سحب {len(all_data)} صف حتى الآن...")

    # تحويل البيانات لـ DataFrame
    df = pd.DataFrame(all_data)
    
    # تظبيط صيغة الوقت لو الجدول مش فاضي
    if not df.empty:
        df['timestamp'] = pd.to_datetime(df['timestamp'])
        df['created_at'] = pd.to_datetime(df['created_at'])
    
    return df

# سحب وحفظ بيانات الجدول الأول
df_30 = fetch_all_data("egx30_candles")
df_30.to_csv("EGX/data/egx30_1d_data.csv", index=False)
print(f"✅ خلصنا! تم حفظ {len(df_30)} صف في ملف: egx30_1d_data.csv")

# سحب وحفظ بيانات الجدول التاني
df_70 = fetch_all_data("egx70ewi_candles")
df_70.to_csv("EGX/data/egx70ewi_1d_data.csv", index=False)
print(f"✅ خلصنا! تم حفظ {len(df_70)} صف في ملف: egx70ewi_1d_data.csv")