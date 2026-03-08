# import pandas as pd
# import json
# import time
# import os
# import re
# from cerebras.cloud.sdk import Cerebras

# # ==============================================================================
# # 1. Configuration 
# # ==============================================================================
# CEREBRAS_APIKEY = "csk-cmfc5nr8t2tw35cwxt52h2cy54kfypxw4vemkfex9kj6r8vd"
# client = Cerebras(api_key=CEREBRAS_APIKEY)

# INPUT_FILE = "stock_news.csv"         
# OUTPUT_FILE = "labeled_news_cerebras.csv" 
# BATCH_SIZE = 10                       

# # ==============================================================================
# # 2. AI Logic using Cerebras (llama3.1-8b)
# # ==============================================================================

# def get_ai_sentiments(batch_df):
#     prompt = """
#     أنت خبير مالي في البورصة المصرية (EGX). قم بتصنيف الأخبار التالية إلى (Positive, Negative, Neutral) بناءً على تأثيرها المباشر على سهم الشركة المذكورة.
    
#     القواعد الصارمة جداً:
#     1. أخبار أسعار الدولار، الذهب، التضخم أو الاقتصاد الكلي (بدون ذكر تأثير مباشر للشركة) = Neutral.
#     2. التراجع في الخسائر وتقليصها = Positive.
#     3. أخطاء التداول، إيقاف الأسهم، الغرامات، وهبوط المؤشرات بسبب السهم = Negative.
#     4. شراكات إدارة الفنادق (مثل ماندارين أورينتال) أو التوسعات = Positive.
    
#     ارجع النتيجة بصيغة JSON Array فقط بهذا الشكل:
#     [{"id": 123, "sentiment_label": "Positive"}]
#     لا تكتب أي نصوص أخرى أو شروحات.
    
#     الأخبار:
#     """
    
#     for _, row in batch_df.iterrows():
#         content_snippet = str(row.get('content', ''))[:300]
#         prompt += f"\n- ID: {row['id']} | Title: {row['title']} | Content: {content_snippet}\n"

#     try:
#         response = client.chat.completions.create(
#             messages=[
#                 {"role": "system", "content": "أنت محلل مالي دقيق. تجيب بصيغة JSON فقط دون أي مقدمات."},
#                 {"role": "user", "content": prompt}
#             ],
#             model="llama3.1-8b", # الموديل المتاح والمضمون لحسابك
#             temperature=0.1, 
#         )
        
#         raw_text = response.choices[0].message.content
        
#         json_match = re.search(r'\[.*\]', raw_text, re.DOTALL)
#         if json_match:
#             clean_json = json_match.group(0)
#             return json.loads(clean_json)
#         else:
#             print("   ⚠️ الموديل لم يرجع JSON صالح.")
#             return None
            
#     except Exception as e:
#         print(f"   ⚠️ خطأ في الاتصال بـ Cerebras: {e}")
#         return None

# # ==============================================================================
# # 3. Main Runner
# # ==============================================================================

# def main():
#     if not os.path.exists(INPUT_FILE):
#         print(f"❌ الملف {INPUT_FILE} مش موجود في المسار الحالي!")
#         return

#     print("📥 جاري قراءة الملف...")
#     try:
#         df = pd.read_csv(INPUT_FILE, encoding='utf-8-sig')
#     except:
#         try:
#             df = pd.read_csv(INPUT_FILE, encoding='utf-16')
#         except:
#             df = pd.read_csv(INPUT_FILE, encoding='cp1256')

#     if 'sentiment_label' not in df.columns:
#         df['sentiment_label'] = None

#     total_rows = len(df)
#     print(f"🚀 تم العثور على {total_rows} خبر. جاري بدء التحليل الذكي مع Cerebras...")

#     unlabeled_idx = df[df['sentiment_label'].isnull()].index

#     if len(unlabeled_idx) == 0:
#          print("✅ جميع الأخبار تم تصنيفها مسبقاً!")
#          return

#     for i in range(0, len(unlabeled_idx), BATCH_SIZE):
#         batch_indices = unlabeled_idx[i : i + BATCH_SIZE]
#         batch_df = df.loc[batch_indices]
        
#         print(f"📦 جاري معالجة الأخبار من {i+1} إلى {min(i+BATCH_SIZE, len(unlabeled_idx))} من أصل {len(unlabeled_idx)} متبقي...")
        
#         results = get_ai_sentiments(batch_df)
        
#         if results:
#             for item in results:
#                 try:
#                     item_id = type(df['id'].iloc[0])(item['id'])
#                     df.loc[df['id'] == item_id, 'sentiment_label'] = item['sentiment_label']
#                 except:
#                     pass
            
#             df.to_csv(OUTPUT_FILE, index=False, encoding='utf-8-sig')
#             print("   ✅ تم حفظ الدفعة بنجاح.")
        
#         time.sleep(1)

#     print(f"\n🎉 انتهى العمل! الملف النظيف جاهز باسم: {OUTPUT_FILE}")

# if __name__ == "__main__":
#     main()
import pandas as pd

df = pd.read_csv("labeled_news_cerebras.csv")
# مسح أي سطر بيحتوي على كلمة CAPTCHA أو JavaScript في المحتوى
clean_df = df[~df['content'].astype(str).str.contains('CAPTCHA|JavaScript|verify that you', case=False, na=False)]

clean_df.to_csv("final_clean_dataset.csv", index=False, encoding='utf-8-sig')
print(f"تم التنظيف! عدد الأخبار الصافية: {len(clean_df)}")