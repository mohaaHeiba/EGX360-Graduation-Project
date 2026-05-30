import re
from groq import Groq
from transformers import pipeline
import config

class AIEngine:
    def __init__(self):
        print("🧠 Initializing AI Engines...")
        self.groq_client = Groq(api_key=config.GROQ_API_KEY)
        
        print("🤖 Loading FinBERT model for English news (Offline Hugging Face)...")
        self.finbert = pipeline("text-classification", model="ProsusAI/finbert", truncation=True, max_length=512, device=-1)

    def is_arabic(self, text):
        return bool(re.search(r'[\u0600-\u06FF]', str(text)))

    def process_arabic(self, title, content, company_name=None):
        entity_rule = ""
        if company_name:
            entity_rule = f"\n        تحذير إضافي: تأكد أن الخبر يخص بشكل صريح أو يؤثر على شركة/سهم ({company_name}). إذا كان الخبر لا يذكرها أو لا علاقة له بها، أو كان خبراً رياضياً بحتاً (مباريات/كرة قدم)، يجب أن تكتب False."
            
        prompt = f"""
        أنت آلة برمجية صارمة لتنظيف وتصنيف البيانات الاقتصادية. لا تمتلك آراء شخصية. لا تقم بكتابة أي مقدمات أو نهايات أو تحليلات.
        مهمتك محددة في 3 نقاط فقط:
        1. VALID: هل النص يمثل خبر مقروء ومفهوم ومتعلق حصرياً بالاقتصاد، البورصة، الأسهم، أو أخبار الشركات؟ (True/False).
           يجب أن تكتب False إذا كان الخبر متعلقاً بـ: الرياضة (مثل كرة القدم، الأندية)، الفن، الحوادث، أو أي موضوع غير مالي.{entity_rule}
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
            response = self.groq_client.chat.completions.create(
                messages=[
                    {"role": "system", "content": "You are a strict data extraction machine for financial news. ONLY output the requested format. NEVER add opinions, summaries, or conversational text."},
                    {"role": "user", "content": prompt}
                ],
                model="llama-3.1-8b-instant",
                temperature=0.01, 
                max_tokens=3000 
            )
            
            raw_text = response.choices[0].message.content
            
            # Handle cases where the LLM forgets the [END] tag
            if "[START]" in raw_text and "[END]" not in raw_text:
                raw_text += "\n[END]"
                
            block = re.search(r'\[START\](.*?)\[END\]', raw_text, re.DOTALL)
            
            if block:
                data = block.group(1)
                valid_str = re.search(r'VALID:\s*(.+)', data).group(1).strip()
                sentiment_match = re.search(r'SENTIMENT:\s*([A-Za-z]+)', data)
                sentiment = sentiment_match.group(1).strip().capitalize() if sentiment_match else "Neutral"
                
                text_match = re.search(r'TEXT:\s*(.*)', data, re.DOTALL)
                
                is_valid = True if 'True' in valid_str else False
                clean_text = text_match.group(1).strip() if text_match else content
                
                return is_valid, sentiment, clean_text
                
            print(f"      ⚠️ Format Mismatch. Raw Output: {raw_text[:100]}...")
            return True, "Neutral", content
        except Exception as e:
            print(f"      ⚠️ Groq Arabic Error: {e}")
            return True, "Neutral", content

    def process_english_llm(self, title, content):
        prompt = f"""
        You are a strict data extraction machine for financial news. No personal opinions. No introductions or conversational text.
        Your task is strictly limited to 3 points:
        1. VALID: Is the text a readable news item and EXCLUSIVELY related to economy, stock market, stocks, or corporate news? (True/False).
           Write False if the news is about: Sports (e.g., football/soccer, teams), Art/Entertainment, General accidents, or any non-financial topic.
        2. SENTIMENT: Classify the news (Positive, Negative, or Neutral).
        3. TEXT: Rewrite the original text exactly as it is, but REMOVE only (ads, links, keywords, phrases like "Read also").
        
        STRICT WARNING: Do NOT add any opinion, analysis, or summary. The cleaned text must match the original without the advertising clutter.
        
        Original News:
        Title: {title}
        Content: {str(content)[:2500]}
        
        Response MUST be exclusively inside this template:
        [START]
        VALID: <True or False>
        SENTIMENT: <Positive or Negative or Neutral>
        TEXT: <The full cleaned text here>
        [END]
        """
        try:
            response = self.groq_client.chat.completions.create(
                messages=[
                    {"role": "system", "content": "You are a strict financial data extraction machine. ONLY output the requested format."},
                    {"role": "user", "content": prompt}
                ],
                model="llama-3.1-8b-instant",
                temperature=0.01,
                max_tokens=3000
            )
            raw_text = response.choices[0].message.content
            
            # Handle cases where the LLM forgets the [END] tag
            if "[START]" in raw_text and "[END]" not in raw_text:
                raw_text += "\n[END]"
                
            block = re.search(r'\[START\](.*?)\[END\]', raw_text, re.DOTALL)
            if block:
                data = block.group(1)
                valid_str = re.search(r'VALID:\s*(.+)', data).group(1).strip()
                sentiment_match = re.search(r'SENTIMENT:\s*([A-Za-z]+)', data)
                sentiment = sentiment_match.group(1).strip().capitalize() if sentiment_match else "Neutral"
                
                text_match = re.search(r'TEXT:\s*(.*)', data, re.DOTALL)
                is_valid = True if 'True' in valid_str else False
                clean_text = text_match.group(1).strip() if text_match else content
                return is_valid, sentiment, clean_text
                
            print(f"      ⚠️ Format Mismatch. Raw Output: {raw_text[:100]}...")
            return True, "Neutral", content
        except Exception as e:
            print(f"      ⚠️ Groq English Error: {e}")
            return True, "Neutral", content

    def process_english(self, title, content):
        # Fallback to FinBERT if LLM fails or for sentiment only if needed
        text_to_analyze = f"{title}. {content}"
        try:
            result = self.finbert(text_to_analyze)[0]
            return result['label'].capitalize()
        except Exception as e:
            print(f"      ⚠️ FinBERT Error: {e}")
            return "Neutral"