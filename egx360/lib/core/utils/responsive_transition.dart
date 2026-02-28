import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Responsive transition helper that provides different transitions
/// based on screen size (mobile vs desktop)
class ResponsiveTransition extends CustomTransition {
  final Transition mobileTransition;

  ResponsiveTransition({required this.mobileTransition});

  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 800;

    if (isDesktop) {
      // Desktop: Fade transition
      return FadeTransition(opacity: animation, child: child);
    } else {
      // Mobile: Use the specified mobile transition
      return _getMobileTransitionWidget(
        mobileTransition,
        context,
        animation,
        secondaryAnimation,
        child,
      );
    }
  }

  /// Returns adaptive transition
  static ResponsiveTransition adaptive({required Transition mobileTransition}) {
    return ResponsiveTransition(mobileTransition: mobileTransition);
  }

  /// Get the appropriate transition widget for mobile
  static Widget _getMobileTransitionWidget(
    Transition transition,
    BuildContext context,
    Animation<double> current,
    Animation<double> next,
    Widget child,
  ) {
    switch (transition) {
      case Transition.rightToLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(current),
          child: child,
        );

      case Transition.leftToRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(current),
          child: child,
        );

      case Transition.downToUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(current),
          child: child,
        );

      case Transition.upToDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(current),
          child: child,
        );

      case Transition.fadeIn:
      default:
        return FadeTransition(opacity: current, child: child);
    }
  }
}
