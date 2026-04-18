import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/home/domain/entities/market_history_entity.dart';
import 'package:flutter/material.dart';

class MarketIntelligenceCard extends StatelessWidget {
  final MarketHistoryEntity? marketHistory;

  const MarketIntelligenceCard({super.key, this.marketHistory});

  @override
  Widget build(BuildContext context) {
    final isMarketOpen = _checkMarketStatus(DateTime.now());
    final s = context.s;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.surface.withOpacity(0.6),
            context.surface.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.onSurface.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: context.surface.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row - NO ICON
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.market_status_title,
                style: TextStyle(
                  color: context.onSurface.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _buildStatusPill(isMarketOpen, context),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  s.value_traded_label,
                  marketHistory?.valueTraded ?? s.not_available,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: context.onSurface.withOpacity(0.08),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  s.market_cap_label,
                  marketHistory?.marketCap ?? s.not_available,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(bool isOpen, BuildContext context) {
    final color = isOpen ? AppColors.candleGreen : AppColors.candleRed;
    final s = context.s;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isOpen ? s.market_live : s.market_closed,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.onSurface.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: context.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  bool _checkMarketStatus(DateTime ignored) {
    final now = DateTime.now().toUtc().add(const Duration(hours: 2));
    final isWeekend =
        now.weekday == DateTime.friday || now.weekday == DateTime.saturday;
    if (isWeekend) return false;

    final hour = now.hour;
    final minute = now.minute;

    final isAfterStart = hour >= 10;
    final isBeforeEnd = hour < 14 || (hour == 14 && minute <= 30);

    return isAfterStart && isBeforeEnd;
  }
}
