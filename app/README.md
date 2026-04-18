# EGX 360 — Intelligent Financial Markets Platform

## Project Title
**EGX 360** — Comprehensive stock market analysis, real-time trading data, and AI-powered financial assistant for the Egyptian Exchange (EGX) and global markets.

---

## Short Professional Description

EGX 360 is a cross-platform mobile and desktop application built with Flutter that provides investors and traders with a unified, real-time view of the Egyptian Exchange (EGX), cryptocurrencies, commodities, and foreign-exchange rates. The platform consolidates fragmented financial data into a single intelligent interface featuring:

- Advanced interactive charting with 9+ timeframes
- AI-powered financial chatbot with full portfolio context
- Technical analysis engine with composite buy/sell signals
- Machine-learning prediction gauge (bullish probability)
- Paper trading simulation with per-asset risk protection rules
- Full social community with nested threaded comments
- Real-time stock-specific chat rooms
- Text-to-speech news reader in Arabic & English
- Fully bilingual (Arabic ↔ English, RTL-aware)
- Adaptive layouts for mobile, tablet, and desktop (Linux/Windows)

The app implements a hybrid data strategy: WebSocket connections for live crypto/commodity prices, 20-second intelligent polling for EGX stocks during market hours, and a local SQLite cache for offline-first functionality.

---

## Application Entry Point & Startup

**`main.dart`** initializes the app in order:
1. Firebase (`firebase_core`) — skipped gracefully on Linux/Windows
2. `NotificationService.init()` — skipped on Linux (platform guard)
3. `WebViewPlatform` — set to `AndroidWebViewPlatform`
4. `.env` load via `flutter_dotenv` (Supabase URL/key, Cerebras key)
5. `Supabase.initialize()`
6. `GetStorage.init()` (theme/session persistence)
7. `protocolHandler.register('io.supabase.flutter')` — desktop OAuth deep link
8. `InitLocalData.initDatabase()` — Floor SQLite database
9. `ThemeController` — restore saved theme
10. `NotificationRemoteDataSource` + `NotificationRepository` — global registration
11. `ScreenUtilInit` with `designSize: 360×690`, adaptive font scaling for desktop

---

## Key Features

### 🎬 Welcome Screen (Animated Onboarding)
- Full-screen animated **candlestick chart background** — procedurally generated random OHLC candlesticks rendered via a custom `CustomPainter` (`CandlestickPainter` + `InteractiveCandlestickPainter`)
- Smooth **fade + slide-up animation** on logo and CTA elements
- **Mouse-tracking parallax effect** on desktop (tracks cursor position)
- Platform-aware candle sizing (mobile: 7px, desktop: 15px)
- Permission request flow before entering auth (`PermissionService.requestAll()`)

### 🔐 Authentication
All auth flows are fully implemented with separate pages:

| Page | Description |
|---|---|
| `login_page.dart` | Email + password login |
| `register_page.dart` | Account creation with name, email, password |
| `forgot_password_page.dart` | Request password reset via email |
| `email_verification_page.dart` | Email OTP/link verification with resend |
| `create_new_password_page.dart` | Set a new password after reset |
| `auth_desktop_body.dart` | Desktop-adapted two-column auth layout |

- **Google Sign-In** OAuth with Supabase social login
- Deep link protocol handler (`io.supabase.flutter`) for desktop OAuth callback
- Session persistence across app restarts

### 🏠 Home Dashboard
- **Market overview section**: Key index stats and summary
- **Trending stocks section**: Cards with sparklines, price, and % change
- **Watchlist section**: Personalized watchlist with live price rows
- **Quick indicators section**: Fast-access material prices (Gold/Silver EGP)
- **Latest news section**: Scrollable news list items with TTS button
- **Logo animation**: Animated EGX 360 logo widget
- **Separate desktop layout** with:
  - Notification dropdown (bell icon, real-time badge, dropdown overlay)
  - Latest news sidebar section
  - Full shimmer loading skeleton
