import re
from cerebras.cloud.sdk import Cerebras
from transformers import pipeline
import config

class AIEngine:
    def __init__(self):
        print("🧠 Initializing AI Engines...")
        self.cerebras_client = Cerebras(api_key=config.CEREBRAS_APIKEY)
        
        print("🤖 Loading FinBERT model for English news (Offline Hugging Face)...")
        self.finbert = pipeline("text-classification", model="ProsusAI/finbert", truncation=True, max_length=512, device=-1)

    def is_arabic(self, text):
        return bool(re.search(r'[\u0600-\u06FF]', str(text)))

    def process_arabic(self, title, content):
        prompt = f"""
        أنت آلة برمجية صارمة لتنظيف وتصنيف البيانات. لا تمتلك آراء شخصية. لا تقم بكتابة أي مقدمات أو نهايات أو تحليلات.
        مهمتك محددة في 3 نقاط فقط:
        1. VALID: هل النص يمثل خبر مقروء ومفهوم؟ (True/False). إذا كان النص عبارة عن حروف عشوائية، أو بيانات ملتصقة ببعضها (مثل: كودالترقيمالشركة)، أو لا يحمل معنى، اكتب False.
        2. SENTIMENT: صنف الخبر (Positive أو Negative أو Neutral).
        3. TEXT: أعد كتابة النص الأصلي كما هو تماماً، ولكن احذف منه فقط (الإعلانات، الروابط، الكلمات المفتاحية، جمل مثل "اقرأ أيضا"). 
        
        تحذير صارم: ممنوع منعاً باتاً إضافة أي رأي، أو تحليل، أو تلخيص للخبر. النص المنظف يجب أن يكون مطابقاً للأصلي بدون الزيادات الإعلانية.
        
        الخبر الأصلي:
        Title: {title}
        Content: {str(content)[:2500]}
        
        يجب أن يكون الرد حصرياً داخل هذا القالب، وبدون أي كلمة قبله أو بعده:
        [START]
        VALID: <True or False>
        SENTIMENT: <Positive or Negative or Neutral>
        TEXT: <النص الكامل النظيف هنا>
        [END]
        """
        try:
            response = self.cerebras_client.chat.completions.create(
                messages=[
                    {"role": "system", "content": "You are a strict data extraction machine. ONLY output the requested format. NEVER add opinions, summaries, or conversational text."},
                    {"role": "user", "content": prompt}
                ],
                model="llama3.1-8b",
                temperature=0.01, 
                max_tokens=3000 
            )
            
            raw_text = response.choices[0].message.content
            block = re.search(r'\[START\](.*?)\[END\]', raw_text, re.DOTALL)
            
            if block:
                data = block.group(1)
                valid_str = re.search(r'VALID:\s*(.+)', data).group(1).strip()
                sentiment = re.search(r'SENTIMENT:\s*(.+)', data).group(1).strip().capitalize()
                text_match = re.search(r'TEXT:\s*(.*)', data, re.DOTALL)
                
                is_valid = True if 'True' in valid_str else False
                clean_text = text_match.group(1).strip() if text_match else content
                
                return is_valid, sentiment, clean_text
                
            return True, "Neutral", content
        except Exception as e:
            print(f"      ⚠️ Cerebras Error: {e}")
            return True, "Neutral", content

    def process_english(self, title, content):
        text_to_analyze = f"{title}. {content}"
        try:
            result = self.finbert(text_to_analyze)[0]
            return result['label'].capitalize()
        except Exception as e:
            print(f"      ⚠️ FinBERT Error: {e}")
            return "Neutral"