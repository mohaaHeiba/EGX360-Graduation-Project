import 'package:flutter/material.dart';

/// Widget to display a trade button (Buy/Sell)
class TradeButtonWidget extends StatelessWidget {
  final String label;
  final double price;
  final Color color;
  final VoidCallback onPressed;

  const TradeButtonWidget({
    super.key,
    required this.label,
    required this.price,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Text(
              price.toStringAsFixed(3),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(label, style: TextStyle(color: color, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
