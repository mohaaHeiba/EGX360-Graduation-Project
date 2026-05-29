import feedparser
from urllib.parse import quote

def test_query(query):
    print(f"\nTesting Query: {query}")
    url = f"https://news.google.com/rss/search?q={quote(query)}&hl=ar&gl=EG&ceid=EG:ar"
    feed = feedparser.parse(url)
    print(f"Found {len(feed.entries)} entries.")
    for entry in feed.entries[:2]:
        print(" -", entry.title)

# Exact match (what we have now)
test_query('"أبوقير للأسمدة" AND (سهم OR بورصة OR أرباح OR تداول OR اقتصاد OR جنيه) when:5d')

# Fuzzy match without quotes
test_query('أبوقير للأسمدة (سهم OR بورصة OR أرباح OR تداول OR اقتصاد OR جنيه) when:5d')

# Even fuzzier
test_query('ابو قير للاسمدة (سهم OR بورصة OR أرباح OR تداول OR اقتصاد OR جنيه) when:5d')
