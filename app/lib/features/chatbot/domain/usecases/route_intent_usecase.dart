import 'package:egx/features/chatbot/domain/entities/chatbot_intent.dart';
import 'package:egx/features/chatbot/domain/entities/conversation_state.dart';
import 'package:egx/features/chatbot/domain/repositories/chatbot_repository.dart';

class RouteIntentUseCase {
  final ChatbotRepository repository;

  RouteIntentUseCase(this.repository);

  Future<ChatbotIntent> call(
    String message, 
    List<Map<String, dynamic>> assets,
    ConversationState state,
  ) async {
    final normalized = message.toLowerCase().trim();
    final detectedSymbols = _extractSymbols(normalized, assets);

    try {
      final jsonResponse = await repository.detectIntentWithAi(message, assets);
      
      ChatIntentType intentType = jsonResponse['intent'] as ChatIntentType;
      List<String> symbols = [];
      if (jsonResponse['symbols'] != null) {
        symbols = List<String>.from(jsonResponse['symbols']);
      }
      
      // Merge detected symbols from our local list with AI symbols
      final mergedSymbols = {...detectedSymbols, ...symbols}.toList();

      // CRITICAL: Resolve any Arabic/English names back to ticker symbols.
      // The AI sometimes returns "فوري" instead of "FWRY".
      final finalSymbols = _resolveSymbols(mergedSymbols, assets);

      double? amount;
      if (jsonResponse['investment_amount'] != null) {
        amount = double.tryParse(jsonResponse['investment_amount'].toString());
      }
      String? risk = jsonResponse['risk_tolerance'];
      String? lang = jsonResponse['detected_language']?.toString();

      if (amount != null) state.investmentAmount = amount;
      if (risk != null) state.riskTolerance = risk;

      // State is no longer reset by intents since onboarding is removed.

      return ChatbotIntent(
        type: intentType,
        symbols: finalSymbols,
        investmentAmount: amount,
        riskTolerance: risk,
        detectedLanguage: lang,
        originalMessage: message,
      );
    } catch (_) {
      // Fallback
      return ChatbotIntent(
        type: ChatIntentType.generalMarketSummary,
        symbols: detectedSymbols,
        detectedLanguage: _detectLanguageFallback(message),
        originalMessage: message,
      );
    }
  }

  /// Resolves any non-ticker symbols (Arabic names, English names, partial matches)
  /// back to their official ticker symbol using the assets list.
  List<String> _resolveSymbols(List<String> rawSymbols, List<Map<String, dynamic>> assets) {
    final resolved = <String>{};

    print('🧠 [Resolve] Resolving ${rawSymbols.length} symbols against ${assets.length} assets: $rawSymbols');

    for (final raw in rawSymbols) {
      // First, check if it's already a valid ticker
      final isKnownTicker = assets.any(
        (a) => (a['symbol']?.toString() ?? '').toUpperCase() == raw.toUpperCase(),
      );
      if (isKnownTicker) {
        resolved.add(raw.toUpperCase());
        print('🧠 [Resolve] "$raw" → already a valid ticker');
        continue;
      }

      // Not a known ticker — try to match it as an Arabic or English name
      final rawLower = raw.toLowerCase();
      bool found = false;
      for (final asset in assets) {
        final nameAr = asset['company_name_ar']?.toString() ?? '';
        final nameEn = (asset['company_name_en']?.toString() ?? '').toLowerCase();
        final ticker = asset['symbol']?.toString() ?? '';

        // Match: raw text IS the Arabic name, or Arabic name contains the raw text, 
        // or raw text contains the Arabic name
        if ((nameAr.isNotEmpty && (nameAr.contains(raw) || raw.contains(nameAr))) ||
            (nameEn.isNotEmpty && (nameEn.contains(rawLower) || rawLower.contains(nameEn)))) {
          resolved.add(ticker.toUpperCase());
          found = true;
          print('🧠 [Resolve] "$raw" → matched asset "$nameAr" / "$nameEn" → ticker: $ticker');
          break;
        }
      }

      // If still not found, keep the raw value (might be a global stock like AAPL)
      if (!found) {
        resolved.add(raw);
        print('⚠️ [Resolve] "$raw" → NO MATCH found in ${assets.length} assets! Keeping raw.');
      }
    }

    print('🧠 [Resolve] Final result: $rawSymbols → ${resolved.toList()}');
    return resolved.toList();
  }

  List<String> _extractSymbols(String text, List<Map<String, dynamic>> assets) {
    final results = <String>{};
    final words = text.split(RegExp(r'\s+'));

    for (final asset in assets) {
      final symbol = (asset['symbol']?.toString() ?? '').toLowerCase();
      final nameEn = (asset['company_name_en']?.toString() ?? '').toLowerCase();
      final nameAr = (asset['company_name_ar']?.toString() ?? '');

      if (words.contains(symbol) || 
          (nameEn.isNotEmpty && text.contains(nameEn)) || 
          (nameAr.isNotEmpty && text.contains(nameAr)) ||
          // Also check if any Arabic word from the user matches inside the asset's Arabic name
          (nameAr.isNotEmpty && words.any((w) => w.length > 2 && nameAr.contains(w)))) {
        results.add(asset['symbol'].toString());
      }
    }
    return results.toList();
  }

  String _detectLanguageFallback(String text) {
    final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    return hasArabic ? 'ar' : 'en';
  }
}
