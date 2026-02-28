import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildSentimentChip(
  BuildContext context,
  String label,
  String value,
  IconData icon,
  Color color,
  final controller,
) {
  return Obx(() {
    final bool isSelected = controller.selectedSentiment.value == value;
    return InkWell(
      onTap: () => controller.setSentiment(value),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(Icons.check, size: 14, color: color),
            ],
          ],
        ),
      ),
    );
  });
}
