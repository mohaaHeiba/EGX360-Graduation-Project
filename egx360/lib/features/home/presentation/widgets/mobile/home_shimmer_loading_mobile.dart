import 'package:egx/core/helper/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeShimmerLoadingMobile extends StatelessWidget {
  const HomeShimmerLoadingMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Market Intelligence Card
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildBox(context, height: 180, radius: 16),
          ),

          // Quick Indicators
          SizedBox(
            height: 90,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _buildBox(context, width: 100, height: 90, radius: 12),
            ),
          ),
          const SizedBox(height: 24),

          // Watchlist Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBox(context, width: 100, height: 20),
                _buildBox(context, width: 60, height: 16),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Watchlist Items
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildWatchlistItem(context),
          ),

          const SizedBox(height: 24),

          // Trending Stocks Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildBox(context, width: 140, height: 24),
                const SizedBox(width: 8),
                _buildBox(context, width: 16, height: 16),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Trending Stocks Horizontal List
          SizedBox(
            height: 160,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) =>
                  _buildBox(context, width: 140, height: 160, radius: 12),
            ),
          ),

          const SizedBox(height: 24),

          // Market Overview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBox(context, width: 150, height: 24),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) =>
                      _buildBox(context, radius: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWatchlistItem(BuildContext context) {
    return Row(
      children: [
        _buildBox(context, width: 40, height: 40, radius: 8),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBox(context, width: 100, height: 14),
              const SizedBox(height: 6),
              _buildBox(context, width: 60, height: 10),
            ],
          ),
        ),
        _buildBox(context, width: 60, height: 20, radius: 4),
      ],
    );
  }

  Widget _buildBox(
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
