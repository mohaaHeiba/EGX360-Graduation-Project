import 'package:egx/features/profile/presentations/widgets/create_post_widgets/build_sentiment_chip.dart';
import 'package:flutter/material.dart';

Widget buildBottomToolbar(
  BuildContext context,
  ColorScheme colorScheme,
  final controller,
) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
      border: Border(
        top: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 10,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    padding: EdgeInsets.only(
      left: 20,
      right: 20,
      top: 12,
      bottom: MediaQuery.of(context).viewPadding.bottom + 12,
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildToolbarButton(
            context,
            icon: Icons.image_rounded,
            label: "Photo",
            color: colorScheme.primary,
            onTap: () => controller.pickImage(),
          ),
          const SizedBox(width: 12),
          _buildToolbarButton(
            context,
            icon: Icons.attach_money_rounded,
            label: "Stock",
            color: Colors.green,
            onTap: () => controller.addStockSymbol(),
          ),

          Container(
            height: 24,
            width: 1,
            color: colorScheme.outline.withOpacity(0.2),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),

          buildSentimentChip(
            context,
            "Bullish",
            "bullish",
            Icons.trending_up_rounded,
            Colors.green,
            controller,
          ),
          const SizedBox(width: 12),
          buildSentimentChip(
            context,
            "Bearish",
            "bearish",
            Icons.trending_down_rounded,
            Colors.red,
            controller,
          ),
        ],
      ),
    ),
  );
}

Widget _buildToolbarButton(
  BuildContext context, {
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );
}