- **Trending Stocks Page** (mobile + dedicated desktop page)
- **Watchlist Page**: Standalone full-screen watchlist

### 📊 Markets — Advanced Charting & Trading

The Markets feature is the core of the app. `MarketsController` manages everything reactively via GetX.

#### Chart Engine
- **Chart types**: Candlestick and Area (toggle via chart type menu)
- **Drawing tools** (via `DrawingToolsMenuWidget`, 19KB):
  - Trend line, horizontal line, vertical line, rectangle
- **Technical indicator overlays** (via `IndicatorsMenuWidget`, 37KB):
  - SMA, EMA (10, 20, 50, 100), Bollinger Bands (20, 2σ)
  - Configurable period parameters
- **Chart view** (`chart_view.dart`, 29KB): Syncfusion candlestick + area, trackball tooltip, volume bars
- **Chart header** (`chart_header.dart`, 20KB): Price display, % change, open/high/low/close stats
- **Chart toolbar** (`chart_toolbar.dart`): Interval selector, indicator toggle, drawing tool toggle
- **Countdown timer widget**: Shows time remaining to next candle close
- **Shimmer loading skeleton** for chart loading state
- **Empty state widget** when no asset is selected

#### Data Routing Intelligence
| Asset Type | Fetch Method | Real-Time |
|---|---|---|
| Cryptocurrencies | Binance REST API + WebSocket | `wss://stream.binance.com/ws/{symbol}@kline_{interval}` |
| Gold (`PAXGUSDT`) / Silver (`LTCUSDT`) | Binance REST + WebSocket | Same Binance stream |
| EGX Stocks | Supabase candle tables | 20-second polling (market hours only) |
| Long-term EGX (1W, 1M) | Supabase daily data → aggregated | No live updates |
| All assets — previous close | Binance 24hr ticker | On-demand |

#### Market Hours Intelligence
- EGX market: **Sunday–Thursday, 10:00 AM – 2:45 PM Cairo (UTC+2)**
- `isMarketOpen` getter checked before starting polling; polling timer auto-stops when market closes
- Friday & Saturday data excluded from EGX intraday charts
- `CandleAggregator` converts 1m Supabase data → 5m / 15m / 30m / 1H / 4H with timestamp boundary alignment

#### AI Prediction Gauge (Markets)
- Fetches `probability` from Supabase `ai_predictions` table per symbol
- Displayed as a **semicircular gauge** with custom arc painter:
  - Red → Orange → Green gradient (50 arc segments)
  - Black/white needle pointer
  - Bullish / Bearish labels (or Buy / Sell for TA mode)
- Two gauge modes: **AI mode** (`isAi: true`) and **Technical Analysis mode**

#### Order Sheet (Paper Trading Entry)
- `order_sheet.dart` (24KB): Full-featured buy/sell order form
- Select quantity → see total value → execute virtual trade
- Integrated from the chart view (trade button widget)
- `position_summary_card.dart` + `position_details_sheet.dart`: Quick current-position stats

#### Desktop Markets Layout (`markets_page_desktop.dart`, 33KB)
- Left: Full-screen chart with all tools
- Right sidebar (`markets_right_sidebar.dart`, 13KB):
  - Stock details panel (`stock_details_panel.dart`, 10KB): company info, stats
  - **Technical Analysis Gauge** (`technical_gauge.dart`, 14KB)
  - **Seasonality Chart** (`seasonals_chart.dart`, 6KB): historical monthly performance bar chart
  - **Market news card** (`market_news_card.dart`): latest news for the selected asset

### 🔎 Asset Details Page

A unified `AssetDetailsPage` + `AssetDetailsController` (1221 lines) handles **all asset types**:

| Asset Type | Chart Source | Live Update |
|---|---|---|
| EGX Stocks | Supabase | 20s polling (market hours) |
| Cryptocurrencies | Binance Klines + WebSocket | Real-time WebSocket |
| Gold / Silver | Binance (intraday) / Supabase (historical) | WebSocket (1D/1W) |
| Currencies (FX) | Supabase historical rates | On-demand fetch |

