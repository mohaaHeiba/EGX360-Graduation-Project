import 'package:egx/features/stock_chat/presentation/pages/stock_chat_page.dart';
import 'package:flutter/material.dart';

class AssetLiveChatTab extends StatelessWidget {
  final Map<String, dynamic> stockData;

  const AssetLiveChatTab({super.key, required this.stockData});

  @override
  Widget build(BuildContext context) {
    final stockId = stockData['id'].toString();
    return StockChatPage(
      stockId: stockId,
      symbol: stockData['stock_name'] ?? '',
    );
  }
}
