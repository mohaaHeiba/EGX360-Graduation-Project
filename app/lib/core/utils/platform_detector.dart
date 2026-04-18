import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Platform detection utility for conditional UI rendering
class PlatformDetector {
  // Private constructor to prevent instantiation
  PlatformDetector._();

  /// Check if running on desktop platforms (Linux, Windows, macOS)
  static bool get isDesktop => isLinux || isWindows || isMacOS;

  /// Check if running on mobile platforms (iOS, Android)
  static bool get isMobile => isIOS || isAndroid;

  /// Check if running on Linux
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// Check if running on Windows
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Check if running on macOS
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Check if running on iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Check if running on Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Check if running on Web
  static bool get isWeb => kIsWeb;

  /// Get current platform as a string
  static String get platformName {
    if (isLinux) return 'Linux';
    if (isWindows) return 'Windows';
    if (isMacOS) return 'macOS';
    if (isIOS) return 'iOS';
    if (isAndroid) return 'Android';
    if (isWeb) return 'Web';
    return 'Unknown';
  }

  /// Get platform-specific value
  /// Returns the value corresponding to the current platform
  static T platformValue<T>({required T mobile, required T desktop, T? web}) {
    if (isWeb && web != null) return web;
    if (isDesktop) return desktop;
    return mobile;
  }

  /// Get specific platform value with more granular control
  static T specificPlatformValue<T>({
    T? linux,
    T? windows,
    T? macOS,
    T? iOS,
    T? android,
    T? web,
    required T fallback,
  }) {
    if (isLinux && linux != null) return linux;
    if (isWindows && windows != null) return windows;
    if (isMacOS && macOS != null) return macOS;
    if (isIOS && iOS != null) return iOS;
    if (isAndroid && android != null) return android;
    if (isWeb && web != null) return web;
    return fallback;
  }
}
