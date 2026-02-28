import 'package:egx/generated/l10n.dart';
import 'package:flutter/material.dart';

class MarketStatusHelper {
  static bool isMarketOpen({String symbol = 'EGX', bool isCrypto = false}) {
    if (isCrypto) return true; // Crypto is always open

    final now = DateTime.now();

    if (symbol == 'GOLD') {
      // Gold Market (Global Spot)
      // Closed on weekends (Saturday and Sunday)
      if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
        return false;
      }
      // Open 24h on weekdays
      return true;
    }

    // EGX Weekend: Friday (5) and Saturday (6)
    if (now.weekday == DateTime.friday || now.weekday == DateTime.saturday) {
      return false;
    }

    // EGX Hours: 10:00 AM to 2:30 PM (14:30)
    final startTime = DateTime(now.year, now.month, now.day, 10, 0);
    final endTime = DateTime(now.year, now.month, now.day, 14, 30);

    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  static String getMarketStatusText({
    required BuildContext context,
    String symbol = 'EGX',
    bool isCrypto = false,
  }) {
    return isMarketOpen(symbol: symbol, isCrypto: isCrypto)
        ? S.of(context).market_status_open
        : S.of(context).market_status_closed;
  }

  static Color getMarketStatusColor({
    String symbol = 'EGX',
    bool isCrypto = false,
  }) {
    return isMarketOpen(symbol: symbol, isCrypto: isCrypto)
        ? Colors.greenAccent
        : Colors.orangeAccent;
  }
}
