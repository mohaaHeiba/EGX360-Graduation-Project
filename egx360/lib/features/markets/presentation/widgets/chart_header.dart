import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/markets/presentation/controllers/markets_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:egx/core/utils/price_formatter.dart';

class ChartHeader extends StatelessWidget {
  final double price;
  final double change;
  final double percent;
  final Color color;
  final Color gridColor;
  final String selectedTimeframe;
  final List<String> timeframes;
  final Function(String) onTimeframeSelected;
  final MarketsController controller;
  final VoidCallback? onToggleSidebar;
  final VoidCallback? onShowDetails;
  final bool enableSearch;

  const ChartHeader({
    super.key,
    required this.price,
    required this.change,
    required this.percent,
    required this.color,
    required this.gridColor,
    required this.selectedTimeframe,
    required this.timeframes,
    required this.onTimeframeSelected,
    required this.controller,
    this.onToggleSidebar,
    this.onShowDetails,
    this.enableSearch = true,
  });

  void _showStockSelector(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => _StockSelectorDialog(
        controller: controller,
        enableSearch: enableSearch,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: gridColor, width: 0.5)),
        color: context.background,
      ),
      child: Row(
        children: [
          // Stock selector button
          Expanded(
            child: GestureDetector(
              onTap: enableSearch ? () => _showStockSelector(context) : null,
              child: Obx(() {
                final stock = controller.selectedStock.value;
                return Row(
                  children: [
                    // Logo
                    if (stock?.logoUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            stock!.logoUrl!,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: context.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                LucideIcons.coins,
                                color: context.primary,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Symbol & Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                stock?.symbol ?? context.s.chart_header_select,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: context.onSurface,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                LucideIcons.chevronDown,
                                size: 16,
                                color: context.onSurface.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                          Text(
                            context.isArabic
                                ? (stock?.companyNameAr ??
                                      stock?.companyNameEn ??
                                      '')
                                : (stock?.companyNameEn ?? ''),
                            style: TextStyle(
                              fontSize: 12,
                              color: context.onSurface.withValues(alpha: 0.5),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          // Price Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                PriceFormatter.formatPrice(price),
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    "${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(2)}%",
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (onShowDetails != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: const Icon(LucideIcons.info),
                onPressed: onShowDetails,
                tooltip: 'Show Details',
                color: context.onSurface.withValues(alpha: 0.6),
              ),
            ),
          if (onToggleSidebar != null)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: IconButton(
                icon: const Icon(LucideIcons.panelRight),
                onPressed: onToggleSidebar,
                tooltip: context.s.chart_header_toggle_watchlist,
                color: context.onSurface.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );
  }
}

// Separate stateful widget for the dialog
class _StockSelectorDialog extends StatefulWidget {
  final MarketsController controller;
  final bool enableSearch;

  const _StockSelectorDialog({
    required this.controller,
    required this.enableSearch,
  });

  @override
  State<_StockSelectorDialog> createState() => _StockSelectorDialogState();
}

class _StockSelectorDialogState extends State<_StockSelectorDialog> {
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      constraints: BoxConstraints(
        maxHeight: 350.h.clamp(300, 400),
        maxWidth: 300.w.clamp(250, 350),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with search toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: context.onSurface.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.coins, color: context.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  context.s.chart_header_select_crypto,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.onSurface,
                  ),
                ),
                const Spacer(),
                // Search toggle button (only if enabled)
                if (widget.enableSearch)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          widget.controller.searchController.clear();
                          widget.controller.searchResults.clear();
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _isSearching
                            ? context.primary.withValues(alpha: 0.1)
                            : context.onSurface.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.search,
                        color: _isSearching
                            ? context.primary
                            : context.onSurface.withValues(alpha: 0.5),
                        size: 18,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: context.onSurface.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          // Search field (only visible when searching)
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: widget.controller.searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: context.s.chart_header_search_hint,
                  hintStyle: TextStyle(
                    color: context.onSurface.withValues(alpha: 0.4),
                  ),
                  prefixIcon: Icon(
                    LucideIcons.search,
                    color: context.onSurface.withValues(alpha: 0.5),
                    size: 18,
                  ),
                  filled: true,
                  fillColor: context.colors.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                style: TextStyle(color: context.onSurface, fontSize: 14),
                onChanged: widget.controller.searchStocks,
              ),
            ),
          // Scrollable list
          Flexible(
            child: Obx(() {
              // Show search results if searching, otherwise show popular cryptos
              final items =
                  _isSearching &&
                      widget.controller.searchController.text.isNotEmpty
                  ? widget.controller.searchResults
                  : widget.controller.popularAssets;

              if (widget.controller.isLoading.value && _isSearching) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                );
              }

              if (items.isEmpty && _isSearching) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    context.s.chart_header_no_results,
                    style: TextStyle(
                      color: context.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                );
              }

              // أضف Controller للتحكم في السكرول وتحريكه عند الضغط
              // ملاحظة: تأكد من تعريف الـ Controller خارج الـ build لضمان استقراره
              final FixedExtentScrollController _wheelController =
                  FixedExtentScrollController();

              const double itemHeight = 60.0; // قللنا ارتفاع العنصر
              final double viewportHeight = 320.0.h.clamp(
                270,
                370,
              ); // قللنا الارتفاع الكلي ليصبح أصغر

              return Center(
                child: SizedBox(
                  height: viewportHeight,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 1. طبقة الـ Glass الثابتة في المنتصف
                      IgnorePointer(
                        // ضروري جداً عشان تقدر تضغط على العناصر تحتها
                        child: Container(
                          height: itemHeight + 10, // أكبر من العنصر قليلاً
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: context.onSurface.withValues(
                              alpha: 0.03,
                            ), // خلفية خفيفة جداً
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: context.onSurface.withValues(alpha: 0.08),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      // 2. القائمة الدوارة
                      ListWheelScrollView.useDelegate(
                        controller: _wheelController,
                        itemExtent: itemHeight,
                        perspective: 0.003, // ميل خفيف جداً
                        diameterRatio: 2.0, // جعل الدائرة مسطحة أكثر
                        physics: const FixedExtentScrollPhysics(),
                        useMagnifier: true,
                        magnification: 1.1, // تكبير بسيط جداً
                        onSelectedItemChanged: (index) {
                          // اختياري: إضافة Haptic Feedback هنا
                        },
                        childDelegate: ListWheelChildLoopingListDelegate(
                          children: items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final stock = entry.value;
                            final isSelected =
                                widget.controller.selectedStock.value?.symbol ==
                                stock.symbol;

                            return GestureDetector(
                              onTap: () {
                                widget.controller.selectStock(stock);
                                _wheelController.animateToItem(
                                  index,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.decelerate,
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  // نجعل الخلفية شفافة لأن الـ Glass Overlay هو من يعطي الشكل
                                  color: isSelected
                                      ? context.primary.withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: ListTile(
                                    dense: true,
                                    leading: buildLogo(stock),
                                    title: Text(
                                      stock.symbol,
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? context.primary
                                            : context.onSurface,
                                        fontSize: 14,
                                      ),
                                    ),
                                    trailing: isSelected
                                        ? Icon(
                                            Icons.check_circle,
                                            color: context.primary,
                                            size: 18,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget buildLogo(dynamic stock) {
    return stock.logoUrl != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              stock.logoUrl!,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  LucideIcons.coins,
                  color: context.primary,
                  size: 16,
                ),
              ),
            ),
          )
        : Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(LucideIcons.coins, color: context.primary, size: 16),
          );
  }
}
