import pandas as pd
import time
import re
import os
from cerebras.cloud.sdk import Cerebras

# ==========================================
# 1. Configuration
# ==========================================
CEREBRAS_APIKEY = "csk-ywf42kf845xf43crjpphnn9crt28698w8xpkx8ef5p4rdcew"
client = Cerebras(api_key=CEREBRAS_APIKEY)

INPUT_FILE = "labeled_news_cerebras.csv"
OUTPUT_FILE = "super_refined_news.csv"
BATCH_SIZE = 5 

def process_with_ai(batch_df):
    # لغينا الـ JSON تماماً واستخدمنا نظام الـ Tags (زي الـ XML)
    prompt = """
    أنت خبير صياغة تقارير مالية للبورصة المصرية. قم بمعالجة الأخبار التالية.
    
    القواعد:
    1. أعد صياغة الخبر بأسلوب صحفي مالي "كامل ودسم". حافظ على كل الأرقام، أسماء الشركات، أسباب الصعود/الهبوط، والتفاصيل الجوهرية.
    2. احذف فقط: الإعلانات، الروابط، وأسماء الصحفيين.
    3. لا تختصر الخبر في جملة واحدة.
    
    يجب أن يكون الرد بهذا التنسيق النصي الصارم لكل خبر (لا تستخدم JSON):
    
    [START]
    ID: <رقم الخبر>
    SENTIMENT: <Positive أو Negative أو Neutral>
    VALID: <True أو False>
    ACTION: <keep أو delete>
    TEXT: <اكتب النص المالي المعالج والمفصل هنا>
    [END]
    """
    
    for _, row in batch_df.iterrows():
        # تنظيف مبدئي خفيف عشان الـ Prompt
        safe_title = str(row['title']).replace('\n', ' ')
        safe_content = str(row.get('content', '')).replace('\n', ' ')
        prompt += f"\n--- الخبر الأصلي ---\nID: {row['id']}\nTitle: {safe_title}\nContent: {safe_content[:1500]}\n"

    try:
        response = client.chat.completions.create(
            messages=[
                {"role": "system", "content": "You are a financial editor. Always use the exact [START] and [END] block format requested."},
                {"role": "user", "content": prompt}
            ],
            model="llama3.1-8b",
            temperature=0.1, 
            max_tokens=3000, 
        )
        
        raw_content = response.choices[0].message.content
        
        results = []
        # استخراج البيانات باستخدام Regular Expressions قوية جداً
        blocks = re.findall(r'\[START\](.*?)\[END\]', raw_content, re.DOTALL)
        
        for block in blocks:
            try:
                # بنبحث عن كل قيمة جوه البلوك
                item_id = re.search(r'ID:\s*(.+)', block).group(1).strip()
                sentiment = re.search(r'SENTIMENT:\s*(.+)', block).group(1).strip()
                valid_str = re.search(r'VALID:\s*(.+)', block).group(1).strip()
                action = re.search(r'ACTION:\s*(.+)', block).group(1).strip()
                
                # النص بياخد كل حاجة بعد كلمة TEXT: لحد آخر البلوك
                text_match = re.search(r'TEXT:\s*(.*)', block, re.DOTALL)
                clean_text = text_match.group(1).strip() if text_match else ""
                
                is_valid = True if 'True' in valid_str else False
                
                results.append({
                    "id": item_id,
                    "sentiment": sentiment,
                    "clean_text": clean_text,
                    "is_valid": is_valid,
                    "action": action
                })
            except Exception as parse_err:
                print(f"⚠️ تجاهل بلوك غير مكتمل: {parse_err}")
                continue # لو خبر واحد باظ، التانيين يكملوا عادي جداً
                
        return results
        
    except Exception as e:
        print(f"⚠️ خطأ في الاتصال بالـ API: {e}")
        return None

# ==========================================
# 2. Main Runner 
# ==========================================
def main():
    if not os.path.exists(INPUT_FILE):
        print("❌ الملف الأصلي غير موجود!")
        return

    df = pd.read_csv(INPUT_FILE)
    if 'id' not in df.columns: df['id'] = df.index.astype(str)
    
    processed_ids = set()
    if os.path.exists(OUTPUT_FILE):
        existing_df = pd.read_csv(OUTPUT_FILE)
        processed_ids = set(existing_df['id'].astype(str))
    
    to_process_df = df[~df['id'].astype(str).isin(processed_ids)]
    print(f"🚀 متبقي للمعالجة: {len(to_process_df)} من أصل {len(df)}")

    for i in range(0, len(to_process_df), BATCH_SIZE):
        batch = to_process_df.iloc[i : i + BATCH_SIZE]
        print(f"📦 دفعة {i//BATCH_SIZE + 1} | معالجة {len(batch)} أخبار...")
        
        results = process_with_ai(batch)
        
        if results and len(results) > 0:
            results_df = pd.DataFrame(results)
            header = not os.path.exists(OUTPUT_FILE)
            results_df.to_csv(OUTPUT_FILE, mode='a', index=False, header=header, encoding='utf-8-sig')
            print("   ✅ تم الحفظ.")
        else:
            print("   ⚠️ لم يتم استخراج بيانات من هذه الدفعة.")
            
        time.sleep(1) # راحة ثانية عشان الـ API ميعملش Rate Limit

    print(f"\n🎉 المهمة تمت بنجاح! الملف جاهز: {OUTPUT_FILE}")

if __name__ == "__main__":
    main()