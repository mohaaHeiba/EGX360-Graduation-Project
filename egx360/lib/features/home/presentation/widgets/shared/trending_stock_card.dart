import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/home/data/models/stock_model.dart';
import 'package:egx/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TrendingStockCard extends StatefulWidget {
  final StockModel stock;
  final double? usdRate;

  const TrendingStockCard({super.key, required this.stock, this.usdRate});

  @override
  State<TrendingStockCard> createState() => _TrendingStockCardState();
}

class _TrendingStockCardState extends State<TrendingStockCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isGoldOrSilver =
        widget.stock.symbol == 'GOLD' || widget.stock.symbol == 'SILVER';
    double displayPrice = widget.stock.currentPrice ?? 0;

    // Convert to EGP if Gold/Silver and usdRate is available
    if (isGoldOrSilver && widget.usdRate != null) {
      displayPrice = displayPrice * widget.usdRate!;
    }

    final double changePercent = widget.stock.changePercent ?? 0.0;
    final bool isPositive = changePercent >= 0;
    final Color trendColor = isPositive
        ? AppColors.candleGreen
        : AppColors.candleRed;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () => Get.find<HomeController>().openStockDetails(widget.stock),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(_isPressed ? 0.96 : 1.0),
        width: 200,
        decoration: BoxDecoration(
          color: context.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: context.onSurface.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // 1. الشارت في   الخلفية بالأسفل
              Positioned(
                bottom: 20,
                left: 0,
                right: 10,
                height: 45,
                child: CustomPaint(
                  painter: TradingViewPainter(
                    isPositive: isPositive,
                    data:
                        widget.stock.sparklineData ??
                        [10, 12, 11, 15, 14, 18, 17, 20],
                  ),
                ),
              ),
              // 2. المحتوى النصي
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildLogo(trendColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.stock.symbol,
                            maxLines: 1,
                            style: TextStyle(
                              color: context.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.minimize,
                          color: context.onSurface.withOpacity(0.3),
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          NumberFormat.currency(
                            symbol: '',
                            decimalDigits: 2,
                          ).format(displayPrice),
                          style: TextStyle(
                            color: context.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "EGP",
                          style: TextStyle(
                            color: context.onSurface.withOpacity(0.4),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Text(
                          "${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%",
                          style: TextStyle(
                            color: trendColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.s.today,
                          style: TextStyle(
                            color: context.onSurface.withOpacity(0.3),
                            fontSize: 9,
                          ),
                        ),
                      ],
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

  Widget _buildLogo(Color color) {
    return Container(
      width: 18, // تصغير اللوجوzzz
      height: 18,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: widget.stock.logoUrl?.isNotEmpty == true
            ? ClipOval(
                child: Image.network(widget.stock.logoUrl!, fit: BoxFit.cover),
              )
            : Text(
                widget.stock.symbol.substring(0, 1),
                style: TextStyle(
                  color: color,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class TradingViewPainter extends CustomPainter {
  final bool isPositive;
  final List<double> data;

  TradingViewPainter({required this.isPositive, required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final trendColor = isPositive ? AppColors.candleGreen : AppColors.candleRed;
    final paint = Paint()
      ..color = trendColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double stepX = size.width / (data.length - 1);
    final double min = data.reduce((a, b) => a < b ? a : b);
    final double max = data.reduce((a, b) => a > b ? a : b);
    final double range = max - min;

    double getY(double val) {
      double normalized = (val - min) / (range == 0 ? 1 : range);
      return size.height -
          (normalized * (size.height * 0.5)) -
          (size.height * 0.2);
    }

    path.moveTo(0, getY(data[0]));
    for (int i = 0; i < data.length - 1; i++) {
      var x1 = i * stepX;
      var y1 = getY(data[i]);
      var x2 = (i + 1) * stepX;
      var y2 = getY(data[i + 1]);
      path.quadraticBezierTo(
        x1 + (x2 - x1) / 2,
        y1,
        (x1 + x2) / 2,
        (y1 + y2) / 2,
      );
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [trendColor.withOpacity(0.25), trendColor.withOpacity(0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // النقطة المتوهجة في النهاية
    final lastX = size.width;
    final lastY = getY(data.last);
    canvas.drawCircle(
      Offset(lastX, lastY),
      4,
      Paint()..color = trendColor.withOpacity(0.2),
    );
    canvas.drawCircle(Offset(lastX, lastY), 2, Paint()..color = trendColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
