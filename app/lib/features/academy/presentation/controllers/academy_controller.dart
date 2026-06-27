import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:egx/core/services/notification_service.dart';
import 'package:egx/core/constants/app_colors.dart';

class ModuleData {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<LessonData> lessons;

  ModuleData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.lessons,
  });
}

class LessonData {
  final String id;
  final String title;
  final IconData icon;
  final String content;
  final String? imagePath;
  double progress;
  bool isLocked;

  LessonData({
    required this.id,
    required this.title,
    required this.icon,
    this.content = "",
    this.imagePath,
    this.progress = 0.0,
    this.isLocked = true,
  });
}

class AcademyController extends GetxController {
  final _storage = GetStorage();
  final String _storageKey = 'completed_lessons_v1';

  List<ModuleData> modules = [];
  double globalProgress = 0.0;
  
  final RxInt streakCount = 0.obs;
  final RxInt xpCount = 0.obs;
  final RxString lastActiveDate = "".obs;
  final RxBool showXpAnimation = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initData();
    _loadProgress();
    _loadGamificationData();
    _checkStreakAlert();
  }

  void _loadGamificationData() {
    streakCount.value = _storage.read('streak_count') ?? 0;
    xpCount.value = _storage.read('xp_count') ?? 0;
    lastActiveDate.value = _storage.read('last_active_date') ?? "";
    update();
  }

  void _checkStreakAlert() {
    String today = DateTime.now().toIso8601String().split('T').first;
    if (lastActiveDate.value != today && streakCount.value > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          "Keep the flame alive! 🔥", 
          "Complete a lesson today to maintain your ${streakCount.value}-day streak.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.deepOrangeAccent,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          icon: const Icon(Icons.local_fire_department, color: Colors.amber),
          duration: const Duration(seconds: 5),
        );
      });
    }
  }

  LessonData? getNextLesson() {
    for (var module in modules) {
      for (var lesson in module.lessons) {
        if (!lesson.isLocked && lesson.progress < 1.0) {
          return lesson;
        }
      }
    }
    return null;
  }

  Color? getModuleColorForLesson(String lessonId) {
    for (var module in modules) {
      for (var lesson in module.lessons) {
        if (lesson.id == lessonId) return module.color;
      }
    }
    return Colors.purpleAccent;
  }

  void _initData() {
    modules = [
      ModuleData(
        id: "mod_1",
        title: "Module 1",
        subtitle: "Markets & Charting",
        icon: Icons.public,
        color: AppColors.primary,
        lessons: [
          LessonData(
            id: "les_1_1",
            title: "The Financial Markets",
            icon: Icons.account_balance,
            imagePath: "assets/images/lesson_financial_markets_1779935319426.png",
            content: "Welcome to EGX360! You now have the world at your fingertips, but every market plays by different rules.\n\n• EGX & US Stocks: You are buying actual ownership (shares) in real companies like Apple or CIB. Driven by earnings and corporate news.\n• Forex: The global currency exchange. You trade pairs like EUR/USD, betting on the strength of one economy against another.\n• Crypto: Decentralized digital assets. Highly volatile, driven by technology adoption and market sentiment.\n• Metals: Gold and Silver act as 'Safe Havens'. When the stock market crashes, investors flock here to protect their wealth.\n\n[ 🖼️ IMAGE PLACEHOLDER ]\n\nUnderstanding which arena you are playing in—and its unique risks—is the absolute first step to mastering it.",
          ),
          LessonData(
            id: "les_1_2",
            title: "Hours & Sessions",
            icon: Icons.schedule,
            imagePath: "assets/images/lesson_market_hours_1779935332294.png",
            content: "Not all markets sleep at the same time. Time is literally money.\n\nCrypto is the wild west; it runs 24/7, 365 days a year. It never closes.\nTraditional markets like the Egyptian Exchange (EGX) and US Stocks have strict opening and closing bells. If news breaks after hours, you have to wait until the next day to trade, which can cause 'price gaps'.\n\n[ 🖼️ IMAGE PLACEHOLDER ]\n\nForex trades around the clock on weekdays but pauses on weekends. Knowing your market's active sessions (like the overlap between London and New York sessions) is crucial for finding the best trading opportunities.",
          ),
          LessonData(
            id: "les_1_3",
            title: "Candlestick Anatomy",
            icon: Icons.candlestick_chart,
            imagePath: "assets/images/lesson_candlestick_anatomy_1779935346423.png",
            content: "Candlesticks are the heartbeat of the market. They tell a story of the battle between buyers and sellers over a specific period of time. Each candle shows four things: Open, High, Low, and Close (OHLC).\n\n[ 🖼️ IMAGE PLACEHOLDER ]\n\nA green body means the price went up (Bulls are winning). A red body means it went down (Bears are in control). The thin lines at the top and bottom are called 'wicks' or 'shadows'. A long wick at the bottom means sellers tried to push the price down, but buyers aggressively bought it back up. This is called 'Price Rejection' and is a powerful signal!",
          ),
          LessonData(
            id: "les_1_4",
            title: "Market Timeframes",
            icon: Icons.access_time,
            imagePath: "assets/images/lesson_timeframes_1779935360038.png",
            content: "Timeframes dictate the speed and style of your trading game.\n\n• Scalping (1m - 5m charts): Extremely fast-paced. Trades last minutes.\n• Day Trading (15m - 1H charts): Fast-paced, reacting to intraday moves. All trades are closed before you sleep.\n• Swing Trading (4H - 1D charts): Holding trades for days or weeks to catch medium-term trends.\n• Investing (1W - 1M charts): Filters out the daily noise, offering a calm, clear picture for long-term growth.\n\n[ 🖼️ IMAGE PLACEHOLDER ]\n\nAlways check the higher timeframe to see the 'big picture' before placing a trade on a lower timeframe.",
          ),
          LessonData(
            id: "les_1_5",
            title: "Line & Area Charts",
            icon: Icons.show_chart,
            imagePath: "assets/images/lesson_line_area_chart_1779935388507.png",
            content: "While candlesticks are great, sometimes they show too much 'noise'.\n\nLine charts simplify everything by only plotting and connecting the closing prices. By stripping away the extreme highs and lows (wicks), you get a pure, undeniable view of the overall trend direction.\n\n[ 🖼️ IMAGE PLACEHOLDER ]\n\nArea charts are similar but fill the space below the line with color, which visually helps you gauge the momentum and weight of the market movement.",
          ),
          LessonData(
            id: "les_1_6",
            title: "Bar Charts",
            icon: Icons.insert_chart_outlined,
            imagePath: "assets/images/lesson_bar_charts_1779935401714.png",
            content: "Bar charts display the exact same OHLC (Open, High, Low, Close) data as candlesticks, but they do it using a single vertical line with two small horizontal ticks.\n\n[ 🖼️ IMAGE PLACEHOLDER ]\n\nThe small tick on the left is the Open price, and the tick on the right is the Close price. Many classic Western traders prefer Bar Charts because they emphasize the High-Low range without the visual weight of thick candlestick bodies.",
          ),
          LessonData(
            id: "les_1_7",
            title: "Heikin-Ashi",
            icon: Icons.ssid_chart,
            imagePath: "assets/images/lesson_heikin_ashi_1779935415578.png",
            content: "Heikin-Ashi means 'average pace' in Japanese. This is a massive cheat code for riding trends!\n\nUnlike traditional candlesticks, Heikin-Ashi uses a modified mathematical formula to average out the price movements. This completely smooths out the chart.\n\n[ 🖼️ IMAGE PLACEHOLDER ]\n\nInstead of seeing choppy red and green alternating candles, you will see a solid block of green candles moving up, or red candles moving down. It filters out market noise and makes staying in a profitable trade much less stressful.",
          ),
          LessonData(
            id: "les_1_8",
            title: "Renko Charts",
            icon: Icons.waterfall_chart,
            imagePath: "assets/images/lesson_renko_charts_1779935430325.png",
            content: "Renko charts are entirely unique because they completely ignore time and volume! \n\nA new 'brick' is only drawn when the price moves a specific predetermined amount (e.g., \$5). If the price doesn't move \$5, the chart doesn't move, even if a whole week passes.\n\n[ 🖼️ IMAGE PLACEHOLDER ]\n\nThis is the ultimate tool for filtering out minor price fluctuations. It only shows you true, significant price movements.",
          ),
        ],
      ),
      ModuleData(
        id: "mod_2",
        title: "Module 2",
        subtitle: "Trading Mechanics",
        icon: Icons.balance,
        color: Colors.orangeAccent,
        lessons: [
          LessonData(
            id: "les_2_1",
            title: "Order Types",
            icon: Icons.shopping_cart_checkout,
            imagePath: "assets/images/lesson_order_types_1779935443957.png",
            content: "How you enter the market can be the difference between profit and loss.\n\nA 'Market Order' tells your broker: 'Buy this right now, I don't care what the exact price is.' It guarantees execution, but you might get a worse price if the market is moving fast (Slippage).\n\n[ 🖼️ IMAGE PLACEHOLDER ]\n\nA 'Limit Order' tells your broker: 'I only want to buy this if the price drops to \$100. Not a penny more.' It guarantees your price, but if the market never reaches \$100, your trade will never execute.",
          ),
          LessonData(
            id: "les_2_2",
            title: "Settlement Mechanics",
            icon: Icons.swap_horiz,
            imagePath: "assets/images/lesson_settlement_1779935457930.png",
            content: "When you buy a stock on the EGX, you don't actually own it that exact second. It usually takes two business days for the shares and cash to fully exchange hands. This is called T+2 settlement.\n\n[ 🖼️ IMAGE PLACEHOLDER ]\n\nSome brokers allow T+0 (same-day margin trading). In Crypto and Forex, however, execution and settlement are instant via blockchain or electronic matching. Once you click buy, it is instantly in your wallet.",
          ),
          LessonData(
            id: "les_2_3",
            title: "Leverage & Margin",
            icon: Icons.trending_up,
            imagePath: "assets/images/lesson_leverage_1779935496393.png",
            content: "Leverage is a double-edged sword, incredibly common in Crypto and Forex.\n\nIt allows you to trade with borrowed money. For example, 10x leverage means you can control \$1,000 worth of Bitcoin with only \$100 of your own money.\n\n[ 🖼️ IMAGE PLACEHOLDER ]\n\nWhile it multiplies your profits by 10x if the price goes up, it also multiplies your losses. If the price drops just 10%, your entire \$100 is wiped out instantly (Liquidated). Use it with extreme caution and professional risk management.",
          ),
          LessonData(
            id: "les_2_4",
            title: "Position Management",
            icon: Icons.shield_outlined,
            imagePath: "assets/images/lesson_position_management_1779935508943.png",
            content: "A professional never, ever enters a trade without a pre-planned exit strategy.\n\nBefore you buy, you must set a 'Stop Loss'. This is an automated order that sells your position if the price drops to a certain level, capping your losses so you live to trade another day.\n\n[ 🖼️ IMAGE PLACEHOLDER ]\n\nYou should also set a 'Take Profit' to automatically lock in your gains when the price hits your target. Do not let greed turn a winning trade into a losing one.",
          ),
        ],
      ),
      ModuleData(
        id: "mod_3",
        title: "Module 3",
        subtitle: "Technical Analysis",
        icon: Icons.analytics,
        color: Colors.greenAccent,
        lessons: [
          LessonData(
            id: "les_3_1",
            title: "Support & Resistance",
            icon: Icons.stacked_line_chart,
            imagePath: "assets/images/lesson_support_resistance_1779935523255.png",
            content: "The market is bound by invisible psychological floors and ceilings.\n\n'Support' is a price level where the asset is considered 'cheap', causing buyers to step in aggressively and bounce the price up (a floor).\n'Resistance' is a level where the asset is considered 'expensive', causing sellers to dump their shares and knock the price down (a ceiling).\n\n[ 🖼️ IMAGE PLACEHOLDER ]\n\nWhen Support breaks, it often flips to become new Resistance. Connecting these levels diagonally across charts creates Trend Lines.",
          ),
          LessonData(
            id: "les_3_2",
            title: "Moving Averages",
            icon: Icons.moving,
            imagePath: "assets/images/lesson_moving_averages_1779935540135.png",
            content: "Moving Averages (MA) smooth out chaotic price action into a single flowing line, helping you identify the true trend.\n\nA Simple Moving Average (SMA) looks at the average price over a set number of days.\nAn Exponential Moving Average (EMA) does the same, but gives more mathematical weight to the most recent prices.\n\n[ 🖼️ IMAGE PLACEHOLDER ]\n\nThis makes the EMA hug the current price closer and react much faster to sudden market changes, making it the favorite for day traders. Watch out for a 'Golden Cross'—when a short-term MA crosses above a long-term MA, signaling a massive bull run!",
          ),
          LessonData(
            id: "les_3_3",
            title: "Momentum Oscillators",
            icon: Icons.speed,
            imagePath: "assets/images/lesson_rsi_oscillator_1779935551891.png",
            content: "Price tells you where the market is going, but Momentum Oscillators (like RSI and MACD) tell you how fast the car is driving, and if it's running out of gas.\n\nThe RSI (Relative Strength Index) oscillates between 0 and 100. \n\n[ 🖼️ IMAGE PLACEHOLDER ]\n\nIf the RSI spikes above 70, the asset is 'Overbought'—people are too greedy, and a pullback is likely. If it crashes below 30, it is 'Oversold'—people are panicking, and it's likely a great time to buy the dip.",
          ),
          LessonData(
            id: "les_3_4",
            title: "Volatility Indicators",
            icon: Icons.blur_linear,
            imagePath: "assets/images/lesson_bollinger_bands_1779935564315.png",
            content: "Bollinger Bands act like a dynamic rubber band wrapping around the price.\n\nThey expand and contract based on how volatile the market is. When the market is quiet and boring, the bands squeeze tightly together.\n\n[ 🖼️ IMAGE PLACEHOLDER ]\n\nThe market hates being quiet. A 'squeeze' is usually the calm before the storm. When the bands finally snap and widen out, a massive, violent breakout happens in that direction.",
          ),
          LessonData(
            id: "les_3_5",
            title: "Fibonacci Retracement",
            icon: Icons.format_align_center,
            imagePath: "assets/images/lesson_fibonacci_1779970428890.png",
            content: "Markets breathe. They inhale and exhale, rarely moving in a straight line. After a huge jump, they 'pull back' or retrace before continuing up.\n\nFibonacci tools draw horizontal lines at key mathematical ratios (like 38.2%, 50%, and 61.8%) derived from nature.\n\n[ 🖼️ IMAGE PLACEHOLDER ]\n\nThese lines act as magical magnets. Institutional algorithms use them constantly, meaning a pullback will very frequently stop exactly at a Fibonacci level before rocketing back up. This is how pros buy the dip perfectly.",
          ),
        ],
      ),
      ModuleData(
        id: "mod_4",
        title: "Module 4",
        subtitle: "EGX360 AI Engine",
        icon: Icons.psychology,
        color: Colors.purpleAccent,
        lessons: [
          LessonData(
            id: "les_4_1",
            title: "The Prediction Score",
            icon: Icons.score,
            imagePath: "assets/images/lesson_ai_prediction_score_1779970445421.png",
            content: "Our AI model is a quantitative powerhouse. It crunches purely historical price and volume data, stripping away human emotion to give you a purely mathematical edge.\n\n[ 🖼️ IMAGE PLACEHOLDER ]\n\nIt translates complex algorithmic math into a simple probability score. A score over 80% means the AI detects a historical pattern that strongly suggests a Buy. A score under 20% flashes a Strong Sell warning. It's your ultimate compass.",
          ),
          LessonData(
            id: "les_4_2",
            title: "Power of Ensembles",
            icon: Icons.layers,
            imagePath: "assets/images/lesson_ensemble_ai_1779970465838.png",
            content: "Behind the scenes, we don't just rely on one algorithm. We use an 'Ensemble' of cutting-edge machine learning models like XGBoost and LightGBM.\n\n[ 🖼️ IMAGE PLACEHOLDER ]\n\nThink of it as asking a diverse team of brilliant experts instead of just one person. One expert might be wrong, but by mathematically combining their votes, we filter out the noise and deliver highly robust, accurate predictions.",
          ),
          LessonData(
            id: "les_4_3",
            title: "News Sentiment Analysis",
            icon: Icons.article,
            imagePath: "assets/images/lesson_news_sentiment_1779970486313.png",
            content: "While the Prediction Score looks at math, our Natural Language Processing (NLP) tool reads the human side of the market!\n\nIt scans thousands of live articles, press releases, and news headlines in real-time. It then categorizes the overall mood of the market as Positive, Neutral, or Negative.\n\n[ 🖼️ IMAGE PLACEHOLDER ]\n\nCombining this human sentiment with the AI's quantitative math gives you a holistic view, helping you avoid trading against massive breaking news.",
          ),
          LessonData(
            id: "les_4_4",
            title: "Technical Gauge",
            icon: Icons.speed_outlined,
            imagePath: "assets/images/lesson_technical_gauge_1779970500680.png",
            content: "Looking at 15 different indicators (like RSI, MACD, and Multiple MAs) all at once on a chart can make your head spin and cause 'analysis paralysis'.\n\n[ 🖼️ IMAGE PLACEHOLDER ]\n\nThe Technical Gauge solves this by aggregating all of those indicators into a single, beautiful dashboard dial. At a glance, you instantly know if the combined technical consensus is screaming Buy, Neutral, or Sell.",
          ),
          LessonData(
            id: "les_4_5",
            title: "AI is a Co-pilot",
            icon: Icons.warning_amber,
            imagePath: "assets/images/lesson_ai_copilot_1779970535652.png",
            content: "AI is an incredibly powerful tool, but it is not a crystal ball.\n\nNo mathematical model can predict unpredictable 'black swan' events, sudden wars, or unexpected government regulations.\n\n[ 🖼️ IMAGE PLACEHOLDER ]\n\nUse the EGX360 AI as your advanced co-pilot to make informed, data-driven decisions and manage your risk—but never trade blindly. Always keep your hands on the steering wheel.",
          ),
        ],
      ),
    ];
  }

  void _loadProgress() {
    List<dynamic> completedIds = _storage.read<List<dynamic>>(_storageKey) ?? [];
    
    int totalLessons = 0;
    int completedCount = 0;
    bool nextIsUnlocked = true; // The first lesson is always unlocked

    for (var module in modules) {
      for (var lesson in module.lessons) {
        totalLessons++;
        
        if (completedIds.contains(lesson.id)) {
          lesson.progress = 1.0;
          lesson.isLocked = false;
          completedCount++;
          nextIsUnlocked = true; // Unlock the one right after this
        } else {
          lesson.progress = 0.0;
          lesson.isLocked = !nextIsUnlocked;
          nextIsUnlocked = false; // Block all subsequent ones until this is completed
        }
      }
    }
    
    globalProgress = totalLessons > 0 ? (completedCount / totalLessons) : 0.0;
    update(); // Triggers GetBuilder UI update
  }

  void completeLesson(String lessonId) {
    List<dynamic> completedIds = _storage.read<List<dynamic>>(_storageKey) ?? [];
    if (!completedIds.contains(lessonId)) {
      completedIds.add(lessonId);
      _storage.write(_storageKey, completedIds);
      
      // Update Gamification
      xpCount.value += 50;
      _storage.write('xp_count', xpCount.value);

      String today = DateTime.now().toIso8601String().split('T').first;
      if (lastActiveDate.value != today) {
        if (lastActiveDate.value.isNotEmpty) {
          DateTime lastDate = DateTime.parse(lastActiveDate.value);
          DateTime now = DateTime.parse(today);
          if (now.difference(lastDate).inDays > 1) {
            streakCount.value = 1; // broken
          } else {
            streakCount.value++; // maintained
          }
        } else {
          streakCount.value = 1;
        }
        lastActiveDate.value = today;
        _storage.write('streak_count', streakCount.value);
        _storage.write('last_active_date', lastActiveDate.value);
      }

      _loadProgress(); 
      
      // Schedule background push notification for 24 hours from now
      bool academyAlerts = _storage.read('academyAlerts') ?? true;
      if (academyAlerts) {
        NotificationService.scheduleStreakReminder(streakCount.value);
      }

      // Trigger inline UI animation
      showXpAnimation.value = true;
      Future.delayed(const Duration(seconds: 2), () {
        showXpAnimation.value = false;
        update();
      });

      update();
    }
  }
}
