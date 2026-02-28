import 'package:egx/core/helper/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:egx/core/custom/custom_appbar.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PortfolioWebViewPage extends StatelessWidget {
  final String url;

  const PortfolioWebViewPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final theme = context;
    final s = context.s;
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    Future.delayed(const Duration(milliseconds: 500), () {
      controller.loadRequest(Uri.parse(url));
    });

    return Scaffold(
      backgroundColor: theme.background,
      appBar: customAppbar(Get.back, s.my_portfolio),
      body: WebViewWidget(controller: controller),
    );
  }
}
