import firebase_admin
from firebase_admin import credentials, messaging
from supabase import create_client, Client
from difflib import SequenceMatcher
import re
import config

class DatabaseManager:
    def __init__(self):
        print("🔌 Connecting to Supabase and Firebase...")
        self.supabase: Client = create_client(config.SUPABASE_URL, config.SUPABASE_KEY)
        
        if not firebase_admin._apps:
            try:
                cred = credentials.Certificate(config.SERVICE_ACCOUNT_PATH)
                firebase_admin.initialize_app(cred)
            except Exception as e: 
                print(f"⚠️ Firebase Init Error: {e}")

    def get_all_stocks(self):
        return self.supabase.table("stocks").select("*").execute().data

    def is_url_duplicate(self, stock_id, url):
        check = self.supabase.table("stock_news").select("id").eq("url", url).eq("stock_id", stock_id).execute()
        return bool(check.data)

    def is_title_duplicate(self, stock_id, new_title):
        try:
            res = self.supabase.table("stock_news").select("title").eq("stock_id", stock_id).order("created_at", desc=True).limit(15).execute()
            if not res.data: return False
            
            clean_new = re.sub(r'[^\w\s]', '', new_title).strip().lower()
            
            for news in res.data:
                clean_old = re.sub(r'[^\w\s]', '', news['title']).strip().lower()
                
                if clean_new == clean_old: return True
                
                similarity = SequenceMatcher(None, clean_new, clean_old).ratio()
                if similarity > 0.80: return True
                    
                words_new = set(clean_new.split())
                words_old = set(clean_old.split())
                common_words = words_new.intersection(words_old)
                if len(common_words) / max(len(words_new), 1) > 0.85:
                    return True
            return False
        except: return False

    def insert_news(self, data):
        try:
            self.supabase.table("stock_news").insert(data).execute()
            return True   
        
        except Exception as e:
            print(f"      ❌ DB Insert Skipped (Constraint/Duplicate)")
            return False    

    def send_notification(self, symbol, news_title, news_url):
        try:
            res = self.supabase.table("user_watchlist").select("profiles(fcm_token)").eq("stock_symbol", symbol).execute()
            tokens = list(set([i['profiles']['fcm_token'] for i in res.data if i.get('profiles') and i['profiles'].get('fcm_token')]))
            if not tokens: return
            message = messaging.MulticastMessage(
                notification=messaging.Notification(title=f"📢 {symbol} News", body=news_title[:100]+"..."),
                android=messaging.AndroidConfig(priority='high', notification=messaging.AndroidNotification(sound='default', channel_id='stock_news')),
                data={'type': 'stock_news', 'symbol': symbol, 'url': news_url},
                tokens=tokens
            )
            messaging.send_each_for_multicast(message)
            print(f"      🔔 Notification sent to {len(tokens)} users")
        except Exception as e:
            print(f"      ⚠️ Notification Error: {e}")