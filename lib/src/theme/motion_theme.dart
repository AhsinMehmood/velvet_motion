import 'package:flutter/widgets.dart';

import '../core/spring.dart';

/// App-wide motion defaults inherited down the tree.
///
/// ```dart
/// MotionTheme(
///   data: const MotionThemeData(spring: Spring.smooth),
///   child: child,
/// );
/// ```
class MotionTheme extends InheritedWidget {
  /// Creates a motion theme that provides [data] to descendants.
  const MotionTheme({super.key, required this.data, required super.child});

  /// Theme values for springs, reduce-motion, and haptics.
  final MotionThemeData data;

  /// The nearest [MotionThemeData], or [MotionThemeData.fallback] if none.
  static MotionThemeData of(BuildContext context) {
    final MotionTheme? theme = context
        .dependOnInheritedWidgetOfExactType<MotionTheme>();
    return theme?.data ?? MotionThemeData.fallback;
  }

  /// Whether motion should be reduced for this [context].
  ///
  /// True when the theme respects reduce-motion and the platform requests it
  /// via [MediaQueryData.disableAnimations].
  static bool reduceMotionOf(BuildContext context) {
    final MotionThemeData data = of(context);
    if (!data.respectReduceMotion) {
      return false;
    }
    return MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }

  @override
  bool updateShouldNotify(MotionTheme oldWidget) => data != oldWidget.data;
}

/// Configuration for [MotionTheme].
class MotionThemeData {
  /// Creates motion theme data.
  const MotionThemeData({
    this.spring = Spring.smooth,
    this.respectReduceMotion = true,
    this.haptics = true,
  });

  /// Defaults used when no [MotionTheme] is present.
  static const MotionThemeData fallback = MotionThemeData();

  /// Default spring for widgets that do not pass an explicit one.
  final Spring spring;

  /// Whether to honour [MediaQueryData.disableAnimations].
  final bool respectReduceMotion;

  /// Whether haptic feedback is enabled for press interactions.
  final bool haptics;

  /// Returns a copy with the given fields replaced.
  MotionThemeData copyWith({
    Spring? spring,
    bool? respectReduceMotion,
    bool? haptics,
  }) {
    return MotionThemeData(
      spring: spring ?? this.spring,
      respectReduceMotion: respectReduceMotion ?? this.respectReduceMotion,
      haptics: haptics ?? this.haptics,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MotionThemeData &&
        other.spring == spring &&
        other.respectReduceMotion == respectReduceMotion &&
        other.haptics == haptics;
  }

  @override
  int get hashCode => Object.hash(spring, respectReduceMotion, haptics);

  @override
  String toString() {
    return 'MotionThemeData(spring: $spring, '
        'respectReduceMotion: $respectReduceMotion, haptics: $haptics)';
  }
}
