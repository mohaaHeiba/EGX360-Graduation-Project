import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AssetDetailsTooltip extends StatelessWidget {
  final bool visible;
  final double x;
  final double price;
  final double change;
  final double percentage;
  final DateTime date;
  final double maxWidth;

  const AssetDetailsTooltip({
    super.key,
    required this.visible,
    required this.x,
    required this.price,
    required this.change,
    required this.percentage,
    required this.date,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final isPositiveChange = change >= 0;
    final color = isPositiveChange ? Colors.green : Colors.red;
    final sign = isPositiveChange ? '+' : '';

    double left = x - 75;
    if (left < 0) left = 0;
    if (left > maxWidth - 160) {
      left = maxWidth - 160;
    }

    return Positioned(
      top: 0,
      left: left,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  price.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$sign${change.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '$sign${percentage.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, HH:mm').format(date.toLocal()),
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
