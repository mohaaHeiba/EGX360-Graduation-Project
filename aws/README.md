# ☁️ AWS Backend Services

This directory contains all the **server-side scrapers and bots** that run on an AWS EC2 instance (`ubuntu@51.21.191.162`). These services collect real-time financial data from various sources and push it to **Supabase** (database) and **Firebase Cloud Messaging** (push notifications).

---

## 📁 Project Structure

```
aws/
├── commands.txt                  # SSH & SCP quick-reference commands
├── MyNewsBotKey.pem              # EC2 SSH private key
├── market_status/                # EGX market summary scraper
│   └── market_status.py
├── materails_local_pricing/      # Gold & silver price tracker
│   ├── local_gold_scraper.py
│   ├── service_account.json      # Firebase service account credentials
│   └── temp/
├── news_bot/                     # Stock & crypto news aggregator
│   ├── news_scraper.py
│   ├── service_account.json
│   ├── news_test.log
│   └── venv/                     # Python virtual environment
├── stocks_scraper/               # Real-time EGX candle data scraper
│   ├── run.sh                    # Launches all candle scrapers in parallel
│   ├── settings/
│   │   ├── config.py             # Supabase & TradingView credentials
│   │   └── utils.py              # Cairo timezone & market-hours helper
│   └── egx_candles/              # Per-stock candle scrapers (16 scripts)
│       ├── abuk_candle.py
│       ├── comi_candle.py
│       ├── egx30_candle.py
│       ├── egx70ewi_candle.py
│       └── ... (12 more)
```

---

## 🧩 Services Overview

### 1. 📊 Market Status (`market_status/`)

**Purpose:** Scrapes the **Egyptian Exchange (EGX)** homepage for daily market summary data.

