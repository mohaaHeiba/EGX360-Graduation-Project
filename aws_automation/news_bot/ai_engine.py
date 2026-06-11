import re
import time
from groq import Groq
from transformers import pipeline
import config

class AIEngine:
    def __init__(self):
        print("🧠 Initializing AI Engines...")

        # Initialize multiple Groq clients for key rotation
        self.api_keys = config.GROQ_API_KEYS
        self.current_key_index = 0
        self.groq_clients = [Groq(api_key=key) for key in self.api_keys]
        self.request_delay = config.REQUEST_DELAY_SECONDS

        if not self.api_keys:
            raise ValueError("❌ No Groq API keys configured. Check config.py / .env")

        print(f"   🔑 Loaded {len(self.api_keys)} API key(s) for rotation.")

        print("🤖 Loading FinBERT model for English news (Offline Hugging Face)...")
        self.finbert = pipeline("text-classification", model="ProsusAI/finbert", truncation=True, max_length=512, device=-1)

    # ---------- Key Rotation Helpers ----------

    def _get_current_client(self):
        """Return the Groq client for the current key index."""
        return self.groq_clients[self.current_key_index]

    def _rotate_key(self):
        """Advance to the next API key. Returns True if a new key is available, False if all exhausted."""
        next_index = self.current_key_index + 1
        if next_index < len(self.api_keys):
            self.current_key_index = next_index
            print(f"      🔄 Rotated to API key #{next_index + 1}/{len(self.api_keys)}")
            return True
        return False

    def _reset_key_index(self):
        """Reset rotation back to the first key (called at the start of each top-level analysis)."""
        self.current_key_index = 0

    def _call_groq(self, messages, max_retries=3):
        """
        Call Groq API with automatic rate-limit handling:
        1. Apply a delay before each request.
        2. On rate-limit (429) or server error, retry with back-off.
        3. If retries for a key are exhausted, rotate to the next key.
        """
        self._reset_key_index()

        for attempt in range(max_retries * len(self.api_keys)):
            # Throttle between requests
            time.sleep(self.request_delay)

            client = self._get_current_client()
            try:
                response = client.chat.completions.create(
                    messages=messages,
                    model="openai/gpt-oss-120b",
                    temperature=0.01,
                    max_tokens=3000
                )
                return response

            except Exception as e:
                error_str = str(e).lower()
                is_rate_limit = "rate_limit" in error_str or "429" in error_str or "rate limit" in error_str
                is_server_error = "500" in error_str or "502" in error_str or "503" in error_str

                if is_rate_limit:
                    print(f"      ⚠️ Rate limit hit on key #{self.current_key_index + 1}. ", end="")
                    if self._rotate_key():
                        print("Switching key and retrying...")
                        continue
                    else:
                        # All keys exhausted — wait and retry from the first key
                        wait_time = 10 * (attempt + 1)
                        print(f"All keys exhausted. Waiting {wait_time}s before retrying...")
                        time.sleep(wait_time)
                        self._reset_key_index()
                        continue

                elif is_server_error:
                    wait_time = 5 * (attempt + 1)
                    print(f"      ⚠️ Server error. Retrying in {wait_time}s... ({e})")
                    time.sleep(wait_time)
                    continue

                else:
                    # Non-retryable error
                    raise e

        raise RuntimeError("All Groq API retries and key rotations exhausted.")

    # ---------- Language Detection ----------

    def is_arabic(self, text):
        return bool(re.search(r'[\u0600-\u06FF]', str(text)))

    # ---------- Arabic News Processing ----------

    def process_arabic(self, title, content, company_name=None):
        entity_rule = ""
        if company_name:
            entity_rule = f"\n        تحذير إضافي: تأكد أن الخبر يخص بشكل صريح أو يؤثر على شركة/سهم ({company_name}). إذا كان الخبر لا يذكرها أو لا علاقة له بها، أو كان خبراً رياضياً بحتاً (مباريات/كرة قدم)، يجب أن تكتب False."
            
        prompt = f"""
        أنت آلة برمجية صارمة لتصفية وتصنيف البيانات الاقتصادية. لا تمتلك آراء شخصية. لا تقم بكتابة أي مقدمات أو نهايات أو تحليلات.

        === قواعد صارمة لتصفية الضوضاء (فلترة فقط، بدون تغيير) ===
        أنت فلتر (مُرشّح) وليس مُحرر. مهمتك هي اكتشاف وإزالة القمامة التقنية فقط مع الحفاظ على المحتوى الإخباري الأصلي كما هو تماماً.
        اكتشف وأزل تماماً أي عنصر من العناصر التالية:
        - كلام تقني عشوائي غير مفهوم (مثل أكواد HTML، CSS، JavaScript، أو أحرف مشوشة/محرّفة)
        - رسائل أخطاء سيرفر (مثل: "502 Bad Gateway", "404", "timeout", "server down", "503 error", "internal server error")
        - كلمات بلا معنى أو نصوص مكررة آلياً أو أحرف عشوائية
        - إعلانات، روابط، كلمات مفتاحية، جمل مثل "اقرأ أيضاً"
        تحذير حاسم: يُمنع منعاً باتاً إعادة صياغة أو تلخيص أو تغيير المحتوى الإخباري الحقيقي. أنت فلتر فقط: احذف القمامة وأبقِ الخبر الأصلي كما هو حرفياً.
        بعد حذف الضوضاء، إذا لم يتبقَ محتوى ذو معنى اقتصادي، اكتب VALID: False.

        === قواعد تصنيف سعر الصرف لجميع العملات الأجنبية (مهم جداً) ===
        أنت تحلل أخباراً من منظور الاقتصاد المصري. القاعدة تنطبق على جميع العملات الأجنبية الرئيسية وليس الدولار فقط:
        العملات المشمولة: الدولار الأمريكي (USD)، اليورو (EUR)، الجنيه الإسترليني (GBP)، الريال السعودي (SAR)، الدرهم الإماراتي (AED)، الدينار الكويتي (KWD)، وأي عملة أجنبية أخرى.
        - إذا ذكر الخبر أن أي عملة أجنبية تنخفض أو تتراجع أو تهبط مقابل الجنيه المصري (EGP)، أو أن الجنيه المصري يقوى أو يتحسن = خبر إيجابي (Positive).
        - إذا ذكر الخبر أن أي عملة أجنبية ترتفع أو تزداد مقابل الجنيه المصري، أو أن الجنيه المصري يضعف أو يتراجع = خبر سلبي (Negative).

        مهمتك محددة في 3 نقاط فقط:
        1. VALID: هل النص (بعد إزالة الضوضاء) يمثل خبراً مقروءاً ومفهوماً ومتعلقاً حصرياً بالاقتصاد، البورصة، الأسهم، أو أخبار الشركات؟ (True/False).
           يجب أن تكتب False إذا كان الخبر متعلقاً بـ: الرياضة (مثل كرة القدم، الأندية)، الفن، الحوادث، أو أي موضوع غير مالي.{entity_rule}
        2. SUMMARY: اكتب ملخصاً نظيفاً ومختصراً من سطرين فقط يصف جوهر الخبر الحقيقي (بعد إزالة الضوضاء). لا تُضف أي رأي أو تحليل.
        3. SENTIMENT: صنف الخبر (Positive أو Negative أو Neutral). طبّق قواعد سعر الصرف لجميع العملات الأجنبية أعلاه عند التصنيف.
        
        الخبر الأصلي:
        Title: {title}
        Content: {str(content)[:2500]}
        
        يجب أن يكون الرد حصرياً داخل هذا القالب، وبدون أي كلمة قبله أو بعده:
        [START]
        VALID: <True or False>
        SUMMARY: <ملخص من سطرين للخبر الحقيقي بدون الضوضاء>
        SENTIMENT: <Positive or Negative or Neutral>
        [END]
        """

        system_message = (
            "You are a strict noise-filtering and classification machine for financial news in the Egyptian economic context. "
            "ONLY output the requested format. NEVER add opinions or conversational text. "
            "Your job is to FILTER (remove garbage/errors/gibberish) — NOT to rewrite or paraphrase the real news content. "
            "When news mentions ANY foreign currency (USD, EUR, GBP, SAR, AED, KWD, etc.) dropping against EGP or EGP strengthening, that is POSITIVE. "
            "When ANY foreign currency rises against EGP or EGP weakens, that is NEGATIVE."
        )

        try:
            response = self._call_groq(
                messages=[
                    {"role": "system", "content": system_message},
                    {"role": "user", "content": prompt}
                ]
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
                
                summary_match = re.search(r'SUMMARY:\s*(.*?)(?=\n\s*SENTIMENT:)', data, re.DOTALL)
                
                is_valid = True if 'True' in valid_str else False
                clean_text = summary_match.group(1).strip() if summary_match else content
                
                return is_valid, sentiment, clean_text
                
            print(f"      ⚠️ Format Mismatch. Raw Output: {raw_text[:100]}...")
            return True, "Neutral", content
        except Exception as e:
            print(f"      ⚠️ Groq Arabic Error: {e}")
            return True, "Neutral", content

    # ---------- English News Processing (LLM) ----------

    def process_english_llm(self, title, content):
        prompt = f"""
        You are a strict noise-filtering and classification machine for financial news. No personal opinions. No introductions or conversational text.

        === STRICT NOISE REMOVAL (Filter Only — Do NOT Alter Valid Content) ===
        Before any analysis, scan the input and COMPLETELY REMOVE the following types of garbage:
        - Technical gibberish (random HTML/CSS/JS code, corrupted characters, encoding artifacts)
        - Server error messages (e.g., "502 Bad Gateway", "404 Not Found", "timeout", "internal server error")
        - Meaningless random text, auto-generated repetitive strings
        - Ads, links, SEO keywords, phrases like "Read also"
        CRITICAL: You are a FILTER, not an editor. Do NOT rewrite, paraphrase, or change the actual valid news content. Strip out the garbage and keep the genuine financial news exactly as it was written.
        After removing noise, if no meaningful financial content remains, write VALID: False.

        Your task is strictly limited to 3 points:
        1. VALID: Is the text (after noise removal) a readable news item EXCLUSIVELY related to economy, stock market, stocks, or corporate news? (True/False).
           Write False if the news is about: Sports (e.g., football/soccer, teams), Art/Entertainment, General accidents, or any non-financial topic.
        2. SUMMARY: Write a clean, concise 2-line summary of the real news content (after noise removal). Do NOT add any opinion or analysis.
        3. SENTIMENT: Classify the news (Positive, Negative, or Neutral).
        
        Original News:
        Title: {title}
        Content: {str(content)[:2500]}
        
        Response MUST be exclusively inside this template:
        [START]
        VALID: <True or False>
        SUMMARY: <Clean 2-line summary of the real news without noise>
        SENTIMENT: <Positive or Negative or Neutral>
        [END]
        """
        try:
            response = self._call_groq(
                messages=[
                    {"role": "system", "content": "You are a strict financial news noise-filter and classifier. ONLY output the requested format. FILTER out garbage — never rewrite valid content."},
                    {"role": "user", "content": prompt}
                ]
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
                
                summary_match = re.search(r'SUMMARY:\s*(.*?)(?=\n\s*SENTIMENT:)', data, re.DOTALL)
                is_valid = True if 'True' in valid_str else False
                clean_text = summary_match.group(1).strip() if summary_match else content
                return is_valid, sentiment, clean_text
                
            print(f"      ⚠️ Format Mismatch. Raw Output: {raw_text[:100]}...")
            return True, "Neutral", content
        except Exception as e:
            print(f"      ⚠️ Groq English Error: {e}")
            return True, "Neutral", content

    # ---------- English News Processing (FinBERT Fallback) ----------

    def process_english(self, title, content):
        # Fallback to FinBERT if LLM fails or for sentiment only if needed
        text_to_analyze = f"{title}. {content}"
        try:
            result = self.finbert(text_to_analyze)[0]
            return result['label'].capitalize()
        except Exception as e:
            print(f"      ⚠️ FinBERT Error: {e}")
            return "Neutral"