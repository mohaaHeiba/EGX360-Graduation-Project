import 'package:egx/core/helper/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class WatchlistShimmer extends StatelessWidget {
  const WatchlistShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Shimmer
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Row(
            children: [
              _buildShimmerBox(context, width: 20, height: 20, radius: 4),
              const SizedBox(width: 8),
              _buildShimmerBox(context, width: 120, height: 24, radius: 4),
            ],
          ),
        ),
        // List Shimmer
        Expanded(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: context.onSurface.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Logo
                    _buildShimmerBox(
                      context,
                      width: 42,
                      height: 42,
                      radius: 10,
                    ),
                    const SizedBox(width: 14),
                    // Symbol & Name
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerBox(context, width: 60, height: 16),
                          const SizedBox(height: 8),
                          _buildShimmerBox(context, width: 100, height: 12),
                        ],
                      ),
                    ),
                    // Mini Chart
                    Expanded(
                      flex: 2,
                      child: _buildShimmerBox(context, height: 30),
                    ),
                    const SizedBox(width: 12),
                    // Price & Change
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildShimmerBox(context, width: 80, height: 18),
                          const SizedBox(height: 4),
                          _buildShimmerBox(context, width: 50, height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerBox(
    BuildContext context, {
    double? width,
    double? height,
    double radius = 8,
  }) {
    return Shimmer.fromColors(
      baseColor: context.surface.withOpacity(0.3),
      highlightColor: context.surface.withOpacity(0.5),
      child: Container(
        width: width,
        height: height ?? 20,
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
