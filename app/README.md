# EGX 360: Comprehensive Financial Markets Mobile Application

## Project Title
**EGX 360** - intelligence stock mekrt analysis and forcasting platform

---

## Short Professional Description

EGX 360 is a comprehensive mobile application designed to provide investors and traders with real-time market data, advanced technical analysis tools, and a social community platform for the Egyptian Exchange (EGX), cryptocurrencies, and commodities markets. The application addresses the challenge of fragmented financial information by consolidating multiple asset classes into a single, user-friendly interface with offline capabilities, intelligent data processing, and AI-powered news summarization.

The platform enables users to make informed investment decisions through real-time price tracking, interactive charting with technical indicators, paper trading simulation, and community-driven insights. By implementing a hybrid data strategy that combines WebSocket connections, REST APIs, and local database caching, the application ensures reliable performance even under varying network conditions.

---

## Key Features

### 📊 Real-Time Market Data & Advanced Charting
- **Multi-Asset Support**: Track cryptocurrencies (BTC, ETH, BNB, SOL), EGX stocks (TMGH, COMI, FWRY, SWDY, HRHO, ETEL), and commodities (Gold, Silver)
- **Real-Time Price Updates**: WebSocket connections for live cryptocurrency prices; intelligent polling for EGX stocks during market hours
- **Interactive Charts**: Candlestick and area chart visualizations with zoom, pan, and trackball functionality
- **Multiple Timeframes**: Support for 1-minute, 5-minute, 15-minute, 30-minute, 1-hour, 4-hour, daily, weekly, and monthly intervals
- **Technical Indicators**: Simple Moving Average (SMA), Exponential Moving Average (EMA), and Bollinger Bands with configurable parameters
- **Drawing Tools**: Trend lines, horizontal lines, vertical lines, and rectangle annotations for technical analysis
- **Volume Analysis**: Configurable volume bars for market depth analysis

### 💼 Trading Simulation & Portfolio Management
- **Paper Trading**: Virtual portfolio tracking with simulated buy/sell orders
- **Position Management**: Track holdings, profit/loss calculations, and transaction history
- **Order Integration**: Buy/sell interface seamlessly integrated with chart views
- **Portfolio Analytics**: Real-time position valuation and performance metrics

### 👥 Social Community & Engagement
- **Social Feed**: Dynamic feed where users share market analysis, news, and insights
- **Rich Interactions**: Like, comment, and reply functionality for community engagement
- **User Profiles**: Customizable profiles displaying activity, followers, and following lists
- **Follow System**: Build networks by following other investors and market influencers
- **Stock-Specific Chat Rooms**: Asset-focused discussion channels for focused conversations

### 🔍 Search & Discovery
- **Unified Search**: Intelligent search across stocks, cryptocurrencies, and user profiles
- **Trending Assets**: Discover popular market movers and trending stocks
- **Watchlist Management**: Track favorite assets with personalized watchlists
- **News Aggregation**: Latest market news with AI-powered summarization

### 🤖 AI-Powered Features
- **News Summarization**: Automated synthesis of multiple news articles into cohesive summaries using Cerebras AI (Llama 3.1-8B model)
- **Intelligent Data Processing**: Multi-day gap filling for EGX intraday data with market hours awareness
- **Smart Data Routing**: Hybrid strategy that intelligently routes data requests between APIs and local storage based on asset type and timeframe

### 🔔 Notifications & Alerts
- **Push Notifications**: Firebase Cloud Messaging integration for real-time alerts
- **In-App Notifications**: Real-time notification system via Supabase
- **Customizable Preferences**: User-configurable notification settings

### 🌐 Internationalization & Accessibility
- **Bilingual Support**: Full Arabic and English language support with RTL layout support
- **Theme System**: Light and Dark mode with dynamic theming
- **Offline-First Architecture**: Local database caching ensures core features work without internet connectivity

### 🔐 Security & Authentication
- **Secure Authentication**: Supabase-based authentication with email verification
- **Password Management**: Forgot password and password reset flows
- **Social Login**: Google Sign-In integration for seamless authentication

---

## Technologies Used

