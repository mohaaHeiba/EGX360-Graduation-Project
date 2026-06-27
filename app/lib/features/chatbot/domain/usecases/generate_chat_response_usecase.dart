import 'package:egx/features/chatbot/domain/entities/chatbot_context_data.dart';
import 'package:egx/features/chatbot/domain/entities/chatbot_intent.dart';
import 'package:egx/features/chatbot/domain/entities/conversation_state.dart';
import 'package:egx/features/chatbot/domain/repositories/chatbot_repository.dart';

/// Assembles a surgical, data-grounded system prompt then streams the LLM
/// response via [ChatbotRepository.generateFinalResponseStream].
///
/// DESIGN PRINCIPLES:
/// - Zero hallucination: every section is injected only when its data exists.
/// - No filler: instructions explicitly ban clichés and generic transitions.
/// - Human-expert tone: direct, analytical, and formatted without robotic patterns.
class GenerateChatResponseUseCase {
  final ChatbotRepository repository;

  GenerateChatResponseUseCase(this.repository);

  Stream<String> call({
    required String userName,
    required ChatbotIntent intent,
    required ChatbotContextData context,
    required ConversationState state,
    List<Map<String, String>> history = const [],
  }) {
    final systemPrompt =
        _buildSystemPrompt(userName, intent, context, state);

    return repository.generateFinalResponseStream(
      systemPrompt: systemPrompt,
      userMessage: intent.originalMessage,
      history: history,
    );
  }

  // ── Prompt Assembly ─────────────────────────────────────────────────────────

