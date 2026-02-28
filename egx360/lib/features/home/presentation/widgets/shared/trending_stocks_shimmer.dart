import 'package:egx/core/helper/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TrendingStocksShimmer extends StatelessWidget {
  const TrendingStocksShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.8,
      ),
      itemCount: 8, // Show 8 shimmer items
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: context.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: context.onSurface.withOpacity(0.12),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Chart Placeholder
              Positioned(
                bottom: 20,
                left: 0,
                right: 10,
                height: 45,
                child: _buildShimmerBox(context, height: 45, radius: 0),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo & Symbol
                    Row(
                      children: [
                        _buildShimmerBox(
                          context,
                          width: 18,
                          height: 18,
                          radius: 9,
                        ),
                        const SizedBox(width: 6),
                        _buildShimmerBox(context, width: 60, height: 12),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Price
                    _buildShimmerBox(context, width: 80, height: 16),
                    const SizedBox(height: 8),
                    // Change
                    _buildShimmerBox(context, width: 50, height: 11),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerBox(
    BuildContext context, {
    double? width,
    double? height,
    double radius = 4,
  }) {
    return Shimmer.fromColors(
      baseColor: context.surface.withOpacity(0.3),
      highlightColor: context.surface.withOpacity(0.5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