### Frontend
- **Flutter** (SDK 3.9.2): Cross-platform mobile application framework
- **Dart**: Programming language
- **GetX**: State management, dependency injection, and routing
- **Syncfusion Flutter Charts**: Advanced financial charting library
- **FL Chart**: Additional charting capabilities

### Backend & Cloud Services
- **Supabase**: Backend-as-a-Service for authentication, PostgreSQL database, real-time subscriptions, and storage
- **Firebase**: Cloud Messaging for push notifications and app analytics
- **Binance API**: REST API and WebSocket connections for cryptocurrency and commodity market data

### AI & Machine Learning
- **Cerebras AI API**: Large Language Model (Llama 3.1-8B) for news summarization and content synthesis

### Database
- **PostgreSQL** (via Supabase): Cloud database for user data, posts, notifications, and EGX stock historical data
- **SQLite** (via Floor): Local database for offline data caching and persistence

### Real-Time Communication
- **WebSocket**: Real-time bidirectional communication for live price updates
- **Supabase Realtime**: Real-time database subscriptions for notifications and social features

### Tools & Libraries
- **Floor**: Type-safe SQLite abstraction with code generation
- **HTTP**: REST API client for external service integration
- **WebSocket Channel**: WebSocket client implementation
- **Cached Network Image**: Efficient image loading and caching
- **Flutter Local Notifications**: Local notification scheduling
- **Workmanager**: Background task processing
- **Image Picker & Compress**: Media handling and optimization
- **Permission Handler**: Runtime permission management
- **Google Sign-In**: OAuth authentication
- **Internationalization (intl)**: Date, time, and number formatting

---

## System Architecture

EGX 360 follows a **Feature-First Clean Architecture** pattern, ensuring separation of concerns, testability, and maintainability. The architecture is organized into three primary layers:

### Architecture Layers

1. **Presentation Layer** (`lib/features/*/presentation/`)
   - **Pages**: User interface screens and layouts
   - **Widgets**: Reusable UI components
   - **Controllers**: State management using GetX reactive programming
   - **Bindings**: Dependency injection configuration

2. **Domain Layer** (`lib/features/*/domain/`)
   - **Entities**: Core business objects and models
   - **Repositories**: Abstract interfaces defining data operations
   - **Use Cases**: Business logic and application rules

3. **Data Layer** (`lib/features/*/data/`)
   - **Data Sources**: Remote (API) and local (database) data access
   - **Repositories Implementation**: Concrete implementations of domain repositories
   - **Models**: Data transfer objects (DTOs) for API communication

### Core Services Architecture

The application includes a centralized service layer (`lib/core/services/`) that provides:

- **NetworkService**: Manages HTTP requests, connectivity monitoring, and error handling
- **NotificationService**: Handles Firebase Cloud Messaging and local notifications
- **MediaService**: Image picking, compression, and storage operations
- **PermissionService**: Runtime permission requests and management
- **CerebrasAiService**: AI-powered news summarization integration

### Data Flow Strategy

The application implements a **hybrid data strategy** that optimizes performance and reliability:

1. **Cryptocurrencies**: Real-time WebSocket connections to Binance for live price updates
2. **EGX Stocks**: Supabase database queries with intelligent polling (20-second intervals during market hours: 10:00 AM - 2:45 PM, Sunday-Thursday)
3. **Commodities (Gold/Silver)**: Hybrid approach using Binance API/WebSocket for intraday data and Supabase for historical data
4. **Local Caching**: Floor database caches frequently accessed data for offline functionality

### Market Hours Intelligence

The system includes market-aware logic that:
- Automatically detects EGX trading hours (Sunday-Thursday, 10:00 AM - 2:45 PM Cairo Time)
- Adjusts polling frequency based on market status
- Filters weekend data (Friday & Saturday) from EGX stock charts
- Implements gap-filling algorithms for multi-day intraday data

---

## How the Project Works

### Application Flow

1. **Initialization** (`main.dart`)
   - Firebase and Supabase initialization
   - Local database setup (Floor)
   - Theme and state restoration from local storage
   - Notification service configuration

2. **Authentication Flow**
   - User registration/login via Supabase Auth
   - Optional Google Sign-In for social authentication
   - Email verification for new accounts
   - Password reset functionality

