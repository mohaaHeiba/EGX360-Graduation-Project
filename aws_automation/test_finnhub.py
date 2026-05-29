import requests
import datetime

FINNHUB_API_KEY = "d832og1r01ql4ong2vlgd832og1r01ql4ong2vm0"
SYMBOL = "AAPL"

def test_finnhub_news():
    today = datetime.datetime.now().strftime("%Y-%m-%d")
    yesterday = (datetime.datetime.now() - datetime.timedelta(days=1)).strftime("%Y-%m-%d")

    url = f"https://finnhub.io/api/v1/company-news?symbol={SYMBOL}&from={yesterday}&to={today}&token={FINNHUB_API_KEY}"
    
    print(f"🚀 Fetching direct news for {SYMBOL} from Finnhub API...")
    response = requests.get(url)
    
    if response.status_code != 200:
        print(f"❌ Error: HTTP {response.status_code}")
        print(response.text)
        return

    news_data = response.json()
    
    if not news_data:
        print("⚠️ No news found for this date range.")
        return

    print(f"✅ Found {len(news_data)} news articles. Showing the 5 most recent:\n")
    print("-" * 80)
    
    for index, article in enumerate(news_data[:5], 1):
        headline = article.get("headline")
        summary = article.get("summary")
        article_url = article.get("url")
        unix_timestamp = article.get("datetime")
        
        pub_time = datetime.datetime.fromtimestamp(unix_timestamp).strftime('%Y-%m-%d %H:%M:%S')
        
        print(f"[{index}] 🕒 Time: {pub_time}")
        print(f"     📰 Headline: {headline}")
        print(f"     📝 Summary:  {summary[:200]}..." if summary and len(summary) > 200 else f"     📝 Summary:  {summary}")
        print(f"     🔗 URL:      {article_url}")
        print("-" * 80)

if __name__ == "__main__":
    test_finnhub_news()