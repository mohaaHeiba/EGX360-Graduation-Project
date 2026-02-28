import 'dart:io';

import 'package:egx/app.dart';
import 'package:egx/core/data/init_local_data.dart';
import 'package:egx/features/settings/presentaion/controller/theme_controller.dart';
import 'package:egx/core/services/notification_service.dart';
import 'package:egx/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:egx/features/notifications/data/datasource/notification_remote_datasource.dart';
import 'package:egx/features/notifications/data/repository/notification_repository_impl.dart';
import 'package:egx/features/notifications/domain/repository/notification_repository.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:protocol_handler/protocol_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase initialization skipped or failed: $e");
  }

  if (!Platform.isLinux) {
    await NotificationService.init();
  } else {
    print("NotificationService skipped: Not supported on Linux Desktop");
  }
  WebViewPlatform.instance = AndroidWebViewPlatform();
  // load apis from enviroment
  await dotenv.load(fileName: ".env");

  //init supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_APIKEY']!,
  );

  //load theme adn state
  await GetStorage.init();

  // Register custom URL scheme for deep linking (critical for Linux/Windows)
  await protocolHandler.register('io.supabase.flutter');

  //load local storage
  await Get.putAsync(() => InitLocalData().initDatabase(), permanent: true);

  //for theme
  await Get.putAsync(() async => ThemeController(), permanent: true);

  // Register Notification Repository globally
  Get.put<NotificationRemoteDataSource>(
    NotificationRemoteDataSourceImpl(Supabase.instance.client),
    permanent: true,
  );
  Get.put<NotificationRepository>(
    NotificationRepositoryImpl(Get.find()),
    permanent: true,
  );

  // GetStorage().erase();
  runApp(
    ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      fontSizeResolver: (fontSize, instance) {
        if (instance.screenWidth > 600) {
          return fontSize * (600 / 400);
        }
        return fontSize * (instance.screenWidth / 360);
      },
      builder: (context, child) => const MyApp(),
    ),
  );
}
