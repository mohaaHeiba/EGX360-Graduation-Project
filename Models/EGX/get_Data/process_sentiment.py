import pandas as pd
import time
import os
import re
import sys
from cerebras.cloud.sdk import Cerebras

# ==============================================================================
# 1. Configuration 
# ==============================================================================
# حط الـ API الجديد بتاعك هنا بين علامتين التنصيص
CEREBRAS_APIKEY = "csk-ywf42kf845xf43crjpphnn9crt28698w8xpkx8ef5p4rdcew"
client = Cerebras(api_key=CEREBRAS_APIKEY)


current_dir = os.getcwd()

# 1. قراءة الملف اللي فيه الذهب والدولار
file_path = os.path.join(current_dir, "stocks_news_filtered.csv")


INPUT_FILE = file_path     
OUTPUT_FILE = "labeled_news_cerebras.csv" 
BATCH_SIZE = 10                       

# ==============================================================================
# 2. AI Logic using Cerebras (Plain Text Parsing)
# ==============================================================================

def get_ai_sentiments_and_clean(batch_df):
    prompt = """
    أنت خبير مالي في البورصة المصرية ومحرر نصوص دقيق.
    مطلوب منك شيئين لكل خبر يتم إرساله لك:
    1. تنظيف النص (TEXT): استخرج الجوهر المالي للخبر فقط باختصار. احذف أي حشو، إعلانات، روابط، أو جمل مثل "اقرأ أيضا".
    2. تصنيف الخبر (LABEL): صنف الخبر المنظف إلى (Positive, Negative, Neutral).
    
    القواعد الصارمة للتصنيف:
    1. أخبار الدولار، الذهب، الاقتصاد الكلي (بدون ذكر تأثير مباشر للشركة) = Neutral.
    2. التراجع في الخسائر وتقليصها = Positive.
    3. أخطاء التداول، إيقاف الأسهم، الغرامات = Negative.
    4. شراكات أو توسعات = Positive.
    
    يجب أن ترجع النتيجة بالنص العادي (Plain Text) بهذا التنسيق الصارم لكل خبر:
    
    ID: [رقم الخبر]
    LABEL: [Positive أو Negative أو Neutral]
    TEXT: [النص المالي الصافي هنا]
    $$$
    
    استخدم العلامة $$$ لتفصل بين كل خبر والذي يليه.
    لا تكتب أي مقدمات أو شروحات إضافية.
    
    الأخبار:
    """
    
    for _, row in batch_df.iterrows():
        content_snippet = str(row.get('content', ''))[:800] 
        content_snippet = re.sub(r'<[^>]+>', ' ', content_snippet)
        content_snippet = re.sub(r'\s+', ' ', content_snippet).strip()
        
        prompt += f"\n- ID: {row['id']} | Title: {row['title']} | Content: {content_snippet}\n"

    try:
        response = client.chat.completions.create(
            messages=[
                {"role": "system", "content": "أنت نظام آلي يجيب فقط بالتنسيق المطلوب وتفصل بـ $$$."},
                {"role": "user", "content": prompt}
            ],
            model="llama3.1-8b", 
            temperature=0.1, 
        )
        
        raw_text = response.choices[0].message.content
        
        # استخراج البيانات باستخدام Regex
        results = []
        blocks = raw_text.split('$$$') 
        
        for block in blocks:
            if not block.strip():
                continue
                
            id_match = re.search(r'ID:\s*(\d+)', block)
            label_match = re.search(r'LABEL:\s*(Positive|Negative|Neutral)', block, re.IGNORECASE)
            text_match = re.search(r'TEXT:\s*(.*)', block, re.DOTALL | re.IGNORECASE)
            
            if id_match and label_match and text_match:
                results.append({
                    'id': id_match.group(1).strip(),
                    'sentiment_label': label_match.group(1).strip().capitalize(),
                    'cleaned_text': text_match.group(1).strip()
                })
        
        if len(results) > 0:
            return results
        else:
            print("   ⚠️ الموديل لم يرجع الداتا بالتنسيق المطلوب.")
            return None
            
    except Exception as e:
        error_msg = str(e)
        print(f"   ⚠️ خطأ في الاتصال بـ Cerebras: {error_msg}")
        
        # الإيقاف التلقائي لو الباقة خلصت
        if "429" in error_msg and "quota" in error_msg.lower():
            print("\n🛑 تنبيه: الباقة اليومية للـ API ده خلصت! السكريبت هيقف أوتوماتيك.")
            sys.exit(0)
            
        return None

