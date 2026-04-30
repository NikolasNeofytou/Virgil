import 'package:flutter/material.dart';

import 'meraki_motion.dart';

/// Global helper for building screen-to-screen page transitions.
///
/// Replaces `MaterialPageRoute(builder: ...)` with a fade + 12px upward
/// slide that matches the rest of the app's restrained motion language.
///
/// Usage:
/// ```dart
/// Navigator.of(context).push(AppRoute.build((_) => SomeScreen()));
/// ```
class AppRoute {
  AppRoute._();

  static const _slidePixels = 12.0;

  /// Forward route with the standard transition.
  static PageRouteBuilder<T> build<T>(WidgetBuilder builder) {
    return PageRouteBuilder<T>(
      transitionDuration: MerakiMotion.normal,
      reverseTransitionDuration: MerakiMotion.normal,
      pageBuilder: (context, _, __) => builder(context),
      transitionsBuilder: (context, animation, secondary, child) {
        final eased = CurvedAnimation(
          parent: animation,
          curve: MerakiMotion.entrance,
          reverseCurve: MerakiMotion.exit,
        );
        return FadeTransition(
          opacity: eased,
          child: AnimatedBuilder(
            animation: eased,
            builder: (context, child) {
              final offset = (1 - eased.value) * _slidePixels;
              return Transform.translate(
                offset: Offset(0, offset),
                child: child,
              );
            },
            child: child,
          ),
        );
      },
    );
  }
}