#### Tabs in Asset Detail
1. **Overview Tab** (`build_overview_tab.dart`, 23KB):
   - Price header with live price, % change, 24h high/low/volume (crypto)
   - Interactive area chart with time-range selector (1D/5D/1W/1M/6M/1Y/All)
   - AI Prediction gauge for stocks/crypto
   - Week range card (52-week high/low bar)
   - Key stats grid (market cap, volume, sector, etc.)
   - Currency conversion toggle (USD ↔ EGP) for Gold/Silver
2. **News Tab** (`build_news_tab_mobile.dart` / `build_news_tab_desktop.dart`):
   - Latest news articles for the asset
   - TTS read-aloud button per article
   - AI Summarize button → triggers `SummarizeNewsUseCase` → shows `NewsSummaryPage`
3. **Community Tab** (`build_community_tab.dart`):
   - Posts tagged to this asset (loaded from community feature)
4. **Live Chat Tab** (`asset_live_chat_tab.dart`):
   - Routes to Stock Chat feature (real-time Supabase Realtime chat room)
5. **Currency Calculator Tab** (`build_currency_calculator_tab.dart`, 6KB):
   - Available only for FX assets
   - Interactive input fields for bidirectional currency conversion
   - Currency switcher dropdown (10 pairs vs EGP)

#### Supported Currency Pairs (FX)
USD/EGP, EUR/EGP, GBP/EGP, JPY/EGP, CHF/EGP, SAR/EGP, AED/EGP, KWD/EGP, QAR/EGP, JOD/EGP

### 🤖 EGX AI Chatbot

A full conversational AI assistant powered by **Cerebras AI (Llama 3.1-8B)**.

#### UI (`chatbot_page.dart`, 524 lines)
- Forced **LTR layout** (`Directionality`) so Arabic text in bubbles renders correctly
- **Chat bubbles**: User (right, brand color) / AI (left, surface color)
- **AI responses render as Markdown** (`flutter_markdown`): bold, italic, lists, code blocks, headers — fully styled
- **Animated typing indicator**: 3 pulsing dots with staggered opacity animation ("Analyzing your data...")
- **Suggestion chips** (horizontal scroll row, shown when chat is empty):
  - ☀️ Get My Daily Summary
  - 📊 How is my portfolio doing?
  - 💰 Did I gain or lose today?
  - 📰 What's the latest market news?
  - 🌐 What does the community think?
  - 🤖 AI predictions for my stocks?
  - 🛡️ Show my protection rules
- **Desktop mode**: Side nav stays visible; "New Chat" button in header
- Multi-line text input (up to 5 lines), send on Enter key or button tap

#### Intelligence (`chatbot_service.dart`)
Before every response, the service fetches **9 data sources in parallel**:
1. User wallet balance + initial capital (P&L computation)
2. Active holdings (symbol, quantity, average price)
3. Last 10 transactions
4. Latest 40 stock news articles with `sentiment_label` and linked stock symbol
5. Live market prices for 50 assets via Supabase RPC `get_stocks_with_sparklines`
6. Latest 10 community posts with sentiment + author name
7. Full asset dictionary (Arabic + English company names → ticker symbols, solves typo matching like "ابوثير" → ABUK)
8. User watchlist
9. User protection rules (alert % and auto-sell % per symbol)
10. Latest 50 AI predictions from `ai_predictions` table

**Strict system prompt** enforces:
- Natural Egyptian Arabic tone (no robotic phrases)
- No math formulas printed; only pre-computed results
- No name repetition
- Default fallback for missing news: _"مفيش أخبار أو تحديثات جديدة عن السهم ده النهاردة."_
- Max 1–3 short lines unless full summary requested

**Conversation history**: Rolling 12-entry window (6 user+AI turns)

**Daily summary** shortcut: Triggers a pre-built Arabic prompt asking for full portfolio P&L, stock performance, news highlights, and community mood.

**Friendly error handling**: Timeout, network errors, and 401 errors each produce contextual Arabic error messages.

