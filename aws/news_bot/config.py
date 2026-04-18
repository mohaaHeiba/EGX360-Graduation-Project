import os
from dotenv import load_dotenv

# ==============================================================================
# 1. Config & Initialization
# ==============================================================================


# service_account
base_path = os.path.dirname(os.path.abspath(__file__))
SERVICE_ACCOUNT_PATH = os.path.join(base_path, "service_account.json")


# env variables
env_path = os.path.join(os.path.dirname(__file__), '..', '.env')

load_dotenv(dotenv_path=env_path)

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
CEREBRAS_APIKEY=os.getenv("CEREBRAS_APIKEY")


# crypto feeds
CRYPTO_FEEDS = [
    "https://www.coindesk.com/arc/outboundfeeds/rss/",
    "https://cointelegraph.com/rss",
    "https://coingape.com/feed/",
    "https://cryptoslate.com/feed/"
]