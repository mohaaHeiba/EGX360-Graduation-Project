import 'package:egx/core/routes/app_pages_helper.dart';
import 'package:egx/core/theme/app_theme.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:egx/core/services/notification_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Check for notification launch after frame build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationService.checkInitialMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      //overlay
      builder: (context, child) =>
          Overlay(initialEntries: [OverlayEntry(builder: (context) => child!)]),
      // localizations
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      // locale: Locale('ar'),
      //theme
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // bindings
      // initialBinding: InitialBindings(),
      // routes
      initialRoute: AppRoutesHelper.getInitialRoute(),

      getPages: AppPages.routes,
    );
  }
}
