import os
from dotenv import load_dotenv

# ==============================================================================
# 1. Config & Initialization
# ==============================================================================


# service_account
# base_path = os.path.dirname(os.path.abspath(__file__))

SERVICE_ACCOUNT_PATH = os.path.join(os.path.dirname(__file__), '..', 'service_account.json')


# env variables
env_path = os.path.join(os.path.dirname(__file__), '..', '.env')

load_dotenv(dotenv_path=env_path)

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
FINNHUB_API_KEY = os.getenv("FINNHUB_API_KEY")


# crypto feeds
CRYPTO_FEEDS = [
    "https://www.coindesk.com/arc/outboundfeeds/rss/",
    "https://cointelegraph.com/rss",
    "https://coingape.com/feed/",
    "https://cryptoslate.com/feed/"
]