### 📈 Technical Analysis Engine (`technical_analysis_service.dart`)

A pure-math, stateless service (no external APIs). All methods are static and side-effect-free.

| Indicator | Parameters | Signal Logic |
|---|---|---|
| EMA 10 | Period 10 | Price > EMA → Buy |
| EMA 20 | Period 20 | Price > EMA → Buy |
| EMA 50 | Period 50 | Price > EMA → Buy |
| EMA 100 | Period 100 | Price > EMA → Buy |
| RSI | Period 14 | <30 → Buy, >70 → Sell, else Neutral |
| MACD | 12, 26, 9 | Histogram > 0 → Buy, < 0 → Sell |
| Stochastic %K | Period 14, D=3 | <20 → Buy, >80 → Sell, else Neutral |
| Bollinger Bands | Period 20, 2σ | Price ≤ lower band AND RSI < 30 → +15% Buy bonus |

**Composite score**: Weighted average (50% trend EMAs + 50% oscillators) scaled to [-100, +100]

**Recommendations**: Strong Sell / Sell / Neutral / Buy / Strong Buy

**EGX-aware mode**: Adjusts for low-liquidity market characteristics (Bollinger bonus disabled for EGX)

### 📉 Technical Gauge Widget (`technical_gauge.dart`, 504 lines)

Custom `CustomPainter`-based semicircular gauge:
- 50 gradient arc segments (red → orange → green)
- Animated needle pointer rotating to score position
- **Two display modes**:
  - **TA mode**: Shows indicator vote breakdown (EMA/RSI/MACD/Stochastic rows with values and signals)
  - **AI mode** (`isAi: true`): Shows Bullish/Bearish labels, hides indicator rows
- Buy/Neutral/Sell count badges
- Bollinger bonus indicator banner (when triggered)
- Fully localized labels (Arabic/English via `S.of(context)`)

### 💼 Trading Simulation & Risk Management

#### Portfolio Page
- Wallet balance display + initial capital + total P&L
- Holdings list: asset card with live price, avg cost, quantity, unrealized P&L
- Quick navigation to Transaction History

#### Transaction History Page
- Full chronological trade log (buy/sell type, symbol, quantity, price, total value, timestamp)
- Filterable and scrollable

#### Protection Rules (`protection_rule_sheet.dart`, 15KB)
Per-asset configurable risk rules stored in Supabase `user_protection_rules`:
- **Alert threshold %**: Send push notification when position loss exceeds this %
- **Auto-liquidation threshold %**: Automatically execute a sell when drawdown hits this %
- **Toggle independently**: Can enable alert only, sell only, or both
- Fields: `symbol`, `alert_percentage`, `liquidation_percentage`, `is_alert_enabled`, `is_sell_enabled`, `last_alert_sent_at`

#### Portfolio Stats Card
- Summary card showing total invested value, current market value, P&L amount and %

### 🗨️ Post Details & Threaded Comments

`PostDetailsController` (401 lines) + widgets (25KB post_details_view, 13KB comment_item):

- **Nested threaded comments**: Tree structure (root comments → replies → replies-of-replies)
- `rootComments`: filtered list of top-level comments sorted chronologically
- `getThreadFor(rootId)`: recursive descent to build the full thread for any comment
- `getReplyCount(rootId)`: recursive count of all descendants
- **Reply-to mode**: Tap any comment to set `replyingTo`; input shows "@username" banner
- **Optimistic UI for likes**: Instant local update + debounced 500ms API call + rollback on error
- **Bookmark toggle**: Optimistic + rollback
- **Comment vote** (like/dislike): Optimistic with vote toggle logic
- **Cross-controller sync**: Updates propagate to `ProfileController.userPosts` and `CommunityController.posts` reactively
- **Notification triggers**:
  - Comment on post → `NotificationSenderService.notifyPostOwner()`
  - Reply to comment → `NotificationSenderService.notifyCommentOwner()`
  - Like post → `NotificationSenderService.notifyPostLike()`
