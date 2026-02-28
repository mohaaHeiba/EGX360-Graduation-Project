import 'package:egx/core/helper/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeShimmerLoadingDesktop extends StatelessWidget {
  const HomeShimmerLoadingDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.surface.withOpacity(0.3),
      highlightColor: context.surface.withOpacity(0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Panel (65%)
          Expanded(
            flex: 65,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBox(context, width: 100, height: 16),
                          const SizedBox(height: 8),
                          _buildBox(context, width: 150, height: 32),
                        ],
                      ),
                      const Spacer(),
                      _buildBox(context, width: 40, height: 40, radius: 10),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Quick Indicators (Horizontal)
                  Row(
                    children: List.generate(
                      3,
                      (index) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildBox(context, height: 80, radius: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Watchlist Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBox(context, width: 120, height: 24),
                      _buildBox(context, width: 60, height: 20),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Watchlist Items
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _buildWatchlistItem(context),
                  ),

                  const SizedBox(height: 24),

                  // Trending Stocks Header
                  _buildBox(context, width: 140, height: 24),
                  const SizedBox(height: 12),

                  // Trending Stocks Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.55,
                        ),
                    itemCount: 4,
                    itemBuilder: (context, index) =>
                        _buildBox(context, radius: 10),
                  ),
                ],
              ),
            ),
          ),

          // Divider
          VerticalDivider(width: 1, color: context.onSurface.withOpacity(0.1)),

          // Right Panel (35%)
          Expanded(
            flex: 35,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Market Status Card
                  _buildBox(context, height: 180, radius: 12),
                  const SizedBox(height: 24),

                  // Indices
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [_buildBox(context, width: 120, height: 24)],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBox(context, height: 120, radius: 12),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildBox(context, height: 120, radius: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Latest News
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBox(context, width: 100, height: 24),
                      _buildBox(context, width: 50, height: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildBox(context, height: 100, radius: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistItem(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildBox(context, width: 40, height: 40, radius: 8),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBox(context, width: 60, height: 14),
              const SizedBox(height: 6),
              _buildBox(context, width: 100, height: 10),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBox(context, width: 50, height: 14),
              const SizedBox(height: 6),
              _buildBox(context, width: 40, height: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBox(
    BuildContext context, {
    double? width,
    double? height,
    double radius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
