import feedparser
from urllib.parse import quote

def test_query(query):
    print(f"\nTesting Query: {query}")
    url = f"https://news.google.com/rss/search?q={quote(query)}&hl=en-US&gl=US&ceid=US:en"
    feed = feedparser.parse(url)
    print(f"Found {len(feed.entries)} entries.")
    for entry in feed.entries[:2]:
        print(" -", entry.title)

# Current exact query:
test_query('"إعمار مصر" OR "EMFD" AND (stock OR market OR finance OR earnings OR trading) when:5d')

# Fixed query with parentheses
test_query('("إعمار مصر" OR "EMFD") AND (stock OR market OR finance OR earnings OR trading) when:5d')

# Fixed query without quotes around symbol
test_query('EMFD (stock OR market OR finance OR earnings OR trading) when:5d')