- **Desktop wrapper** (`desktop_post_details_wrapper.dart`): Side-by-side post + thread layout for wide screens

### 👥 Community & Social Feed

- **Community page**: Mobile + Desktop adaptive layout
- Post cards with text, image previews, asset tags, sentiment chips
- Like, bookmark interactions with optimistic updates
- Shimmer skeleton loading state

### 👤 Profile Feature

| Page | Description |
|---|---|
| `profile_page.dart` | Own profile: stats, posts, bio, follow/edit buttons |
| `user_profile_page.dart` | View another user's public profile |
| `followers_following_page.dart` | Paginated followers + following tabs |
| `saved_posts_page.dart` | All posts bookmarked by the user |
| `create_post_sheet.dart` | Post creation bottom sheet |

**Create Post** sub-widgets:
- `build_text_field.dart` — rich text input
- `build_image_preview.dart` — image attachment preview with remove option
- `build_bottom_toolbar.dart` — image picker + sentiment selector
- `build_sentiment_chip.dart` — Bullish / Bearish / Neutral tag selector
- `build_user_info.dart` — author avatar + name header
- `create_post_inline_widget.dart` — inline post composer for desktop

**Profile stats**: posts count, followers, following, likes received

### 🔍 Search & News

| Page | Description |
|---|---|
| `search_page_mobile.dart` | Mobile search: assets + users unified search, results with stock cards |
| `search_page_desktop.dart` | Desktop search: two-column layout |
| `news_details_page.dart` | Full news article with title, content, source, date, TTS button, open URL |
| `all_news_page.dart` | Paginated list of all available news articles |

- **Search debounce**: 500ms after last keystroke
- **Stock search cards** (`search_stock_card_desktop.dart`): price, % change, sparkline
- **Sliver app bar** with sticky header for scroll behavior
- **TTS controller** (`news_tts_controller.dart`): Google TTS engine, Arabic auto-detect, error handling for missing language data

### 📰 News Summarization Feature

- `NewsSummaryPage`: Dedicated page showing AI-generated summary for a group of articles
- `NewsSummaryController`: Fetches articles, calls `SummarizeNewsUseCase` → `CerebrasAiService`
- `news_summarization_prompts.dart`: Configurable prompt templates for different summarization contexts
- Triggered from News tab on Asset Details page

### 💬 Stock Chat Rooms (`stock_chat`)

- `StockChatPage`: Real-time chat room per stock asset
- `ChatInputSection`: Message composition bar with send button
- **Supabase Realtime stream**: `GetChatStreamUseCase` returns a live `Stream<List<ChatMessage>>` from Supabase Realtime
- `StockChatRemoteDataSource`: Sends messages and subscribes to the chat channel
- Chat messages stored in Supabase with userId, symbol, content, timestamp

### 🔔 Notifications

- `NotificationPage`: Full notification list with read/unread state
- `NotificationItem` widget: Type-aware display (like, comment, follow, system)
- `NotificationController`: Fetches notifications, marks as read, handles Supabase Realtime subscription for live badge updates
- `NotificationSenderService` (`notification_sender_service.dart`, 10KB): Sends FCM push notifications peer-to-peer via Supabase Edge Functions or direct FCM API for: post likes, post comments, comment replies, follow events
- `GetPeerFcmTokenUseCase`: Retrieves target user's FCM token from `profiles` table
- `SendNotificationUseCase`: Posts notification record to Supabase + triggers push

### ⚙️ Settings & Personalization

| Page | Description |
|---|---|
| `settings_view.dart` / `settings_view_desktop.dart` | Main settings hub |
| `app_settings_page.dart` | App preferences (theme, language, notifications) |
| `menu_page.dart` | Profile menu (navigation hub) |
| `dark_mode_page.dart` | Theme toggle with live preview |
| `language_page.dart` | Arabic / English language switch |
| `edit_profile_page.dart` | Edit name, bio, avatar |
| `change_pass_page.dart` | Change password |
| `privacy_security_page.dart` | Security overview |
| `active_sessions_page.dart` | View and revoke active login sessions |
| `notifications_page.dart` | Notification preferences |
| `abou_egx_page.dart` | About EGX 360 (version, team) |
| `show_license_page.dart` | In-app open source license viewer |
| `portfolio_web_view_page.dart` | WebView for portfolio-related web content |
| `privacy_policy_page.dart` | Privacy policy |
| `help_support_page.dart` | Help and support |
| `how_to_use_page.dart` | App usage guide |
| `data_sources_page.dart` | Data sources and attributions |