| Detail | Value |
|---|---|
| **Source** | [egx.com.eg](https://www.egx.com.eg/ar/homepage.aspx) |
| **Data Collected** | Market Cap, Value Traded |
| **DB Table** | `market_history` |
| **Method** | Selenium (Undetected ChromeDriver) |

**How it works:**
- Launches a headless Chrome browser via `undetected_chromedriver` to bypass bot detection.
- Extracts **Market Cap** and **Value Traded** from the EGX homepage.
- Formats large numbers into human-readable strings (e.g., `2.45T EGP`, `1.23B EGP`).
- Performs an **upsert** on the `market_history` table — updates if a record for today exists, otherwise inserts a new one.

**Key Dependencies:** `undetected-chromedriver`, `selenium`, `webdriver-manager`, `supabase`

---

### 2. 🥇 Materials Local Pricing (`materails_local_pricing/`)

**Purpose:** Tracks **local Egyptian gold and silver prices** and sends push notifications when significant price changes occur.

| Detail | Value |
|---|---|
| **Source** | [SafeHavenHub](https://safehavenhub.com) |
| **Data Collected** | Gold (24K, 21K, 18K), Silver (999, 925) |
| **DB Table** | `material_prices` |
| **Notifications** | Firebase Cloud Messaging (FCM) |
| **Alert Threshold** | ±10 EGP change on 21K gold |

**How it works:**
1. Scrapes gold & silver prices from SafeHavenHub using `requests` + `BeautifulSoup`.
2. Compares the new 21K gold price against the latest entry in the database.
3. If the price change exceeds the threshold (10 EGP), sends a **bulk FCM push notification** to all users with registered FCM tokens.
4. Inserts the new price record into the `material_prices` table.

**Key Dependencies:** `requests`, `beautifulsoup4`, `firebase-admin`, `supabase`

---

### 3. 📰 News Bot (`news_bot/`)

**Purpose:** Aggregates financial news for **EGX stocks** and **cryptocurrencies**, with intelligent duplicate detection and targeted push notifications.

| Detail | Value |
|---|---|
| **Stock Sources** | Google News RSS (Arabic, filtered per stock) |
| **Crypto Sources** | CoinTelegraph RSS, CoinDesk RSS |
| **DB Table** | `stock_news` |
| **Notifications** | FCM (per-stock watchlist subscribers) |
| **Duplicate Detection** | 70% title similarity threshold (SequenceMatcher) |

**How it works:**

**Stock Engine:**
1. Loads all stocks from the `stocks` table in Supabase.
2. For each stock, builds a smart Arabic search query and fetches results from Google News RSS.
3. Resolves shortened Google News URLs using Selenium to get the actual article link.
4. Extracts full article content using `trafilatura`.
5. Checks for duplicates via both **exact URL match** and **70% title similarity** before saving.
6. Sends targeted FCM notifications to users who have the stock in their watchlist.

**Crypto Engine:**
1. Fetches entries from CoinTelegraph and CoinDesk RSS feeds.
2. Matches articles to tracked cryptocurrencies by name/symbol.
3. Saves matched articles to the database with source attribution.

**Anti-Spam Features:**
- Blacklisted domains (social media, search engines) are automatically skipped.
- Garbage content detection (CAPTCHA pages, 404s, JS-disabled pages).
- Freshness filter: only articles from the last 2–3 days are processed.

**Key Dependencies:** `feedparser`, `trafilatura`, `selenium`, `beautifulsoup4`, `firebase-admin`, `supabase`, `python-dateutil`

---

### 4. 📈 Stocks Scraper (`stocks_scraper/`)

**Purpose:** Streams **real-time candlestick data** (1-minute & daily) for EGX stocks and indices from TradingView.

| Detail | Value |
|---|---|
| **Source** | TradingView (via `tvDatafeed`) |
| **Timeframes** | 1-minute, 1-day |
| **Update Interval** | Every 20 seconds during market hours |
| **Market Hours** | Sun–Thu, 10:00 AM – 2:46 PM (Cairo time) |

**Tracked Symbols (15):**

| Stocks | Indices |
|---|---|
| ABUK, COMI, EAST, EFIH, EMFD | EGX30 |
| ETEL, EXPA, FWRY, HRHO, IRON | EGX70EWI |
| ORAS, SWDY, TMGH | |

**How it works:**
1. On startup, performs an **initial catch-up** by fetching 300 one-minute bars and 5 daily bars.
2. During market hours, polls TradingView every 20 seconds for the latest candle data.
3. Applies **noise filters** before saving:
   - Volume must be > 0
   - Timestamps must fall within market session hours
   - Low ≤ High and prices > 0 (sanity checks)
4. On market close, performs a final sync to capture end-of-day data.
5. Each stock has its own Supabase table (e.g., `abuk_candles`, `comi_candles`).

**Key Dependencies:** `tvDatafeed`, `pandas`, `pytz`, `supabase`

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| **Python 3** | All scrapers are written in Python |
| **Supabase** | PostgreSQL backend (data storage & queries) |
| **Firebase Admin SDK** | Push notifications via FCM |
| **Selenium / Undetected ChromeDriver** | Web scraping for dynamic pages |
| **TradingView DataFeed** | Real-time stock candle data |
| **BeautifulSoup & Trafilatura** | HTML parsing & article extraction |
| **Feedparser** | RSS feed consumption |

---

## 🚀 Deployment

### Server Connection

```bash
# Set permissions on the key file
chmod 400 MyNewsBotKey.pem

# SSH into the EC2 instance
ssh -i "MyNewsBotKey.pem" ubuntu@51.21.191.162

# Download files from the server to local machine
scp -i "MyNewsBotKey.pem" -r ubuntu@51.21.191.162:/home/ubuntu/news_bot .
```

### Running the Services

```bash
# News Bot
cd /home/ubuntu/news_bot
source venv/bin/activate
python3 news_scraper.py

# Gold Price Tracker
cd /home/ubuntu/materails_local_pricing
python3 local_gold_scraper.py

# Market Status
cd /home/ubuntu/market_status
python3 market_status.py

# Stocks Scraper (launches all 15 in parallel)
cd /home/ubuntu/stocks_scraper
bash run.sh
```

> **Note:** These services are typically scheduled via **cron jobs** on the EC2 instance for automated execution.

---

## 📊 Database Tables

| Table | Service | Description |
|---|---|---|
| `market_history` | Market Status | Daily market cap & value traded |
| `material_prices` | Gold Scraper | Gold & silver price history |
| `stock_news` | News Bot | Aggregated financial news articles |
| `stocks` | News Bot | Master stock list (read-only) |
| `profiles` | Gold Scraper | User profiles with FCM tokens |
| `user_watchlist` | News Bot | Per-user stock watchlist |
| `{symbol}_candles` | Stocks Scraper | Per-stock candlestick data (e.g., `abuk_candles`) |