3. **Home & Market Overview**
   - Displays trending stocks and popular assets
   - Market summary with key statistics
   - Quick access to watchlist and portfolio

4. **Markets Feature - Charting System**
   - **Asset Selection**: Users search or select from popular assets
   - **Data Loading**: 
     - For crypto: Establishes WebSocket connection to Binance
     - For EGX stocks: Queries Supabase with market-hours-aware polling
     - For commodities: Hybrid API/database approach based on timeframe
   - **Chart Rendering**: Syncfusion charts display candlestick or area visualizations
   - **Technical Analysis**: Users can overlay indicators (SMA, EMA, Bollinger Bands) and use drawing tools
   - **Trading Integration**: Buy/sell buttons open order sheet integrated with simulation portfolio

5. **Community & Social Features**
   - Users create posts with text, images, and asset tags
   - Posts appear in community feed with engagement metrics
   - Users can like, comment, and follow other users
   - Stock-specific chat rooms enable focused discussions

6. **Trading Simulation**
   - Users place virtual buy/sell orders from chart interface
   - Portfolio tracks positions, average prices, and P&L
   - Transaction history maintains complete audit trail
   - Real-time position valuation updates with current market prices

7. **Search & Discovery**
   - Unified search across assets and users
   - Results filtered by relevance and popularity
   - Quick access to asset details and user profiles

8. **News & AI Summarization**
   - News articles aggregated from multiple sources
   - Cerebras AI service synthesizes articles into cohesive summaries
   - Summaries displayed in user-friendly format with source attribution

9. **Notifications**
   - Firebase Cloud Messaging delivers push notifications
   - Supabase real-time subscriptions handle in-app notifications
   - Users receive alerts for price movements, social interactions, and system updates

### Data Processing Pipeline

1. **Real-Time Data (Cryptocurrencies)**
   - WebSocket connection established to Binance
   - Price updates received and processed in real-time
   - Chart automatically updates with new candle data
   - Connection status monitored and auto-reconnection implemented

2. **Polling Data (EGX Stocks)**
   - Market hours detection determines polling activation
   - 20-second interval queries to Supabase during trading hours
   - Data processed through `EgxDataProcessor` for gap filling and chronological ordering
   - Weekend and non-trading hours automatically excluded

3. **Data Aggregation**
   - `CandleAggregator` utility converts 1-minute data to higher timeframes (5m, 15m, 30m, 1H, 4H)
   - Aggregation follows standard OHLC (Open, High, Low, Close) rules
   - Volume data aggregated accordingly

4. **Offline Support**
   - Frequently accessed data cached in local Floor database
   - Offline mode provides access to cached charts and portfolio data
   - Sync occurs automatically when connectivity restored

---

## Installation & Setup

### Prerequisites

