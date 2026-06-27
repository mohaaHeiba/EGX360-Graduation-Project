<div align="center">

# 🇪🇬 EGX 360
### Intelligent Financial Markets Platform

**A comprehensive stock market analysis, real-time trading data, and AI-powered financial assistant for the Egyptian Exchange (EGX) and global markets.**

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)](https://supabase.com)
[![Firebase](https://img.shields.io/badge/Firebase-FCM-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Academic-blue)](#license)

</div>

---

## 📖 About

EGX 360 is a cross-platform mobile and desktop application built with Flutter that provides investors and traders with a unified, real-time view of the Egyptian Exchange (EGX), cryptocurrencies, ETFs, materials, commodities, and foreign-exchange rates. The platform aggregates data from **Google Sheets, Finnhub, Binance, Massive, and TradingView** scrapers into a single intelligent interface — covering **100+ assets** across EGX stocks, US stocks, crypto, ETFs, materials, and USD/FX pairs.

### ✨ Key Highlights

| Feature | Description |
|---|---|
| 📊 **Advanced Charting** | Candlestick & area charts with 9+ timeframes, drawing tools, 8 technical indicators |
| 🤖 **AI Chatbot** | Conversational assistant (Cerebras Llama 3.1-8B) with full portfolio context |
| 📈 **Technical Analysis** | Composite engine: EMA, RSI, MACD, Stochastic, Bollinger Bands → Buy/Sell signal |
| 🎯 **AI Prediction Gauge** | ML-based bullish probability displayed as animated semicircular gauge |
| 📰 **News + Sentiment Analysis** | AI-powered Arabic & English news with per-article sentiment scoring (Bullish / Bearish / Neutral) via Cerebras & FinBERT |
| 🎓 **Learn (Academy)** | Duolingo-style financial education: XP streaks, daily learning streak, interactive lesson maps — Markets, Charting, Investing & more |
| 🛢️ **Local Material Prices** | Real-time Egyptian local prices for gold (24K/21K/18K), silver, and other commodities scraped live |
| 💼 **Paper Trading** | Full simulation with per-asset risk protection rules (alert + auto-sell) |
| 👥 **Social Community** | Nested threaded comments, real-time stock chat rooms, posts with sentiment tags |
| 🔊 **News + TTS** | Arabic & English text-to-speech news reader with AI summarization |
| 🌐 **Bilingual** | Full Arabic ↔ English support with RTL-aware layouts |
| 🖥️ **Adaptive** | Responsive layouts for mobile, tablet, and desktop (Linux/Windows) |

---

## 🏗️ Repository Structure

```
EGX360-Graduation-Project/
├── app/                      # Flutter application (main codebase)
│   ├── lib/                  # Dart source code
│   │   ├── core/             # Shared utilities, design system, routing
│   │   └── features/         # 15 feature modules (Clean Architecture)
│   ├── supabase/             # Database schema & migration files
│   └── README.md             # Detailed app documentation
├── aws_automation/           # AWS EC2 backend Python services
│   ├── stocks_scraper/       # Live EGX candle scrapers (per-ticker background processes)
│   ├── news_bot/             # AI news aggregator + sentiment (Cerebras + FinBERT)
│   ├── materials_local_pricing/ # Gold/silver local price scraper → Supabase + FCM
│   ├── market_status/        # Daily EGX market cap & value traded scraper
│   ├── user_protection_rules/# Automated stop-loss / take-profit engine (FCM + auto-sell)
│   ├── prediction_models/    # ML inference pipeline → ai_predictions table
│   └── fallback_scraper/     # Historical data recovery (TradingView backfill)
├── models/                   # ML model training notebooks & artifacts
│   ├── EGX/                  # EGX stock prediction models (stacking, LSTM)
│   ├── BTC/                  # Bitcoin prediction models (Deep Quant, XGBoost)
│   └── THE DEEP QUANT MODEL.ipynb
├── assets/                   # Screenshots & presentation materials
├── data_store/               # Data storage configs & exports
├── docs/                     # Project documentation & reports
├── presentations/            # Poster, slides, infographics
└── sql_schema/               # SQL database schema definitions
```

> 📋 For a full breakdown of the Flutter app architecture, features, and APIs, see [`app/README.md`](app/README.md).

---

## ☁️ AWS Server & Backend Infrastructure

The entire data pipeline runs on an **AWS EC2 Ubuntu instance** hosting a suite of Python services that feed the Supabase database in real time.

### Services Running on AWS

| Service | Script | Trigger |
|---|---|---|
| **EGX Live Candle Scrapers** | `stocks_scraper/run.sh` | Continuous (dozens of background processes per ticker) |
| **AI News Bot** | `news_bot/news_scraper.py` | Continuous / scheduled |
| **Local Material Prices** | `materials_local_pricing/local_gold_scraper.py` | Periodic (scrapes safehavenhub.com) |
| **Market Status** | `market_status/market_status.py` | Daily cron (EGX close) |
| **User Protection Engine** | `user_protection_rules/user_protection_rules.py` | Continuous infinite loop |
| **AI Prediction Pipeline** | `prediction_models/predict.py` | Scheduled (post-market) |
| **Prev Close Updater** | `update_prev_close.py` | Daily cron (after market close) |

### What Each Service Does

- **EGX Candle Scrapers** — Each top EGX stock (ABUK, COMI, EAST, EGX30, EGX70EWI, …) runs as its own background Python process via `run.sh`, continuously writing 1-minute OHLCV candles to Supabase.

- **AI News Bot** — Scrapes Google News RSS feeds for Egyptian stocks and crypto. Arabic news is routed through **Cerebras Llama 3.1** for validation, noise filtering, and sentiment tagging. English crypto news uses **FinBERT** (Hugging Face, offline) for sentiment. Results + FCM push notifications are sent to users tracking the relevant asset in their watchlist.

- **Local Material Prices** — Scrapes `safehavenhub.com` for live Egyptian gold prices (24K, 21K, 18K) and silver (999, 925). Saves to `material_prices` table. Fires an FCM broadcast if 21K gold moves by ≥ 10 EGP.

- **Market Status** — Uses headless `undetected_chromedriver` to visit the EGX homepage, extracts daily Market Cap and Value Traded, and upserts to `market_history`.

- **User Protection Engine** — Runs an infinite loop comparing live candle prices against user holdings. Triggers:
  - 📢 **Take-profit alert** at +5% gain (global threshold)
  - 🔔 **Stop-loss alert** at user-configured drop %
  - 🔴 **Auto-liquidation** via Supabase RPC `execute_trade` when drawdown hits user's auto-sell threshold
  - Faster polling during "Hot Zones" (market open/close)

- **AI Prediction Pipeline** — Downloads global macro data (Gold, USD/EGP via `yfinance`), computes RSI, MACD, EMA distances, and Price Velocity for every asset, then runs a pre-trained ML model to output a bullish probability → pushed to `ai_predictions` table.

### Server Access

```bash
# SSH into the EC2 instance
chmod 400 MyNewsBotKey.pem
ssh -i "MyNewsBotKey.pem" ubuntu@<ec2-ip>

# Start all stock scrapers
cd stocks_scraper && bash run.sh

# Activate virtual environment
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
```

---

## 🧠 Machine Learning Models

All trained model artifacts and training notebooks live in the [`models/`](models/) directory.

### EGX Stock Prediction (`models/EGX/`)

| Artifact | Description |
|---|---|
| `egx360_stack_model.pkl` | Final stacking ensemble model (deployed to AWS) |
| `egx360_scaler.pkl` | Feature scaler paired with the stack model |
| `final_model.ipynb` | Full training pipeline — feature engineering, stacking, evaluation |
| `Egx30.ipynb` | EGX30 index-specific experiments |
| `egx_prediction.html` | Interactive prediction visualization export |
| `THE DEEP QUANT MODEL.ipynb` | Deep quantitative model experiments |
| `predict.py` | Production inference script (runs on AWS, writes to `ai_predictions`) |

**Features used**: RSI-14, MACD histogram, EMA distances (10/20/50/100), Price Velocity, Bollinger Band position, global macro (Gold price, USD/EGP rate)

**Output**: Bullish probability [0–1] → displayed in the app as the animated semicircular AI Prediction Gauge

### BTC Prediction (`models/BTC/`)

| Artifact | Description |
|---|---|
| `THE DEEP QUANT MODEL.ipynb` | Deep quantitative model for Bitcoin |
| `XGBoost.ipynb` | XGBoost-based BTC price direction model |

### Root-level Notebooks

| Notebook | Description |
|---|---|
| `THE DEEP QUANT MODEL.ipynb` | Master deep quant model architecture |
| `lstm_v1.ipynb` | LSTM v1 experiments |
| `lstm copy.ipynb` | LSTM variant experiments |

---

## 🛠️ Technology Stack

### Flutter Libraries

| Library | Purpose |
|---|---|
| **Flutter** `^3.9.2` | Cross-platform framework (Android, iOS, Linux, Windows) |
| **Dart** | Language |
| **GetX** | State management, dependency injection, routing |
| **Syncfusion Flutter Charts** | Candlestick / area charts with trackball |
| **FL Chart** | Sparklines, gauge fills |
| **Flutter ScreenUtil** | Responsive font/size scaling (design: 360×690) |
| **flutter_markdown** | Markdown rendering in AI chatbot responses |
| **flutter_tts** | TTS news reader (Arabic + English, Google TTS) |
| **webview_flutter** | In-app web view (portfolio, license viewer) |
| **flutter_localizations** | RTL + localization delegates |
| **Floor** | Type-safe SQLite ORM with code generation |
| **GetStorage** | Key-value store (theme, session persistence) |
| **flutter_dotenv** | `.env` config (API keys) |
| **cached_network_image** | Image loading + disk caching |
| **flutter_local_notifications** | Local notification scheduling |
| **workmanager** | Background tasks |
| **image_picker / image_compress** | Media handling for post creation |
| **permission_handler** | Runtime permissions |
| **google_sign_in** | Google OAuth |
| **protocol_handler** | Desktop OAuth deep link (`io.supabase.flutter`) |
| **url_launcher** | Open news article URLs externally |
| **web_socket_channel** | Binance WebSocket streams |
| **intl** | Date / time / number formatting |

### Backend & Cloud

| Service | Purpose |
|---|---|
| **Supabase** | Auth, PostgreSQL, Realtime, Storage, Edge RPCs |
| **Firebase FCM** | Push notifications (peer-to-peer + broadcast) |
| **AWS EC2 (Ubuntu)** | Hosts all Python backend services (scrapers, bots, ML inference) |
| **Binance API** | REST + WebSocket crypto / commodity data |
| **Cerebras AI** | Llama 3.1-8B — chatbot, news summarization, Arabic sentiment |
| **FinBERT (HuggingFace)** | English crypto news sentiment (offline, runs on AWS) |
| **Finnhub API** | US stocks & ETF data |
| **TradingView / tvDatafeed** | EGX historical candle backfill |

### Python Backend Libraries (AWS)

| Library | Purpose |
|---|---|
| **pandas / numpy** | Data processing |
| **yfinance** | Macro data (Gold, USD/EGP) for ML features |
| **supabase-py** | Database read/write from Python |
| **firebase_admin** | FCM push from Python scripts |
| **selenium + undetected_chromedriver** | Headless scraping (EGX, safehavenhub) |
| **trafilatura** | News article text extraction |
| **feedparser / beautifulsoup4** | RSS feed parsing |
| **cerebras_cloud_sdk** | Arabic news sentiment via Llama 3.1 |
| **transformers (FinBERT)** | English crypto sentiment |
| **joblib** | Load/save trained ML model (.pkl) |
| **scikit-learn / xgboost** | ML training & stacking |

---

## 🏛️ Architecture

EGX 360 follows **Feature-First Clean Architecture** with three layers per feature:

```
Data Layer  →  Domain Layer  →  Presentation Layer
(APIs/DB)       (Entities,        (GetX Controllers,
                 Repos, UseCases)   Pages, Widgets)
```

**15 Feature Modules**: `assets` · `auth` · `chatbot` · `community` · `home` · `learn` · `markets` · `news_briefing` · `notifications` · `post_details` · `profile` · `search` · `settings` · `simulation` · `stock_chat` · `welcome`

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK `^3.9.2`
- Supabase project ([supabase.com](https://supabase.com))
- Firebase project ([console.firebase.google.com](https://console.firebase.google.com))
- Cerebras AI API key ([inference.cerebras.ai](https://inference.cerebras.ai))

### Setup

```bash
# 1. Clone
git clone https://github.com/mohaaHeiba/EGX360-Graduation-Project.git
cd EGX360-Graduation-Project/app

# 2. Install dependencies
flutter pub get

# 3. Create .env file (never commit this!)
cat > .env << EOF
SUPABASE_URL=your_supabase_url
SUPABASE_APIKEY=your_supabase_anon_key
CEREBRAS_APIKEY=your_cerebras_key
EOF

# 4. Configure Firebase
dart pub global activate flutterfire_cli
flutterfire configure

# 5. Generate Floor (SQLite) code
flutter pub run build_runner build --delete-conflicting-outputs

# 6. Run
flutter run                        # Development
flutter build apk --release        # Android APK
flutter build linux --release      # Linux Desktop
```

> ⚠️ **Never commit your `.env` file.** It is listed in `.gitignore`. Create it locally only.

---

## 🔮 Future Improvements

- **Price Alerts** — User-set price-target push notifications
- **Social Trading** — Copy-trade from top performers
- **Export** — Portfolio report as PDF/CSV
- **Advanced Analytics** — Sharpe ratio, beta, correlation matrix
- **Chart Pattern Recognition** — Automated candlestick pattern detection
- **Home-screen Widgets** — Quick market glance widget
- **More Learn Modules** — Expand Academy to cover Options, Forex, and Portfolio Theory

---

## 📸 Screenshots

### 🖥️ Desktop Application

![Loading Screen](assets/image/dektop/1_Loading.png)
*Loading Screen*

![Welcome / Onboarding](assets/image/dektop/2_Welcome.png)
*Welcome / Onboarding*

![Authentication](assets/image/dektop/3_auth.png)
*Authentication*

![Onboarding Step 1](assets/image/dektop/5_onbording.png)
*Onboarding Step 1*

![Onboarding Step 2](assets/image/dektop/6_onbording.png)
*Onboarding Step 2*

![Onboarding Step 3](assets/image/dektop/7_onbording.png)
*Onboarding Step 3*

![Home Dashboard](assets/image/dektop/9_Home.png)
*Home Dashboard*

![Home — Market Overview](assets/image/dektop/10_1_home.png)
*Home — Market Overview*

![AI Chatbot](assets/image/dektop/10_chatbot.png)
*AI Chatbot*

![AI Chatbot — Conversation](assets/image/dektop/11_chatbot.png)
*AI Chatbot — Conversation*

![News Feed with Sentiment Analysis](assets/image/dektop/12_news.png)
*News Feed with Sentiment Analysis*

![Markets Overview](assets/image/dektop/13_market.png)
*Markets Overview*

![Markets — Candlestick Chart](assets/image/dektop/15_market.png)
*Markets — Candlestick Chart*

![Markets — Technical Analysis](assets/image/dektop/16_market.png)
*Markets — Technical Analysis*

![Markets — AI Prediction Gauge](assets/image/dektop/17_mrket.png)
*Markets — AI Prediction Gauge*

![Markets — Indicators](assets/image/dektop/18_market.png)
*Markets — Indicators*

![Markets — Drawing Tools](assets/image/dektop/19_market.png)
*Markets — Drawing Tools*

![Markets — Order Sheet](assets/image/dektop/20_market.png)
*Markets — Order Sheet*

![Markets — Stock Details](assets/image/dektop/21_market.png)
*Markets — Stock Details*

![Markets — Seasonality](assets/image/dektop/22_market.png)
*Markets — Seasonality*

![Markets — Crypto](assets/image/dektop/24_1_market.png)
*Markets — Crypto*

![Markets — FX / USD Rates](assets/image/dektop/24_2_market.png)
*Markets — FX / USD Rates*

![Search (100+ Assets)](assets/image/dektop/24_search.png)
*Search — 100+ Assets*

![Community Feed](assets/image/dektop/25_community.png)
*Community Feed*

![Community — Post Details](assets/image/dektop/26_1_community.png)
*Community — Post Details*

![Community — Comments](assets/image/dektop/26_2_community.png)
*Community — Comments*

![User Profile](assets/image/dektop/26_profile.png)
*User Profile*

![Simulation — Portfolio](assets/image/dektop/27_a_simulation.png)
*Simulation — Portfolio*

![Simulation — Transactions](assets/image/dektop/27_b_simulation.png)
*Simulation — Transactions*

![Settings](assets/image/dektop/27_settings.png)
*Settings*

![Asset Detail — Overview](assets/image/dektop/28_assets.png)
*Asset Detail — Overview*

![Asset — News & Sentiment Tab](assets/image/dektop/30_assets.png)
*Asset — News & Sentiment Tab*

![Asset — Community Tab](assets/image/dektop/31_assets.png)
*Asset — Community Tab*

![Asset — Live Chat](assets/image/dektop/32_assets.png)
*Asset — Live Chat*

---

### 🎓 Learn — Academy (Duolingo-style)

![Academy — Lesson Map (locked)](assets/image/dektop/1.jpg)
*Academy — Lesson Map (locked state)*

![Academy — Lesson Map with Progress & XP](assets/image/dektop/2.jpg)
*Academy — Lesson Map (with progress & XP streak)*

![Academy — Lesson Content](assets/image/dektop/3.jpg)
*Academy — Lesson Content (Hours & Sessions)*

---

## 👨‍💻 Author

**Developer**: Mohamed Heiba
**GitHub**: [@mohaaHeiba](https://github.com/mohaaHeiba)
**Institution**: Kafr El-Sheikh University (KSIU)
**Email**: mohamed222101223@ksiu.edu.eg
**Academic Year**: 2024–2025

---

## 🙏 Acknowledgments

- **Supabase** — Backend, database, Realtime, storage
- **Firebase** — Push notification infrastructure
- **AWS EC2** — Cloud server hosting all Python backend services
- **Binance** — Crypto/commodity market data APIs
- **Finnhub** — US stocks & ETF data
- **TradingView / Massive / Google Sheets** — EGX stock data pipeline
- **Cerebras AI** — LLM inference for chatbot, summarization & Arabic sentiment
- **FinBERT (Hugging Face)** — English crypto sentiment analysis
- **Syncfusion** — Flutter charting components
- **Flutter Community** — Open source packages ecosystem

---

## 📄 License

This project is developed as a graduation project for academic purposes.

---

<div align="center">

**EGX 360** · Built with ❤️ using Flutter · 2024–2025

</div>
