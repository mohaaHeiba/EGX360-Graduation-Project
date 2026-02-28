import 'package:egx/core/helper/context_extensions.dart';
import 'package:flutter/material.dart';

/// Widget to display empty state when no data is available
class EmptyStateWidget extends StatelessWidget {
  final String message;

  const EmptyStateWidget({super.key, this.message = "Select a Crypto Asset"});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: TextStyle(color: context.onSurface)),
    );
  }
}
