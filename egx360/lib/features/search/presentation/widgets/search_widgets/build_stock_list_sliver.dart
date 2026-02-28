import 'package:flutter/material.dart';
import 'package:egx/features/search/domain/entities/stock_entity.dart';
import 'package:egx/features/search/presentation/widgets/search_widgets/build_list_item.dart';

Widget buildStockListSliver(BuildContext context, List<StockEntity> stocks) {
  if (stocks.isEmpty) {
    return const SliverFillRemaining(
      child: Center(child: Text("No symbols found")),
    );
  }
  return SliverPadding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final stock = stocks[index];
        // Use the external buildListItem widget
        return buildListItem(
          context,
          stock,
          // Pass the function, don't execute it
        );
      }, childCount: stocks.length),
    ),
  );
}
