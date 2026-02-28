import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/home/data/models/stock_model.dart';
import 'package:egx/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class WatchlistCard extends StatefulWidget {
  final StockModel stock;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final double usdRate;

  const WatchlistCard({
    super.key,
    required this.stock,
    required this.onDelete,
    required this.onTap,
    this.usdRate = 1.0,
  });

  @override
  State<WatchlistCard> createState() => _WatchlistCardState();
}

class _WatchlistCardState extends State<WatchlistCard>
    with SingleTickerProviderStateMixin {
  late final SlidableController _slidableController;
  bool _vibrated = false; // لمنع تكرار الاهتزاز أثناء نفس السحبة

  @override
  void initState() {
    super.initState();
    // إنشاء كنترولر خاص بالسلايدر
    _slidableController = SlidableController(this);

    // إضافة مستمع لحركة السحب
    _slidableController.animation.addListener(() {
      final double value = _slidableController.animation.value;

      // إذا تحرك السلايدر بنسبة 15% ولم يهتز بعد
      if (value > 0.15 && !_vibrated) {
        HapticFeedback.lightImpact(); // اهتزاز خفيف جداً واحترافي
        _vibrated = true;
      }
      // إذا عاد السلايدر لنقطة الصفر، نصفر المتغير للسحبة القادمة
      else if (value == 0) {
        _vibrated = false;
      }
    });
  }

  @override
  void dispose() {
    // ✅ لازم تقفل الكنترولر هنا
    _slidableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... (باقي الحسابات الخاصة بـ price و trendColor كما هي في كودك) ...
    final double changePercent = widget.stock.changePercent ?? 0.0;
    final bool isPositive = changePercent >= 0;
    final Color trendColor = isPositive
        ? AppColors.candleGreen
        : AppColors.candleRed;
    final bool isForeign =
        widget.stock.sector == 'Crypto' || widget.stock.symbol == 'GOLD';
    final double rate = isForeign ? widget.usdRate : 1.0;
    final double price = (widget.stock.currentPrice ?? 0.0) * rate;

    return Slidable(
      key: Key(widget.stock.symbol),
      controller: _slidableController, // ربط الكنترولر هنا
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        dismissible: DismissiblePane(
          onDismissed: () {
            // اهتزاز أقوى قليلاً عند الحذف النهائي
            HapticFeedback.mediumImpact();
            widget.onDelete();
          },
        ),
        children: [
          SlidableAction(
            onPressed: (context) {
              HapticFeedback.mediumImpact();
              widget.onDelete();
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: context.s.delete_action,
          ),
        ],
      ),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          // ... نفس تصميم الـ Container الخاص بك (استبدل stock بـ widget.stock) ...
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: Border.all(
                color: context.onSurface.withOpacity(0.1),
              ).bottom,
            ),
          ),
          child: Row(
            children: [
              _buildLogo(context),
              const SizedBox(width: 14),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.stock.symbol,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      widget.stock.companyNameEn ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.onSurface.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // الشارت الصغير
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 30,
                  child: CustomPaint(
                    painter: MiniSparklinePainter(
                      data:
                          widget.stock.sparklineData ??
                          [10, 12, 11, 14, 13, 15],
                      color: trendColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // السعر
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${price >= 1000 ? price.toStringAsFixed(0) : price.toStringAsFixed(2)} EGP',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: context.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: trendColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: context.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: widget.stock.logoUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(widget.stock.logoUrl!, fit: BoxFit.cover),
            )
          : Center(
              child: Text(
                widget.stock.symbol[0],
                style: TextStyle(
                  color: context.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}

// رسام الشارت الصغير (Mini Sparkline)
class MiniSparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  MiniSparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path();
    final double stepX = size.width / (data.length - 1);
    final double min = data.reduce((a, b) => a < b ? a : b);
    final double max = data.reduce((a, b) => a > b ? a : b);
    final double range = max - min;

    path.moveTo(
      0,
      size.height - ((data[0] - min) / (range == 0 ? 1 : range) * size.height),
    );
    for (int i = 1; i < data.length; i++) {
      path.lineTo(
        i * stepX,
        size.height -
            ((data[i] - min) / (range == 0 ? 1 : range) * size.height),
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class WatchlistSection extends StatelessWidget {
  final List<StockModel> watchlist;
  final int? limit;
  final VoidCallback? onSeeAll;

  const WatchlistSection({
    super.key,
    required this.watchlist,
    this.limit,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final displayList = limit != null
        ? watchlist.take(limit!).toList()
        : watchlist;

    return Obx(() {
      final usdRate =
          controller.currencyPrices['USD'] ?? 50.0; // Default fallback
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (watchlist.isEmpty)
            const SizedBox.shrink()
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: onSeeAll,
                    child: Row(
                      children: [
                        Icon(
                          Icons.bookmark_rounded,
                          color: context.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.s.your_watchlist_title,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: context.onSurface.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                  if (onSeeAll != null && watchlist.length > (limit ?? 0))
                    TextButton(
                      onPressed: onSeeAll,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        context.s.see_all_btn,
                        style: TextStyle(
                          color: context.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          // القائمة الرأسية (لا تستخدم SizedBox هنا لترك المساحة مفتوحة)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              final stock = displayList[index];
              return WatchlistCard(
                key: Key(stock.symbol),
                stock: stock,
                usdRate: usdRate,
                onTap: () {
                  controller.openStockDetails(stock);
                },
                onDelete: () {
                  controller.removeFromWatchlist(stock.symbol);
                },
              );
            },
          ),
        ],
      );
    });
  }
}