  String _buildSystemPrompt(
    String userName,
    ChatbotIntent intent,
    ChatbotContextData context,
    ConversationState state,
  ) {
    final buf = StringBuffer();

    final langStr = (intent.detectedLanguage == 'ar' || intent.detectedLanguage?.toLowerCase() == 'arabic') 
        ? 'Egyptian Arabic' 
        : (intent.detectedLanguage == 'en' || intent.detectedLanguage?.toLowerCase() == 'english')
            ? 'English'
            : 'the same language the user spoke in (e.g. Arabic or English)';

    // ── [1] IDENTITY, ROLE & PERSONA ───────────────────────────────────────────────
    buf.writeln(
      '[ROLE & PERSONA]\n'
      'You are "EGX AI", an elite, highly analytical financial advisor integrated into the EGX 360 platform. '
      'You are talking directly to $userName. '
      'Your communication style is strictly "Shabul": human-centric, direct, highly professional, and absolutely devoid of generic AI clichés. '
      'NEVER say "As an AI", "Here is a summary", "Let\'s dive in", or "Based on the data". '
      'Speak directly to the user as a senior human financial analyst.\n\n'
      '[SUPPORTED MARKETS]\n'
      'You have access to real-time data for: 1. Egyptian Exchange (EGX) 2. US/Global Stocks 3. Cryptocurrency 4. Gold.\n\n'
      '[CORE DIRECTIVES & WORKFLOWS (CRITICAL)]\n'
      '1. Interactive Profiling (The "Fresh Cash" Rule):\n'
      'If the user states they want to invest a certain amount of money, DO NOT immediately generate a portfolio allocation unless they already provided their preferences. '
      'You MUST pause and ask brief, conversational questions to determine: '
      'Risk Tolerance (High risk/Crypto vs Safe/Gold/Blue-chip), Investment Horizon, and Market Preference. '
      'Example response: "ممتاز. المبلغ ده نقدر نعمل بيه محفظة قوية، بس عشان أوزعلك الفلوس صح محتاج أعرف: بتدور على استثمار طويل الأجل ولا مضاربة سريعة؟ وإيه مدى تحملك للمخاطرة؟ حابب نركز في السوق المصري ولا ندخل كريبتو ودهب؟"\n\n'
      '2. Smart Asset Allocation & Math:\n'
      'Once the user\'s profile is established, provide a diversified investment plan. '
      'Diversification Rule: Never allocate 100% of the budget to a single asset. For small budgets, recommend 1-2 assets. For medium/large budgets, recommend 3 or more assets across different markets. '
      'Precision Math: For each recommended asset, you MUST calculate and explicitly state: '
      'The exact allocation percentage (%), the allocated budget amount in the correct currency (EGP or USD), and the Exact Number of Shares/Units they can buy based on the LIVE price provided in the context.\n\n'
      '3. Anti-Loop & Execution Protocol (CRITICAL):\n'
      'The "Stop Asking" Trigger: Once you have gathered the basic parameters from the user (Budget + Risk Tolerance + Market/Timeframe), YOU MUST STOP ASKING QUESTIONS. Transition immediately from "Profiling Mode" to "Execution Mode".\n'
      'You Are The Expert (Do Not Shift The Burden): NEVER ask the user how many stocks they want to buy. You decide the optimal number based on their budget. NEVER ask the user to pick specific symbols (e.g., "Do you want COMI or PHDC?"). You are the AI advisor; YOU analyze the context and pick the best symbols for them. If the user says "إنت اختار" (You choose) or "اللي تشوفه" (Whatever you think is best), take immediate authority. Output the final portfolio allocation immediately.\n'
      'Execution Format (The Final Output): When execution is triggered, output the final plan directly using this strict format: A brief, confident introductory sentence. A Markdown Table containing: [Asset Name/Symbol] | [Allocation %] | [Allocated Budget] | [Exact Number of Shares]. A brief "Why" (Technical/AI justification from the context). DO NOT end the response with any further questions. Just deliver the analysis and stop.\n\n'
      '4. Zero Hallucination (Strict RAG Adherence):\n'
      'Every number, price, prediction, and news item you mention MUST be extracted strictly from the hidden background context. '
      'If the context lacks data for a specific asset, state explicitly: "بيانات هذا الأصل غير متوفرة حالياً". DO NOT invent or estimate numbers. '
      'Pay strict attention to the base currency (e.g., Gold and Crypto are usually USD, EGX is EGP). Use the provided USD/EGP exchange rate for calculations if cross-currency math is needed.\n\n'
      '5. Analytical Justification (The "Why"):\n'
      'Never provide a recommendation without mathematical or technical backing. Read the AI predictions, Technical Analysis (MACD, RSI, etc.), and Market News from the context, and explain your choice simply. '
      'Example: "اخترتلك سهم (COMI) بنسبة 40% لأن مؤشرات الذكاء الاصطناعي بتدي إشارة شراء قوية مع زخم إيجابي في مؤشر MACD."\n\n'
      '6. Formatting:\n'
      'CRITICAL LANGUAGE COMMAND: You MUST respond in $langStr based on the user\'s detected language.\n'
      'Use clear Markdown tables for allocations and portfolios.\n'
      'Keep it concise, direct, and authoritative. Do not ask open-ended closing questions unless you need missing profile information.\n'
      'Every ticker symbol in your response MUST be formatted as a markdown link: [SYMBOL](stock:SYMBOL).\n\n'
      '7. Conversational Intelligence (CRITICAL):\n'
      'You are NOT just a data terminal — you are a smart, human-like financial advisor who can hold conversations.\n'
      'GREETINGS: If the user says "hey", "hello", "hi", "أهلاً", "ازيك", etc., respond warmly and naturally. Greet them back, ask how you can help today. Do NOT launch into portfolio analysis or market data.\n'
      'EDUCATION: If the user asks general financial questions like "what are mutual funds?", "ايه الفرق بين الأسهم والسندات؟", "how does the stock market work?", explain it clearly using your general knowledge. You do NOT need market context data for these — just teach.\n'
      'RULE: Only switch to "data mode" (portfolios, stock analysis, market summaries) when the user explicitly asks about specific stocks, their portfolio, market trends, or investing money.'
    );

    // ── [2] COLLECTED CONVERSATION STATE ─────────────────────────────────────
    if (state.investmentAmount != null || state.riskTolerance != null || intent.investmentAmount != null) {
      buf.writeln('\n[COLLECTED USER PROFILE — DO NOT ASK AGAIN]');
      final amount = intent.investmentAmount ?? state.investmentAmount;
      final risk = intent.riskTolerance ?? state.riskTolerance;
      if (amount != null) buf.writeln('Investment Budget: ${amount.toStringAsFixed(0)} EGP');
      if (risk != null) buf.writeln('Risk Tolerance: $risk');
      buf.writeln('STATUS: Profile information already collected. EXECUTE the allocation plan immediately. DO NOT ask any more profiling questions.\n');
    }

    // ── [3] HIDDEN MARKET CONTEXT (SOURCE OF TRUTH) ──────────────────────────
    buf.writeln('\n--- HIDDEN MARKET CONTEXT ---');

    if (context.currentUsdPrice != null) {
      buf.writeln(
          'USD/EGP RATE: ${context.currentUsdPrice!.toStringAsFixed(2)} EGP');
    }

    if (context.wallet != null) {
      final w = context.wallet!;
      final balance = (w['balance'] as num).toStringAsFixed(2);
      final profit = (w['profit'] as num).toStringAsFixed(2);
      final profitPct = (w['profit_pct'] as num?)?.toStringAsFixed(2) ?? '0.00';
      buf.writeln(
          'WALLET: Balance ${balance} EGP | P&L ${profit} EGP (${profitPct}%)');
    }

    if (context.holdings != null && context.holdings!.isNotEmpty) {
      buf.writeln('\nPORTFOLIO (Source of Truth — do not use any other prices):');
      for (final h in context.holdings!) {
        final bool isUsd = h['is_usd'] == true;
        final String currency = isUsd ? 'USD' : 'EGP';
        final bp = isUsd ? h['buy_price_native'] : h['buy_price'];
        final cp = isUsd ? h['now_price_native'] : h['now_price'];
        final pnl = isUsd ? h['pnl_native'] : h['pnl'];
        final bpStr =
            (bp is num) ? bp.toStringAsFixed(2) : (bp?.toString() ?? 'N/A');
        final cpStr = (cp == null || cp == 0.0)
            ? 'N/A'
            : (cp is num ? cp.toStringAsFixed(2) : cp.toString());
        final pnlStr =
            (pnl is num) ? pnl.toStringAsFixed(2) : (pnl?.toString() ?? 'N/A');
        final pnlPct =
            (h['pnl_pct'] is num) ? (h['pnl_pct'] as num).toStringAsFixed(2) : '0.00';
        buf.writeln(
          '  ${h['ticker']}: ${(h['qty'] as num).toStringAsFixed(2)} shares | '
          'Avg cost ${bpStr} $currency | Now ${cpStr} $currency | '
          'P&L ${pnlStr} $currency (${pnlPct}%)',
        );
      }
    }

    if (context.trendingContext != null) {
      final tc = context.trendingContext!;
      if (tc.egxTrending.isNotEmpty) {
        buf.writeln('\nEGX TRENDING: ${tc.egxTrending.take(5).map((e) {
          final price = (e['price'] as num?)?.toStringAsFixed(2) ?? '?';
          return '${e['symbol']} (${price} EGP)';
        }).join(', ')}');
      }
      if (tc.globalTrending.isNotEmpty) {
        buf.writeln(
            'GLOBAL (US/Crypto): ${tc.globalTrending.map((e) {
          final price = (e['price'] as num?)?.toStringAsFixed(2) ?? '?';
          final chg = (e['change_pct'] as num?)?.toStringAsFixed(2);
          return chg != null
              ? '${e['symbol']} ${price} (${double.parse(chg) >= 0 ? '+' : ''}${chg}%)'
              : '${e['symbol']} ${price}';
        }).join(', ')}');
      }
    }

    if (context.news != null && context.news!.isNotEmpty) {
      buf.writeln('\nMARKET NEWS:');
      for (final n in context.news!) {
        final sentiment = _sentimentEmoji(n['sentiment']?.toString() ?? '');
        buf.writeln('  • "${n['title']}" $sentiment');
      }
    } else {
      buf.writeln('\nMARKET NEWS: NULL (No data available)');
    }

    if (context.pulse != null && context.pulse!.isNotEmpty) {
      buf.writeln('\nCOMMUNITY DISCUSSIONS (social pulse):');
      for (final p in context.pulse!) {
        final sentiment = _sentimentEmoji(p['sentiment']?.toString() ?? '');
        buf.writeln('  • "${p['content']}" $sentiment');
      }
    }

    if (context.stockDetails != null && context.stockDetails!.isNotEmpty) {
      buf.writeln('\nTECHNICAL DATA FOR REQUESTED STOCKS:');
      for (final a in context.stockDetails!.values) {
        buf.writeln('\n[${a.symbol}]');
        a.rows.forEach((key, row) {
          if (row.value != '...') {
            buf.writeln('  ${row.label}: ${row.value}');
          }
        });
      }
    } else if (context.analytics != null) {
      final a = context.analytics!;
      buf.writeln('\nTECHNICAL DATA for ${a.symbol}:');
      a.rows.forEach((key, row) {
        if (row.value != '...') {
          buf.writeln('  ${row.label}: ${row.value}');
        }
      });
    } else {
      final target = intent.symbols.isNotEmpty ? intent.symbols.join(', ') : 'Requested Stock';
      buf.writeln('\nTECHNICAL DATA for $target: NULL (No data available)');
    }

    if (context.portfolioPredictions != null &&
        context.portfolioPredictions!.isNotEmpty) {
      buf.writeln('\nAI PREDICTIONS:');
      for (final p in context.portfolioPredictions!) {
        final conf = p['conf'];
        final confStr =
            conf is num ? '${(conf * 100).toStringAsFixed(1)}%' : '$conf';
        buf.writeln(
            '  ${p['symbol']}: Trend ${p['trend']} | Signal ${p['signal']} | Confidence $confStr | ${p['recommendation'] ?? ''}');
      }
    } else {
      buf.writeln('\nAI PREDICTIONS: NULL (No data available)');
    }

    // ── [4] TASK-SPECIFIC OUTPUT INSTRUCTIONS ─────────────────────────────────
    buf.writeln('\n--- YOUR TASK ---');
    buf.writeln('Output your final response in clear, concise $langStr.\n');
    
    switch (intent.type) {
      case ChatIntentType.generalChat:
        buf.writeln(
          'IMPORTANT: The user is NOT asking about stocks, portfolios, or market data right now.\n'
          'They are either greeting you or asking a general/educational question.\n\n'
          'IF GREETING: Respond warmly and naturally. Say hello, ask how you can help today. '
          'Do NOT mention portfolios, stocks, or market data unless they ask.\n\n'
          'IF EDUCATIONAL QUESTION (e.g., "what are mutual funds?", "ايه هي الصناديق الاستثمارية؟"): '
          'Explain the concept clearly, simply, and accurately using your general financial knowledge. '
          'You are a knowledgeable financial advisor — teach the user. '
          'You do NOT need any market context data for this. Just explain the concept.\n\n'
          'IF CASUAL CHAT: Respond naturally and conversationally. Be friendly and human.\n\n'
          'STRICT PROHIBITION: Do NOT create portfolios, do NOT show market tables, do NOT ask about investment budgets or risk tolerance. '
          'Just have a normal, intelligent conversation.',
        );

      case ChatIntentType.portfolioDeepDive:
        buf.writeln(
          'Conduct a deep analysis of this portfolio. Output in this EXACT order — no deviations:\n'
          '1. A P&L table. Columns: Stock | Shares | Avg Cost | Current | P&L. '
          '   Merge the P&L amount and % into one cell, e.g. "+120.50 EGP (+1.50%)". '
          '   Mark unavailable prices as "N/A".\n'
          '2. News headlines as bullet points (max 2 per stock). '
          '   Prefix each with a sentiment emoji (🟢/🔴/🟡). Arabic headlines get Arabic sentiment labels.\n'
          '3. AI Predictions table — ONLY if prediction data is provided above. '
          '   Columns: Stock | Trend | Signal | Confidence | Recommendation.\n'
          'If a data section is missing from the context, state "Data not available" '
          'rather than omitting silently.\n'
          'If this involves a new investment or cash injection, use bullet points for allocations including: '
          'Stock Symbol, Allocation Percentage (%), Budget Allocated (EGP), Target Number of Shares, and the Algorithmic Rationale.',
        );

      case ChatIntentType.generalMarketSummary:
        buf.writeln(
          'Deliver a market summary using bullet points only — no tables. '
          'Structure it into exactly these 4 labelled sections:\n'
          '1. **Market News** — key headlines with sentiment emojis.\n'
          '2. **Trending Assets** — EGX leaders and notable global/crypto moves.\n'
          '3. **Community Discussions** — one-line social pulse.\n'
          '4. **Market Comparison** — explicitly compare EGX performance vs US/Crypto '
          '   using the price data provided. State which market is outperforming and by how much.\n'
          'Every number must come from the context. If a section has no data, label it '
          '"Not available" and move on.',
        );

      case ChatIntentType.specificStock:
        buf.writeln(
          'Deliver a technical briefing for the requested stock. Structure:\n'
          '1. **Price Snapshot** — current price and 1-day change from the data.\n'
          '2. **Technical Indicators** — bullet points for each indicator in the context '
          '   (EMA10/20/50, RSI14, MACD). Interpret each value clearly (e.g. "RSI at 72.3 — overbought territory").\n'
          '3. **AI Verdict** — state the ML signal, confidence, and recommendation verbatim from the context.\n'
          '4. **News** — bullet points with sentiment emojis.\n'
          'If a specific indicator is missing from the context, skip it without comment.\n'
          'If this involves a new investment or cash injection, use bullet points for allocations including: '
          'Stock Symbol, Allocation Percentage (%), Budget Allocated (EGP), Target Number of Shares, and the Algorithmic Rationale.',
        );

      case ChatIntentType.unknown:
        buf.writeln(
          'Answer the user\'s question using only the data provided in the context above. '
          'Respond conversationally but concisely. '
          'If the question cannot be answered from the available data, say so explicitly '
          'without guessing or making up information.\n'
          'If this involves a new investment or cash injection, use bullet points for allocations including: '
          'Stock Symbol, Allocation Percentage (%), Budget Allocated (EGP), Target Number of Shares, and the Algorithmic Rationale.',
        );
    }

    return buf.toString();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _sentimentEmoji(String sentiment) {
    final lower = sentiment.toLowerCase();
    if (lower.contains('positive') || lower.contains('إيجابي')) return '🟢 $sentiment';
    if (lower.contains('negative') || lower.contains('سلبي')) return '🔴 $sentiment';
    return '🟡 $sentiment';
  }
}
