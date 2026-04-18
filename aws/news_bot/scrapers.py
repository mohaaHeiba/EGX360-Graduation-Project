import re
from bs4 import BeautifulSoup

class NewsScraper:
    def __init__(self):
        self.SCRAPERS_MAP = {
            "vetogate.com": self.scrape_vetogate,
            "almasryalyoum.com": self.scrape_almasryalyoum,
            "fintechgate.net": self.scrape_fintechgate,
            "masrawy.com": self.scrape_masrawy,
            "masrtimes.com": self.scrape_masrtimes,
            "mubasher.info": self.scrape_mubasher,
            "amwalalghad.com": self.scrape_amwalalghad,
            "arabfinance.com": self.scrape_arabfinance,
            "petro-news.com": self.scrape_petronews,
            "youm7.com": self.scrape_youm7,
            "msn.com": self.scrape_msn,
            "alboslanews.com": self.scrape_alboslanews,
            "almalnews.com": self.scrape_almalnews,
            "ahram.org.eg": self.scrape_ahram,
            "dostor.org": self.scrape_dostor,
            "alborsaanews.com": self.scrape_alborsaanews,
            "coingape.com": self.scrape_coingape, 
            "coindesk.com": self.scrape_coindesk,
            "cointelegraph.com": self.scrape_cointelegraph,
            "cryptoslate.com": self.scrape_cryptoslate
        }

    def clean_html(self, html_content):
        if not html_content: return ""
        soup = BeautifulSoup(html_content, "html.parser")
        return soup.get_text(separator="\n").strip()

    def clean_and_validate_content(self, text, description, title):
        if not text:
            text = ""
            
        bot_protection_phrases = [
            "This website uses a security service", "protect against malicious bots",
            "verifies you are not a bot", "Enable JavaScript and cookies to continue",
            "Performance and Security by", "Verification successful"
        ]
        
        if any(phrase.lower() in text.lower() for phrase in bot_protection_phrases):
            print("      🛡️ Cloudflare Bot Protection detected! Falling back to description.")
            text = ""

        if len(text) < 20:
            cleaned_desc = self.clean_html(description) if description else ""
            return "" if cleaned_desc.strip() == title.strip() else cleaned_desc

        text = re.sub(r'<[^>]+>', '', text)
        
        stop_markers = [
            r"جريدة المال هي جريدة", r"تقدم تغطية شاملة لآخر أخبار", r"إيكونومي بلس عبر واتس اب", 
            r"اضغط هنا", r"حقوق النشر محفوظة", r"مواضيع متعلقة", r"اقرأ أيضاً", r"إقرأ أيضاً", 
            r"قد يعجبك أيضاً", r"الأكثر قراءة", r"©", r"تم التصميم والتطوير", r"كلمات دالة",
            r"تابعوا آخر أخبار اليوم السابع", r"أرشيفية\s*:\s*مشاركة الخبر"
        ]
        
        for marker in stop_markers:
            if re.search(marker, text, flags=re.IGNORECASE):
                parts = re.split(marker, text, flags=re.IGNORECASE)
                text = parts[0]

        if title and title.strip() in text[:150]:
            text = text.replace(title.strip(), "", 1).strip()

        text = re.sub(r'(?<!\d)\.(?!\d)\s+([أ-ي])', r'.\n\n\1', text)

        junk_patterns = [
            r"(Facebook|Twitter|Pinterest|Linkedin|Whatsapp|Telegram|Email)", 
            r"بواسطة\s*[:\s]*[\w\s]+", r"كتبت?\s*[:\s]*[\w\s]+",   
            r"\d+\s*:\s*\d+\s*(م|ص)", r"الرابط المختصر.*", r"\|\s*\|\s*[\w-]+",
            r"جميع الحقوق محفوظة", r"النشر\s*\d+", r"00:00\s*/\s*00:16"
        ]
        for pattern in junk_patterns:
            text = re.sub(pattern, '', text, flags=re.IGNORECASE)

        lines = text.split('\n')
        cleaned_lines = []
        seen_lines = set() 
        important_keywords = ["سعر", "جنيه", "سهم", "بورصة", "ارباح", "تراجع", "ارتفاع", "حديد", "بنك", "أسمدة", "صفقة"]
        
        for line in lines:
            line = line.strip()
            if not line or len(line) < 3: continue
            line_mini = line[:60].lower()
            if line_mini in seen_lines: continue

            has_numbers = any(char.isdigit() for char in line)
            has_finance = any(key in line for key in important_keywords)
            is_list = bool(re.match(r'^(\d+[\.\-\)]|•|\*)', line))
            
            if len(line.split()) > 3 or has_numbers or has_finance or is_list or len(line) > 40:
                cleaned_lines.append(line)
                seen_lines.add(line_mini)
                
        text = '\n\n'.join(cleaned_lines)
        text = re.sub(r'[ \t]+', ' ', text)
        text = re.sub(r'\n\s*\n', '\n\n', text)
        return text.strip()

    def is_blacklisted(self, url, title=""):
        url_lower = url.lower()
        bad_domains = ["facebook.com", "twitter.com", "instagram.com", "youtube.com", "google.com/search",
                       "asharqbusiness.com","akher.news","fath-news.com","belbalady.net","belbalady","asharqbusiness"]
        for domain in bad_domains:
            if domain in url_lower: 
                return True
                
        if title:
            bad_title_patterns = ["كود الترقيم", "الشركةاسم", "نموذج تقرير إفصاح", "EFG HOLDING", "إفصاح مكمل"]
            for pattern in bad_title_patterns:
                if pattern in title:
                    print(f"      🚫 Skipped: Raw Exchange Disclosure (Bad Title)")
                    return True
                    
        if "consent.google.com" in url: return True
        crypto_junk = ["sponsored", "press-release", "advertise"]
        if any(junk in url.lower() for junk in crypto_junk): return True
        return False

    def extract_smart_content(self, url, html_content):
        url_lower = url.lower()

        if "arabfinance.com" in url_lower and "companyprofile" in url_lower:
            print(f"      🚫 Skipped: Arab Finance Data Page")
            return None
        
        soup = BeautifulSoup(html_content, "html.parser")
        
        og_type = soup.find("meta", property="og:type")
        if og_type and og_type.get("content") == "website":
            if not any(word in url_lower for word in ['story', 'news', 'details', '2026', 'amp', 'article']):
                print(f"      🚫 Skipped: Generic website page (Not an article)")
                return None

        for domain, scraper_func in self.SCRAPERS_MAP.items():
            if domain in url:
                extracted_text = scraper_func(soup)
                if extracted_text:
                    print(f"      🎯 Custom Scraper Used: {domain}")
                    return extracted_text
                else:
                    return None
                    
        print(f"      🔄 Using General Fallback Scraper (Strict Cleaning)...")
        
        tags_to_kill = ['header', 'footer', 'nav', 'aside', 'figcaption', 'title', 'meta', 'script', 'style', 'button']
        for tag in soup.find_all(tags_to_kill):
            tag.decompose()
            
        junk_regex = re.compile(r'(related|widget|ad|social|share|tags|comments|login|auth|popup|modal|form|paywall|subscription|subscribe|register)', re.IGNORECASE)
        for tag in soup.find_all(class_=junk_regex):
            tag.decompose()
            
        text_parts = []
        seen_paragraphs = set() 
        
        forbidden_lines = [
            'login', 'password', 'sign in', 'username', 'reset your password', 
            'اشترك الآن', 'سجل الدخول', 'محتوى للمشتركين', 'النسخة الرقمية',
            'visibility - public', 'enter your username'
        ]
        
        for tag in soup.find_all(['p', 'h1', 'h2', 'h3']):
            text = tag.get_text(separator=" ").strip()
            
            if any(word in text.lower() for word in forbidden_lines):
                continue
                
            if text:
                if text not in seen_paragraphs or len(text) < 35:
                    seen_paragraphs.add(text)
                    text_parts.append(text)
                    
        final_text = "\n\n".join(text_parts)
        return final_text if len(final_text) > 150 else None

    # ==================== Custom Scrapers ====================
    def scrape_vetogate(self, soup):
        content_div = soup.find('div', class_='paragraph-list')
        if not content_div: return None 
        for tag in content_div.find_all(['figure', 'script', 'style']): tag.decompose()
        text = content_div.get_text(separator="\n\n").strip()
        return re.sub(r'\n\s*\n', '\n\n', text)

    def scrape_almasryalyoum(self, soup):
        content_div = soup.find('div', id='NewsStory') or soup.find('div', class_='article-body')
        if not content_div: content_div = soup
        junk_classes = ['related-article-inside-body', 'article-body-ad', 'no-print']
        for junk in junk_classes:
            for tag in content_div.find_all('div', class_=junk): tag.decompose()
        for tag in content_div.find_all(['script', 'style']): tag.decompose()
        for p_tag in content_div.find_all('p'):
            a_tag = p_tag.find('a')
            if a_tag and p_tag.get_text(strip=True) == a_tag.get_text(strip=True): p_tag.decompose()
        text_parts = []
        for tag in content_div.find_all(['p', 'h1', 'h2', 'h3']):
            text = tag.get_text(separator=" ").strip()
            if text and text != "قد يهمك": text_parts.append(text)
        final_text = "\n\n".join(text_parts)
        final_text = re.sub(r'\n\s*\n', '\n\n', final_text)
        return final_text if len(final_text) > 100 else None

    def scrape_fintechgate(self, soup):
        content_div = soup.find('div', id='penci-post-entry-inner') or soup.find('div', class_='inner-post-entry')
        if not content_div: return None
        junk_classes = ['code-block', 'penci-custom-html-inside-content', 'penci-ilrltpost-beaf', 'shorten_url', 'post-tags', 'penci-single-link-pages']
        for junk in junk_classes:
            for tag in content_div.find_all('div', class_=junk): tag.decompose()
        for tag in content_div.find_all(['style', 'script']): tag.decompose()
        for h4 in content_div.find_all(['h4', 'h3', 'p']):
            if 'روابط ذات صلة' in h4.get_text():
                next_node = h4.find_next_sibling()
                if next_node and next_node.name == 'ul': next_node.decompose()
                h4.decompose()
        text_parts = [tag.get_text(separator=" ").strip() for tag in content_div.find_all(['p', 'h1', 'h2', 'h3', 'h4']) if tag.get_text(separator=" ").strip()]
        final_text = "\n\n".join(text_parts)
        return re.sub(r'\n\s*\n', '\n\n', final_text) if len(final_text) > 100 else None

    def scrape_masrawy(self, soup):
        content_div = soup.find('div', class_='ArticleDetails details')
        if not content_div: return None
        for tag in content_div.find_all('section', class_='pattern01'): tag.decompose()
        text_parts = []
        for tag in content_div.find_all(['p', 'h1', 'h2', 'h3']):
            text = tag.get_text(separator=" ").strip()
            if "اقرأ أيضًا" in text or "اقرأ أيضا" in text: continue
            a_tag = tag.find('a')
            if a_tag and tag.get_text(strip=True) == a_tag.get_text(strip=True): continue
            if text: text_parts.append(text)
        final_text = "\n\n".join(text_parts)
        return re.sub(r'\n\s*\n', '\n\n', final_text) if len(final_text) > 100 else None

    def scrape_masrtimes(self, soup):
        content_div = soup.find('div', class_='paragraph-list')
        if not content_div: return None
        for tag in content_div.find_all(['figure', 'img', 'figcaption', 'script', 'style']): tag.decompose()
        text_parts = [tag.get_text(separator=" ").strip() for tag in content_div.find_all(['p', 'h2', 'h3', 'li']) if tag.get_text(separator=" ").strip()]
        final_text = "\n\n".join(text_parts)
        return re.sub(r'\n\s*\n', '\n\n', final_text) if len(final_text) > 100 else None

    def scrape_mubasher(self, soup):
        content_div = soup.find('div', itemprop='articleBody')
        if not content_div: return None
        junk_classes = ['mi-article__stocks', 'outstream-ad-container', 'stock-price-block']
        for junk in junk_classes:
            for tag in content_div.find_all('div', class_=junk): tag.decompose()
        text_parts = [tag.get_text(separator=" ").strip() for tag in content_div.find_all(['p', 'h2', 'h3']) if tag.get_text(separator=" ").strip()]
        return "\n\n".join(text_parts) if len(text_parts) > 1 else None

    def scrape_amwalalghad(self, soup):
        content_div = soup.find('div', id='penci-post-entry-inner') or soup.find('div', class_='inner-post-entry')
        if not content_div: return None
        junk_classes = ['penci-ilrltpost-insert', 'shorten_url', 'post-tags', 'penci-single-link-pages', 'penci-post-countview-number-check', 'penci-google-adsense-1']
        for junk in junk_classes:
            for tag in content_div.find_all(['div', 'i'], class_=junk): tag.decompose()
        for tag in content_div.find_all(['style', 'script']): tag.decompose()
        text_parts = [tag.get_text(separator=" ").strip() for tag in content_div.find_all(['p', 'h2', 'h3']) if tag.get_text(separator=" ").strip()]
        final_text = "\n\n".join(text_parts)
        return re.sub(r'\n\s*\n', '\n\n', final_text) if len(final_text) > 100 else None

    def scrape_arabfinance(self, soup):
        content_div = soup
        junk_classes = ['details-tags', 'video-section-title', 'news-single-category']
        for junk in junk_classes:
            for tag in content_div.find_all('div', class_=re.compile(junk)): tag.decompose()
        for tag in content_div.find_all('div', id=re.compile(r'^div-gpt-ad')): tag.decompose()
        for tag in content_div.find_all(['style', 'script']): tag.decompose()
        text_parts = [tag.get_text(separator=" ").strip() for tag in content_div.find_all(['p', 'h2', 'h3']) if tag.get_text(separator=" ").strip()]
        final_text = "\n\n".join(text_parts)
        return re.sub(r'\n\s*\n', '\n\n', final_text) if len(final_text) > 100 else None

    def scrape_petronews(self, soup):
        content_div = soup.find('div', class_='entry-content entry')
        if not content_div: return None
        junk_classes = ['post-views', 'post-shortlink', 'share-buttons', 'about-author', 'post-components', 'related-posts']
        for junk in junk_classes:
            for tag in content_div.find_all('div', class_=re.compile(junk)): tag.decompose()
        for tag in content_div.find_all(['figure', 'img', 'script', 'style']): tag.decompose()
        text_parts = [tag.get_text(separator=" ").strip() for tag in content_div.find_all(['p', 'h2', 'h3']) if tag.get_text(separator=" ").strip() and not tag.get_text().startswith("مصدر الخبر:")]
        final_text = "\n\n".join(text_parts)
        return re.sub(r'\n\s*\n', '\n\n', final_text) if len(final_text) > 100 else None

    def scrape_msn(self, soup):
        content_div = soup.find('div', class_='article-content') or soup.find('cp-article') or soup
        if not content_div: return None
        for tag in content_div.find_all(['display-ads', 'figcaption', 'script', 'style']): tag.decompose()
        text_parts, seen = [], set()
        for tag in content_div.find_all(['p', 'h2', 'h3']):
            text = tag.get_text(separator=" ").strip()
            if text and text not in seen:
                seen.add(text)
                text_parts.append(text)
        final_text = "\n\n".join(text_parts)
        return final_text if len(final_text) > 100 else None

    def scrape_youm7(self, soup):
        content_div = soup.find('div', id='articleBody') or soup.find('div', class_='articleCont') or soup.find('div', class_='article-body')
        if not content_div: return None
        junk_classes = ['tags', 'writeBy', 'wirte-by', 'img-text', 'breadcumb', 'social-share-bar']
        for junk in junk_classes:
            for tag in content_div.find_all('div', class_=re.compile(junk, re.IGNORECASE)): tag.decompose()
        for tag in content_div.find_all(['script', 'style', 'img', 'figure', 'amp-img', 'center']): tag.decompose()
        for a_tag in content_div.find_all('a'):
            link_text = a_tag.get_text(strip=True)
            if "Google News" in link_text or "واتساب" in link_text: a_tag.decompose()
        for tag in content_div.find_all('div', id=re.compile(r'taboola|div-gpt-ad')): tag.decompose()
        for tag in content_div.find_all(['span', 'div'], class_=re.compile(r'writeBy|wirte-by|news-date')): tag.decompose()
        text_parts = [tag.get_text(separator=" ").strip() for tag in content_div.find_all(['p', 'h2', 'h3']) if tag.get_text(separator=" ").strip()]
        final_text = "\n\n".join(text_parts)
        return re.sub(r'\n\s*\n', '\n\n', final_text) if len(final_text) > 100 else None

    def scrape_alboslanews(self, soup):
        content_div = soup.find('div', class_='news-content')
        if not content_div: return None
        for tag in content_div.find_all(['script', 'style', 'img']): tag.decompose()
        final_text = content_div.get_text(separator="\n\n").strip()
        return re.sub(r'\n\s*\n', '\n\n', final_text) if len(final_text) > 100 else None

    def scrape_almalnews(self, soup):
        content_div = soup.find('div', class_='article-content')
        if not content_div: return None
        junk_selectors = ['div.paywall-container', 'div.subscription-card', 'div.google-news-bar', 'div.news-side-column', 'div.read-more', 'div.card-more', 'div.ad-banner']
        for selector in junk_selectors:
            for tag in content_div.select(selector): tag.decompose()
        for tag in content_div.find_all(['script', 'style', 'img', 'figure', 'iframe']): tag.decompose()
        text_parts = []
        forbidden_words = ["اشترك الآن", "سجل الدخول", "محتوى للمشتركين", "النسخة الرقمية", "Google News"]
        for tag in content_div.find_all(['p', 'h2', 'h3']):
            text = tag.get_text(separator=" ").strip()
            if any(word in text for word in forbidden_words): continue
            if text and len(text) > 10: text_parts.append(text)
        final_text = "\n\n".join(text_parts)
        return final_text if len(final_text) > 100 else None

    def scrape_ahram(self, soup):
        content_div = soup.find('div', id='ContentPlaceHolder1_divContent')
        if not content_div: return None
        for tag in content_div.find_all('div'):
            if "موضوعات مقترحة" in tag.get_text():
                next_row = tag.find_next_sibling('div', class_='row')
                if next_row: next_row.decompose()
                tag.decompose()
        for tag in content_div.find_all(['script', 'style', 'img', 'figure', 'span']):
            if tag.name == 'span' and 'text_list' in tag.get('class', []): continue
            tag.decompose()
        text_parts = [tag.get_text(separator=" ").strip() for tag in content_div.find_all(['p', 'h2', 'h3']) if tag.get_text(separator=" ").strip()]
        final_text = "\n\n".join(text_parts)
        return re.sub(r'\n\s*\n', '\n\n', final_text) if len(final_text) > 100 else None

    def scrape_dostor(self, soup):
        content_div = soup.find('div', class_='paragraph-list') or soup.find('article', class_='cont')
        if not content_div: return None
        junk_classes = ['adfull', 'keywords', 'share-top', 'share-bottom', 'publish', 'author']
        for junk in junk_classes:
            for tag in content_div.find_all(['div', 'ul'], class_=re.compile(junk, re.IGNORECASE)): tag.decompose()
        for tag in content_div.find_all(['figure', 'script', 'style', 'nav']): tag.decompose()
        text_parts = []
        for tag in content_div.find_all(['p', 'h1', 'h2', 'h3', 'strong']):
            text = tag.get_text(separator=" ").strip()
            if "اقرأ أيضًا" in text or "اقرأ ايضا" in text: break
            if text and len(text) > 5: text_parts.append(text)
        final_text = "\n\n".join(text_parts)
        return re.sub(r'\n\s*\n', '\n\n', final_text) if len(final_text) > 100 else None

    def scrape_alborsaanews(self, soup):
        subtitle = soup.find('h2', class_='jeg_post_subtitle')
        subtitle_text = subtitle.get_text(strip=True) if subtitle else ""
        content_div = soup.find('div', class_='content-inner')
        if not content_div: return None
        junk_classes = ['jnews_inline_related_post_wrapper', 'jeg_ad', 'jeg_post_tags', 'jeg_ad_module']
        for junk in junk_classes:
            for tag in content_div.find_all('div', class_=junk): tag.decompose()
        for tag in content_div.find_all(['script', 'style', 'img', 'figure', 'amp-img']): tag.decompose()
        text_parts = []
        if subtitle_text: text_parts.append(subtitle_text)
        for tag in content_div.find_all(['p', 'h2', 'h3']):
            text = tag.get_text(separator=" ").strip()
            if any(msg in text for msg in ["واتس اب اضغط هنا", "تليجرام اضغط هنا", "لمتابعة أخر الأخبار"]): continue
            if text: text_parts.append(text)
        final_text = "\n\n".join(text_parts)
        return final_text if len(final_text) > 100 else None

    def scrape_coingape(self, soup):
        content_div = soup.find('div', class_='c-content') or soup.find('div', class_='main')
        if not content_div: return None
        junk_selectors = ['div.ads-container', 'div.highlight-ad-section', 'section#faq', 'div.keyfeatures', 'div.googlenewsbtn-contreloer']
        for selector in junk_selectors:
            for tag in content_div.select(selector): tag.decompose()
        for tag in content_div.find_all(['script', 'style', 'img', 'figure', 'button']): tag.decompose()
        text_parts = []
        for tag in content_div.find_all(['p', 'h2', 'h3']):
            text = tag.get_text(separator=" ").strip()
            if "Investment disclaimer" in text or "Ad Disclosure" in text: continue
            if text: text_parts.append(text)
        final_text = "\n\n".join(text_parts)
        return final_text if len(final_text) > 200 else None

    def scrape_coindesk(self, soup):
        content_div = soup.find('div', class_='common-stylestext-wrapper') or soup.find('article')
        if content_div:
            for tag in content_div.find_all(['aside', 'script', 'style']): tag.decompose()
            return content_div.get_text(separator="\n\n").strip()
        return None

    def scrape_cointelegraph(self, soup):
        content_div = soup.find('div', class_='post-content')
        if content_div:
            for tag in content_div.find_all(['div', 'script', 'style'], class_=re.compile(r'related|ad|promo')): tag.decompose()
            return content_div.get_text(separator="\n\n").strip()
        return None

    def scrape_cryptoslate(self, soup):
        content_div = soup.find('article', class_='post-column')
        if content_div:
            return content_div.get_text(separator="\n\n").strip()
        return None