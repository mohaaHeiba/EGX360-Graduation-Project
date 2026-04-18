import 'package:egx/core/helper/context_extensions.dart'; // تأكد إن المسار ده صح
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPostCard extends StatelessWidget {
  const ShimmerPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context;

    final baseColor = theme.isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = theme.isDark ? Colors.grey[700]! : Colors.grey[100]!;

    Widget shimmerBox({double? width, double? height, double radius = 4}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.surface.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================
            // Header (Avatar + Name)
            // ============================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  shimmerBox(width: 40, height: 40, radius: 12),
                  const SizedBox(width: 12),
                  // Name and Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        shimmerBox(width: 120, height: 14),
                        const SizedBox(height: 6),
                        shimmerBox(width: 80, height: 10),
                      ],
                    ),
                  ),
                  // Tag Placeholder
                  shimmerBox(width: 60, height: 24, radius: 6),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ============================
            // Image Placeholder
            // ============================
            // استبدلنا الكونتينر بـ shimmerBox عشان ياخد التأثير
            shimmerBox(width: double.infinity, height: 225, radius: 0),

            // ============================
            // Content Text
            // ============================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  shimmerBox(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  shimmerBox(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  shimmerBox(width: 200, height: 14),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: Colors.white), // لون Divider جوه الشيمر
            ),

            // ============================
            // Footer (Actions)
            // ============================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  // Like Button Placeholder
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        shimmerBox(width: 22, height: 22, radius: 4),
                        const SizedBox(width: 8),
                        shimmerBox(width: 30, height: 12),
                      ],
                    ),
                  ),
                  // Comment Button Placeholder
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        shimmerBox(width: 22, height: 22, radius: 4),
                        const SizedBox(width: 8),
                        shimmerBox(width: 30, height: 12),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Bookmark Icon
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: shimmerBox(width: 20, height: 20, radius: 4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