# ==============================================================================
# 3. Main Runner
# ==============================================================================

def main():
    if not os.path.exists(INPUT_FILE):
        print(f"❌ الملف {INPUT_FILE} مش موجود في المسار الحالي!")
        return

    print("📥 جاري قراءة الملف الأصلي...")
    try:
        df = pd.read_csv(INPUT_FILE, encoding='utf-8-sig')
    except:
        try:
            df = pd.read_csv(INPUT_FILE, encoding='utf-16')
        except:
            df = pd.read_csv(INPUT_FILE, encoding='cp1256')

    df['id'] = df['id'].astype(str)

    if 'sentiment_label' not in df.columns:
        df['sentiment_label'] = None
    if 'cleaned_text' not in df.columns:
        df['cleaned_text'] = None

    # ==============================================================================
    # استرجاع الأخبار المعالجة مسبقاً (ده اللي هيخليه يكمل من مكان ما وقف)
    # ==============================================================================
    if os.path.exists(OUTPUT_FILE):
        print("🔍 جاري فحص ملف المخرجات لاسترجاع الأخبار المعالجة مسبقاً...")
        try:
            df_out = pd.read_csv(OUTPUT_FILE, encoding='utf-8-sig')
            df_out['id'] = df_out['id'].astype(str)
            
            labeled_rows = df_out.dropna(subset=['sentiment_label', 'cleaned_text'])
            
            labeled_dict = labeled_rows.set_index('id')['sentiment_label'].to_dict()
            cleaned_dict = labeled_rows.set_index('id')['cleaned_text'].to_dict()
            
            df['sentiment_label'] = df['id'].map(labeled_dict).fillna(df['sentiment_label'])
            df['cleaned_text'] = df['id'].map(cleaned_dict).fillna(df['cleaned_text'])
            
            print(f"🔄 تم استرجاع وتخطي {len(labeled_dict)} خبر معالج مسبقاً!")
        except Exception as e:
            print(f"⚠️ مقدرتش أقرأ ملف المخرجات القديم: {e}")

    total_rows = len(df)
    unlabeled_idx = df[df['sentiment_label'].isnull()].index

    print(f"🚀 إجمالي الأخبار: {total_rows} | المعالج: {total_rows - len(unlabeled_idx)} | المتبقي: {len(unlabeled_idx)}")

    if len(unlabeled_idx) == 0:
         print("✅ جميع الأخبار تم معالجتها مسبقاً! مفيش حاجة تتعمل.")
         return

    for i in range(0, len(unlabeled_idx), BATCH_SIZE):
        batch_indices = unlabeled_idx[i : i + BATCH_SIZE]
        batch_df = df.loc[batch_indices]
        
        print(f"📦 جاري معالجة الأخبار من {i+1} إلى {min(i+BATCH_SIZE, len(unlabeled_idx))} من أصل {len(unlabeled_idx)} متبقي...")
        
        results = get_ai_sentiments_and_clean(batch_df)
        
        if results:
            for item in results:
                s_label = item.get('sentiment_label')
                c_text = item.get('cleaned_text')
                
                mask = df['id'] == str(item.get('id', ''))
                if s_label:
                    df.loc[mask, 'sentiment_label'] = s_label
                if c_text:
                    df.loc[mask, 'cleaned_text'] = c_text
            
            df.to_csv(OUTPUT_FILE, index=False, encoding='utf-8-sig')
            print("   ✅ تم التنظيف والتصنيف والحفظ بنجاح.")
        else:
            print("   ⚠️ تم تخطي هذه الدفعة بسبب عدم فهم رد الموديل أو خطأ في الاتصال.")
            
        time.sleep(1)

    print(f"\n🎉 انتهى العمل! الملف جاهز باسم: {OUTPUT_FILE}")

if __name__ == "__main__":
    main()