- **Flutter SDK**: Version 3.9.2 or higher ([Installation Guide](https://flutter.dev/docs/get-started/install))
- **Dart SDK**: Included with Flutter installation
- **Android Studio / Xcode**: For Android/iOS development
- **Supabase Account**: For backend services ([Sign up](https://supabase.com))
- **Firebase Account**: For push notifications ([Console](https://console.firebase.google.com))
- **Cerebras AI API Key**: For news summarization features
- **Binance API Access**: Public API endpoints (no authentication required for market data)

### Step-by-Step Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/egx360.git
   cd egx360
   ```

2. **Install Flutter Dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Configuration**
   
   Create a `.env` file in the root directory:
   ```env
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_APIKEY=your_supabase_anon_key
   ```
   
   **Note**: The `.env` file is already configured in `pubspec.yaml` assets section.

4. **Firebase Setup**
   
   - Install FlutterFire CLI:
     ```bash
     dart pub global activate flutterfire_cli
     ```
   
   - Configure Firebase for your project:
     ```bash
     flutterfire configure
     ```
   
   - This generates `firebase_options.dart` in the `lib/` directory
   
   - Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are properly configured

5. **Supabase Database Setup**
   
   - Create necessary tables in your Supabase project:
     - Users, posts, notifications, stocks, candles tables
     - Configure Row Level Security (RLS) policies
     - Set up real-time subscriptions if needed
   
   - Refer to `supabase/migrations/` directory for SQL migration scripts

6. **Local Database Generation**
   
   - Generate Floor database code:
     ```bash
     flutter pub run build_runner build --delete-conflicting-outputs
     ```

7. **Run the Application**
   
   **Development Mode:**
   ```bash
   flutter run
   ```
   
   **Release Build (Android):**
   ```bash
   flutter build apk --release
   # or for App Bundle
   flutter build appbundle --release
   ```
   
   **Release Build (iOS):**
   ```bash
   flutter build ios --release
   ```

### Platform-Specific Configuration

**Android:**
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Configure `android/app/build.gradle.kts` for signing and build variants

**iOS:**
- Minimum iOS: 12.0
- Configure `ios/Runner.xcodeproj` for signing and capabilities
- Ensure push notification capabilities are enabled

---

## Usage Instructions

### Getting Started

1. **First Launch**
   - The app displays a welcome/onboarding screen
   - Users can choose to sign up or log in
   - Google Sign-In option available for quick authentication

2. **Authentication**
   - **Sign Up**: Create account with email and password
   - **Email Verification**: Verify email address (if required)
   - **Login**: Access existing account
   - **Forgot Password**: Reset password via email link

3. **Exploring Markets**
   - Navigate to "Markets" tab from bottom navigation
   - Search for assets or select from popular list
   - Select timeframe (1m, 5m, 1H, 1D, etc.)
   - Toggle chart type (Candlestick/Area)
   - Add technical indicators from toolbar
   - Use drawing tools for technical analysis

4. **Trading Simulation**
   - Open order sheet from chart interface
   - Select buy or sell order type
   - Enter quantity and review order details
   - Execute order to add to virtual portfolio
   - View portfolio in "Simulation" tab
   - Track P&L and position details

5. **Community Features**
   - Navigate to "Community" tab
   - View feed of posts from followed users
   - Create new post with text, images, or asset tags
   - Like, comment, and share posts
   - Follow users to build network
   - Access user profiles for detailed information

6. **Search & Discovery**
   - Use search bar to find stocks, crypto, or users
   - Filter results by category
   - View trending assets on home screen
   - Add assets to watchlist for quick access

7. **Settings & Customization**
   - Access settings from profile menu
   - Toggle between light and dark themes
   - Configure notification preferences
   - Switch between Arabic and English
   - Manage account settings

### Advanced Features

- **Chart Drawing Tools**: Long-press on chart to access drawing tools menu
- **Multiple Indicators**: Overlay multiple indicators simultaneously for comprehensive analysis
- **Portfolio Analytics**: View detailed breakdown of holdings and performance metrics
- **News Summarization**: AI-generated summaries appear automatically in news sections
- **Offline Mode**: Cached data accessible without internet connection

---

## Screenshots

<!-- Add screenshots here with proper formatting -->
<!-- Example:
![Home Screen](screenshots/home.png)
![Markets Chart](screenshots/markets.png)
![Community Feed](screenshots/community.png)
![Trading Simulation](screenshots/simulation.png)
![Profile](screenshots/profile.png)
-->

*Screenshots will be added to demonstrate key features and user interface.*

---

## Future Improvements

### Technical Enhancements
- **Additional Technical Indicators**: RSI (Relative Strength Index), MACD (Moving Average Convergence Divergence), Stochastic Oscillator
- **Advanced Drawing Tools**: Fibonacci retracement levels, Elliott Wave annotations
- **Chart Pattern Recognition**: Automated detection of common chart patterns (head and shoulders, triangles, etc.)
- **Performance Optimization**: Further optimization of chart rendering for large datasets (1000+ candles)
- **Data Compression**: Implement data compression for historical data storage

### Feature Additions
- **Price Alerts**: User-configurable price alerts with push notifications
- **Advanced Portfolio Analytics**: Risk metrics, Sharpe ratio, correlation analysis
- **Social Trading**: Copy trading features allowing users to follow successful traders
- **News Sentiment Analysis**: AI-powered sentiment analysis of news articles
- **Multi-Portfolio Support**: Support for multiple virtual portfolios
- **Export Functionality**: Export portfolio data and charts as PDF/CSV
- **Widget Support**: Home screen widgets for quick market overview

### User Experience
- **Tutorial System**: Interactive onboarding for new users
- **Accessibility Improvements**: Enhanced support for screen readers and accessibility features
- **Custom Themes**: User-customizable color schemes beyond light/dark modes
- **Gesture Improvements**: Enhanced chart interaction gestures
- **Offline Sync**: Improved synchronization when connectivity restored

---

## Author Information

**Project Developer**: [Your Name]  
**Institution**: [Your University/Institution Name]  
**Department**: [Your Department, e.g., Computer Science, Software Engineering]  
**Academic Year**: [Academic Year, e.g., 2024-2025]  
**Email**: [Your Email Address]  
**GitHub**: [Your GitHub Profile URL]

---

## Academic Context

### Graduation Project

This project was developed as part of the **Graduation Project** requirement for the [Degree Program, e.g., Bachelor of Science in Computer Science] at [University Name]. The project demonstrates the application of software engineering principles, mobile application development, real-time data processing, and integration of modern cloud services and AI technologies.

### Project Objectives

1. **Technical Objectives**:
   - Implement a cross-platform mobile application using Flutter framework
   - Design and implement a scalable architecture following Clean Architecture principles
   - Integrate multiple data sources (REST APIs, WebSockets, databases) for real-time market data
   - Develop efficient data processing algorithms for financial time-series data
   - Implement offline-first architecture with local data caching

2. **Functional Objectives**:
   - Provide comprehensive market data visualization for multiple asset classes
   - Enable technical analysis through interactive charts and indicators
   - Facilitate community engagement through social features
   - Support paper trading simulation for educational purposes
   - Integrate AI-powered content summarization

3. **Learning Outcomes**:
   - Mastery of Flutter and Dart programming
   - Understanding of real-time data processing and WebSocket communication
   - Experience with cloud services (Supabase, Firebase)
   - Knowledge of financial market data structures and technical analysis
   - Application of software architecture patterns and best practices

### Technologies & Concepts Demonstrated

- **Mobile Development**: Flutter framework, cross-platform development
- **Architecture Patterns**: Clean Architecture, Repository Pattern, Dependency Injection
- **State Management**: Reactive programming with GetX
- **Real-Time Communication**: WebSocket protocols, real-time subscriptions
- **Database Management**: SQLite (local), PostgreSQL (cloud), ORM with Floor
- **Cloud Services**: Backend-as-a-Service (Supabase), Firebase services
- **AI Integration**: Large Language Model API integration for content generation
- **Data Processing**: Time-series data aggregation, gap filling algorithms
- **UI/UX Design**: Material Design, responsive layouts, internationalization

### Project Scope

The project encompasses a full-stack mobile application with:
- **Frontend**: Complete Flutter application with 15+ feature modules
- **Backend Integration**: Supabase for authentication, database, and real-time features
- **External APIs**: Binance API for cryptocurrency data, Cerebras AI for summarization
- **Local Storage**: SQLite database for offline functionality
- **Real-Time Features**: WebSocket connections, push notifications, live updates

---

## Acknowledgments

- **Binance**: For providing comprehensive cryptocurrency and commodity market data APIs
- **Supabase**: For backend infrastructure and excellent developer experience
- **Firebase**: For push notification services and cloud infrastructure
- **Syncfusion**: For providing advanced Flutter charting components
- **Cerebras AI**: For AI-powered content generation capabilities
- **Flutter Community**: For the extensive ecosystem of packages and resources
- **Open Source Contributors**: For the various packages that made this project possible

---

## License

[Specify your license here, e.g., MIT License, Proprietary, etc.]

---

## Version Information

- **Application Version**: 1.0.0+1
- **Flutter SDK**: ^3.9.2
- **Dart SDK**: ^3.9.2
- **Last Updated**: December 2024

---

## Contact & Support

For questions, issues, or contributions regarding this project, please contact:

**Email**: [Your Email]  
**GitHub Issues**: [GitHub Repository Issues URL]  
**Project Repository**: [GitHub Repository URL]

---

*This README document provides a comprehensive overview of the EGX 360 graduation project. For detailed technical documentation, please refer to the inline code comments and architecture documentation within the codebase.*
