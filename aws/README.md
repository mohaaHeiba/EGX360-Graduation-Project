# EGX360 AWS Backend & Deployment Directory

## Project Overview
This directory contains the core backend scripts and services for **EGX360**, a comprehensive financial platform handling Egyptian stocks, cryptocurrencies, indices, local gold, and silver. The scripts here are primarily written in Python and are responsible for live market data scraping, AI-based asset predictions, news aggregation, server management, and automated user protection measures (e.g., stop-loss/take-profit triggers). These services interface continuously with a Supabase PostgreSQL database and Firebase Cloud Messaging (FCM) for user notifications.

## Table of Contents
1. [Directory Structure & Components](#directory-structure--components)
2. [Setup & Deployment Instructions](#setup--deployment-instructions)
3. [Security Notices](#security-notices)

---

## Directory Structure & Components

### `commands.txt`
* **Purpose:** A quick reference for essential server management commands.
* **Structure:** A simple text file containing SSH and SCP terminal commands.
* **Behavior/Execution:** Used manually by developers to connect to the AWS Ubuntu server via SSH and to securely copy code (like the `news_bot` directory) between the local machine and the remote server.

### `just save it when we turn off the server use this its get the data for stocks dont forget it/`
* **Purpose:** A historical data recovery toolset. It is used to backfill missing 1-minute stock candle data in the event that the server experiences downtime or is intentionally turned off.
* **Structure:** Contains Python scripts like `get_data_oneDay.py` and `get_one_day_ofdata.py`, which utilize the `tvDatafeed` (TradingView) library, alongside a copy of `update_prev_close.py`.
* **Behavior/Execution:** Executed manually after server downtime. It iterates through Egyptian stocks, fetches missing 1-minute interval historical data from TradingView, and upserts the records into the respective Supabase candle tables.
> **💡 Suggestion:** For better project organization and readability, consider renaming this folder to something cleaner and more descriptive, such as `historical_data_recovery/` or `server_downtime_backfill/`.

### `market_status/`
* **Purpose:** Scrapes and records the daily EGX market summary (Total Market Cap and Total Value Traded).
* **Structure:** Contains a single driver script, `market_status.py`.
* **Behavior/Execution:** Set up to run automatically (typically via a cron job). It uses `undetected_chromedriver` (in headless mode on the server) to visit the Egyptian Stock Exchange (EGX) homepage, extracts the "Market Cap" and "Value Traded" values, formats them (e.g., B, T, M EGP), and upserts the data into the `market_history` table in Supabase.

### `materials_local_pricing/`
* **Purpose:** Tracks the local prices of precious metals (Gold and Silver) in Egypt and alerts users of significant price movements.
* **Structure:** Contains `local_gold_scraper.py` and a Firebase `service_account.json` for sending notifications.
* **Behavior/Execution:** Intended to run periodically. It scrapes `safehavenhub.com` to get live prices for 24K, 21K, 18K gold, as well as 999 and 925 silver. It saves these prices to the `material_prices` Supabase table. If the price of 21K gold changes by a specific threshold (e.g., 10 EGP), it triggers a Firebase Cloud Messaging (FCM) push notification to all subscribed users.

### `MyNewsBotKey.pem`
* **Purpose:** The SSH private key used to authenticate and connect to the AWS EC2 instance hosting the backend services.
* **Structure:** Standard PEM encoded RSA private key.
* **Behavior/Execution:** Provided to the `ssh` or `scp` commands using the `-i` flag to securely access the remote server without requiring a password.

### `news_bot/`
* **Purpose:** An AI-powered news aggregator and sentiment analyzer for both Egyptian stocks and cryptocurrencies.
* **Structure:** Contains `news_scraper.py`, a log file `news_test.log`, and a Firebase `service_account.json`.
* **Behavior/Execution:** Designed to run continuously or on a schedule. It scrapes Google News using RSS feeds. It implements Cloudflare bot-protection bypasses and cleans HTML content. Crucially, it routes Arabic news through **Cerebras (Llama 3.1)** to filter out noise, validate the news, and assign a market sentiment. English cryptocurrency news is routed through Hugging Face's **FinBERT** for offline sentiment classification. The clean details and sentiment are saved into `stock_news`, and FCM push notifications are fired to users who have the respective assets in their watchlist.

### `Predection_models/` (Prediction Models)
* **Purpose:** The quantitative AI engine responsible for forecasting asset price movements based on technical indicators and global macroeconomic data.
* **Structure:** Contains the main inference script `predict.py` and trained Machine Learning objects (`EGX360_Final_Model_v8.pkl` and `EGX360_Scaler_v8.pkl`).
* **Behavior/Execution:** Acts as a continuous pipeline. It downloads global macro data (Gold, USD/EGP) via `yfinance`. It then calculates complex technical features (RSI, MACD, Price Velocity, EMA distances) for each asset (Stocks via Supabase 1D candles; Crypto via `yfinance`). Finally, it utilizes a pre-trained ML model to predict the probability of a price increase, pushing these probabilities to the `ai_predictions` Supabase table.

### `stocks_scraper/`
* **Purpose:** Dedicated live data scrapers configured to continuously fetch live candle data for top EGX stocks and market indices.
* **Structure:** Contains a shell script `run.sh`, a `settings/` folder, an `egx_candles/` directory (holding individual scripts for tickers like ABUK, COMI, EAST, EGX30, EGX70EWI, etc.), and a duplicate of `user_protection_rules.py`.
* **Behavior/Execution:** The `run.sh` script acts as the entry point. When executed on the AWS server, it activates the python virtual environment and spins up dozens of background Python processes (`&`). Each background process continuously tracks a specific asset's price data in real-time.

### `update_prev_close.py`
* **Purpose:** Utility script to update the "Previous Close" values for all stock listings.
* **Structure:** A standalone Python script connecting to Supabase.
* **Behavior/Execution:** Typically executed once at the start or end of the trading day. It fetches the latest available daily candle for every stock in the system and updates the `prev_close` column in the main `stocks` table.

### `user_protection_rules/`
* **Purpose:** The Automated Risk Management and Trading Engine. It protects user investments by triggering automatic alerts and auto-liquidation actions based on live market movements.
* **Structure:** Contains `user_protection_rules.py` and a Firebase `service_account.json`.
* **Behavior/Execution:** Runs as a continuous infinite loop (`while True`). It calculates holding profit/loss percentages by comparing user entry prices against live candle data. It implements:
  - **Take Profit Alerts:** Global automated FCM alerts when a position is up 5%.
  - **Stop Loss Alerts:** User-configured FCM drop alerts.
  - **Auto-Liquidation (Sell):** Automatically triggers a Supabase RPC (`execute_trade`) to dump a stock if it surpasses a user's chosen auto-sell threshold to minimize catastrophic losses.
  - *Note:* It implements faster polling/cooldowns during "Hot Zones" (market open and close) due to high volatility.

---

## Setup & Deployment Instructions

Based on the directory structure and scripts, here is how the server is intended to be deployed and initialized:

1. **Server Access:**
   Connect to your Ubuntu AWS instance securely using the private key:
   ```bash
   chmod 400 MyNewsBotKey.pem
   ssh -i "MyNewsBotKey.pem" ubuntu@51.21.191.162
   ```

2. **Environment & Dependency Setup:**
   - Ensure Python 3.x and `pip` are installed on the server.
   - Create and navigate to a virtual environment (as seen in `run.sh`): 
     ```bash
     python3 -m venv venv
     source venv/bin/activate
     ```
   - Install required dependencies (e.g., `pandas`, `yfinance`, `supabase`, `firebase_admin`, `selenium`, `undetected_chromedriver`, `trafilatura`, `transformers`, `cerebras_cloud_sdk`, `joblib`, `feedparser`, `beautifulsoup4`, etc.).

3. **Running the Live Stock Scrapers:**
   Navigate to the `stocks_scraper/` directory and execute the shell script to start all tracking processes in the background:
   ```bash
   bash run.sh
   ```

4. **Configuring Daemon Services:**
   The following scripts contain continuous infinite loops or are designed to be run repeatedly on a schedule. You should configure them as **systemd services** or **crontab** entries to ensure they run constantly and restart automatically on failure:
   - `news_bot/news_scraper.py`
   - `materials_local_pricing/local_gold_scraper.py`
   - `user_protection_rules/user_protection_rules.py`
   - `Predection_models/predict.py`

5. **Daily Maintenance (CRON Jobs):**
   - Hook `update_prev_close.py` to a daily CRON job scheduled shortly after the Egyptian market closes.
   - Hook `market_status/market_status.py` to a daily CRON job to record the closing stats of the day.

---

## ⚠️ Security Notices

> [!CAUTION]
> **CRITICAL SECURITY WARNING: PRIVATE SSH KEY EXPLOSION RISK**
>
> The file `MyNewsBotKey.pem` is an active SSH private key providing direct root/ubuntu access to your AWS instances. 
> 
> **THIS FILE MUST NEVER BE PUSHED TO GITHUB OR ANY VERSION CONTROL SYSTEM.**
> 
> Committing this file could allow unauthorized malicious actors to instantly hijack your AWS server, potentially resulting in massive unauthorized AWS billing charges, data breaches, and complete loss of the EGX360 backend. 
> 
> **Action Required:**
> Add `*.pem` and specifically `MyNewsBotKey.pem` to your project's `.gitignore` file immediately and run `git rm --cached MyNewsBotKey.pem` if it has already been tracked in your repository.