**Profile widgets in Settings**:
- `build_profile_card.dart`: Avatar, name, email display card
- `build_simulation_card.dart`: Simulation wallet balance preview card

### 🎨 Core Design System

#### Colors (`app_colors.dart`)
- **Brand**: Teal `#28C0B1` + Cyan `#00F5FF` / `#00A9CC`
- **Dark mode**: Pure black background, `#212121` surface, `#1A1D29` overlay
- **Light mode**: `#EFEFF1` background, `#F6F8FA` surface
- **Trading**: `#26A69A` (green candle), `#EF5350` (red candle)
- **Glassmorphism**: `Colors.white.withOpacity(0.05)` background + `withOpacity(0.2)` border

#### Custom Background Widgets
- `CandlestickChildBackground`: Full-screen animated candlestick chart as a background widget
- `CandlestickPainter` + `InteractiveCandlestickPainter`: Custom painters with touch interaction
- `CandlestickData` entity: OHLC data model for the animated background
- `custom_background.dart`: Wrapper that applies the animated background to any child widget

#### Reusable Core Widgets
- `custom_appbar.dart`: Branded app bar with optional icon, back button
- `custom_dialogs.dart`: Confirmation and info dialog templates
- `custom_loading.dart`: Shimmer loading and spinner variants
- `custom_snackbar.dart`: Branded snackbar with color support
- `text_form_fileds_widget.dart`: Styled form fields with validation

---

## Named Routes Summary (29 total)

| Route | Page |
|---|---|
| `/welcome` | Welcome/onboarding screen |
| `/auth` | Login / Register |
| `/verify_email` | Email verification |
| `/forgotPass` | Forgot password |
| `/newPass` | Create new password |
| `/loyoutPage` | Main tab layout (home, markets, community, simulation) |
| `/showDetailsPage` | Post details + comments |
| `/profile` | Own user profile |
| `/user_profile` | Another user's public profile |
| `/followers_following` | Followers / following list |
| `/community` | Community feed |
| `/newsDetailsPage` | Full news article |
| `/allNewsPage` | All news listing |
| `/stockDetailsPage` | EGX stock asset details |
| `/cryptoDetailsPage` | Crypto asset details |
| `/currencyDetailsPage` | FX currency asset details |
| `/newsSummaryPage` | AI news summary |
| `/watchlist` | Watchlist page |
| `/trending-stocks` | Trending stocks (mobile + desktop) |
| `/notifications` | Notification center |
| `/saved_posts` | Bookmarked posts |
| `/portfolio` | Simulation portfolio |
| `/transaction-history` | Trade history |
| `/chatbot` | EGX AI chatbot (mobile + desktop) |
| `/search` | Search |
| `/menu` | Settings menu |

---

## Application Architecture

EGX 360 follows **Feature-First Clean Architecture** with three layers per feature:

