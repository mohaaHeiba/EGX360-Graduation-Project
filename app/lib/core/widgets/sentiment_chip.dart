import 'package:egx/core/helper/context_extensions.dart';
import 'package:flutter/material.dart';

class SentimentChip extends StatelessWidget {
  final String label;
  final double fontSize;

  const SentimentChip({
    super.key,
    required this.label,
    this.fontSize = 8,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (label.toLowerCase()) {
      case 'positive':
        color = Colors.green;
        icon = Icons.trending_up;
        break;
      case 'negative':
        color = Colors.red;
        icon = Icons.trending_down;
        break;
      case 'neutral':
      default:
        color = Colors.blueGrey;
        icon = Icons.trending_flat;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2, color: color),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: context.textStyles.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
