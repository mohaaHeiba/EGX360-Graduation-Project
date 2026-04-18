import 'package:egx/generated/l10n.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/assets/presentation/controllers/asset_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AssetTimeRangeSelector extends StatelessWidget {
  final AssetDetailsController controller;

  const AssetTimeRangeSelector({super.key, required this.controller});

  String _getLocalRange(String range, BuildContext context) {
    switch (range) {
      case '1D':
        return S.of(context).range_1d;
      case '5D':
        return S.of(context).range_5d;
      case '1W':
        return S.of(context).range_1w;
      case '1M':
        return S.of(context).range_1m;
      case '3M':
        return S.of(context).range_3m;
      case '6M':
        return S.of(context).range_6m;
      case '1Y':
        return S.of(context).range_1y;
      case '5Y':
        return S.of(context).range_5y;
      case 'All':
        return S.of(context).range_all;
      default:
        return range;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: controller.timeRanges.map((range) {
          return Obx(() {
            final isSelected = controller.selectedTimeRange.value == range;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(_getLocalRange(range, context)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    controller.updateTimeRange(range);
                  }
                },
                selectedColor: context.primary,
                labelStyle: TextStyle(
                  color: isSelected ? context.onPrimary : context.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: context.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }
}