```
lib/
├── main.dart                    # App bootstrap (9-step initialization sequence)
├── app.dart                     # GetMaterialApp: themes, l10n, routing, notification check
├── firebase_options.dart        # Generated Firebase config
├── generated/l10n.dart          # Auto-generated localization strings
├── l10n/                        # ARB files (app_en.arb, app_ar.arb)
│
├── core/
│   ├── Layout/                  # MainLayout, BottomNavBar, SideNavBar (desktop), LayoutController
│   ├── bindings/                # Shared GetX bindings for layout, community, profile, search, settings, stock_chat, post_details, news_details
│   ├── constants/               # AppColors, AppBreakpoints, AppDimensions, AppGaps, AppSizes, AppTextStyles, AppImages
│   ├── custom/
│   │   ├── background/          # CandlestickChildBackground, CandlestickPainter, InteractiveCandlestickPainter, CandlestickData, CustomBackground
│   │   ├── custom_appbar.dart
│   │   ├── custom_dialogs.dart
│   │   ├── custom_loading.dart
│   │   ├── custom_snackbar.dart
│   │   └── text_form_fileds_widget.dart
│   ├── data/entities/           # PostLocalModel (Floor entity), InitLocalData
│   ├── errors/                  # AppException hierarchy
│   ├── helper/                  # ContextExtensions, MarketStatusHelper
│   ├── routes/                  # AppPages (29 named routes), AppPagesHelper (initial route logic)
│   ├── services/
│   │   ├── cerebras_ai_service.dart         # Cerebras Llama 3.1-8B integration
│   │   ├── technical_analysis_service.dart  # EMA, RSI, MACD, Stochastic, Bollinger Bands
│   │   ├── technical_result.dart            # TechnicalResult, IndicatorVote, IndicatorSignal
│   │   ├── notification_service.dart        # FCM init + local notifications + initial message check
│   │   ├── notification_sender_service.dart # Peer-to-peer FCM push sender (likes, comments, follows)
│   │   ├── media_service.dart               # Image pick, compress, Supabase storage upload
│   │   ├── network_service.dart             # HTTP connectivity
│   │   ├── desktop_deep_link_service.dart   # Desktop OAuth deep link handler
│   │   └── permission_service.dart          # Runtime permission requests
│   ├── theme/                   # AppTheme (light/dark), LightTheme, DarkTheme, AppGradients
│   ├── utils/
│   │   ├── candle_aggregator.dart           # 1m → any OHLCV timeframe aggregation
│   │   ├── platform_detector.dart           # isMobile / isDesktop
│   │   ├── price_formatter.dart             # Financial number formatting
│   │   ├── responsive_layout.dart           # Mobile ↔ Desktop body switcher
│   │   ├── responsive_transition.dart       # Adaptive page transition
│   │   └── validator.dart                   # Form validation rules
│   └── widgets/
│       └── desktop_route_wrapper.dart       # Wraps any page with SideNavBar on desktop
│
└── features/
    ├── assets/       # Unified asset details (stocks, crypto, gold/silver, currencies)
    ├── auth/         # Login, register, forgot password, email verification, password reset, desktop auth
    ├── chatbot/      # EGX AI chatbot (Markdown UI, suggestion chips, typing animation, daily summary)
    ├── community/    # Social feed (posts, likes, bookmarks, shimmer loading)
    ├── home/         # Dashboard + trending stocks + watchlist page
    ├── markets/      # Advanced charting, drawing tools, indicators, order sheet, desktop sidebar
    ├── news_briefing/# AI news summarization (prompts config, summary page, controller)
    ├── notifications/# Push + in-app notifications (FCM, Supabase Realtime, read/unread)
    ├── post_details/ # Post view + nested threaded comments + reply + like/bookmark + cross-controller sync
    ├── profile/      # Own profile, view user profile, create post, saved posts, followers/following
    ├── search/       # Unified search, news details, all news, TTS controller
    ├── settings/     # Full settings hub with 14 sub-pages
    ├── simulation/   # Paper trading: portfolio, transactions, protection rules
    ├── stock_chat/   # Real-time per-stock chat rooms (Supabase Realtime stream)
    └── welcome/      # Animated candlestick onboarding screen
```

---

## Technologies Used

### Frontend
| Technology | Purpose |
|---|---|
| **Flutter** `^3.9.2` | Cross-platform (Android, iOS, Linux, Windows) |
| **Dart** | Language |
| **GetX** | State management, DI, routing |
| **Syncfusion Flutter Charts** | Candlestick/area charts, trackball |
| **FL Chart** | Sparklines, gauge fills |
| **Flutter ScreenUtil** | Responsive font/size scaling (design: 360×690) |
| **flutter_markdown** | Markdown rendering in chatbot AI responses |
| **flutter_tts** | TTS news reader (Arabic + English, Google TTS) |
| **webview_flutter** | In-app web view (portfolio web view, license viewer) |
| **flutter_localizations** | RTL + localization delegates |
| **flutter_screenutil** | Responsive sizing |

### Backend & Cloud
| Service | Purpose |
|---|---|
| **Supabase** | Auth, PostgreSQL, Realtime, Storage, Edge RPCs |
| **Firebase** | FCM push notifications |
| **Binance API** | REST + WebSocket crypto/commodity data |
| **Cerebras AI** | Llama 3.1-8B for chatbot + news summarization |

### Local Storage
| Library | Purpose |
|---|---|
| **Floor** | Type-safe SQLite ORM with code generation |
| **GetStorage** | Key-value store (theme, session) |

### Other Libraries
| Library | Purpose |
|---|---|
| **flutter_dotenv** | `.env` config (API keys) |
| **cached_network_image** | Image loading + caching |
| **flutter_local_notifications** | Local notification scheduling |
| **workmanager** | Background tasks |
| **image_picker / image_compress** | Media handling for post creation |
| **permission_handler** | Runtime permissions |
| **google_sign_in** | Google OAuth |
| **protocol_handler** | Desktop deep link (`io.supabase.flutter`) |
| **url_launcher** | Open news article URLs externally |
| **web_socket_channel** | Binance WebSocket streams |
| **intl** | Date/time/number formatting |

---

## Installation & Setup

### Prerequisites
- Flutter SDK `^3.9.2`
- Android Studio / Xcode
- Supabase project ([supabase.com](https://supabase.com))
- Firebase project ([console.firebase.google.com](https://console.firebase.google.com))
- Cerebras AI API key ([inference.cerebras.ai](https://inference.cerebras.ai))

### Step-by-Step

1. **Clone**
   ```bash
   git clone https://github.com/yourusername/egx360.git && cd egx360
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment file** — create `.env` in project root:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_APIKEY=your_supabase_anon_key
   CEREBRAS_APIKEY=your_cerebras_key
   ```

4. **Firebase setup**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

5. **Supabase tables** (create via migrations in `supabase/migrations/`):
   `stocks`, candle tables per asset, `posts`, `profiles`, `user_wallets`, `user_holdings`, `user_transactions`, `user_protection_rules`, `user_watchlist`, `stock_news`, `ai_predictions`, `notifications`, chat message tables, `currency_history`

6. **Generate Floor code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

7. **Run**
   ```bash
   flutter run                        # Dev
   flutter build apk --release        # Android APK
   flutter build appbundle --release  # Android Bundle
   flutter build ios --release        # iOS
   flutter build linux --release      # Linux Desktop
   ```

---

## Future Improvements

- **Price Alerts**: User-set price-target push notifications
- **Social Trading**: Copy-trade from top performers
- **Export**: Portfolio report as PDF/CSV
- **Advanced Analytics**: Sharpe ratio, beta, correlation
- **Chart Pattern Recognition**: Automated pattern detection
- **Home-screen Widgets**: Quick market glance widget

---

## Author Information

**Developer**: [Your Name]  
**Institution**: [University Name]  
**Department**: [Department Name]  
**Academic Year**: 2024–2025  
**Email**: [Email]  
**GitHub**: [GitHub URL]

---

## Acknowledgments

- **Supabase** — Backend, database, Realtime, storage
- **Firebase** — Push notification infrastructure
- **Binance** — Crypto/commodity market data APIs
- **Cerebras AI** — LLM inference for chatbot and summarization
- **Syncfusion** — Flutter charting components
- **Flutter Community** — Open source packages ecosystem

---

## License

[Specify license here]

---

## Version

| Field | Value |
|---|---|
| App Version | 1.0.0+1 |
| Flutter SDK | ^3.9.2 |
| Last Updated | March 2026 |

---

*README generated from a complete source-level audit of all files in `lib/` — March 2026.*
