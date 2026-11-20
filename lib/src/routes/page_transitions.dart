import 'package:material_ui/material_ui.dart';

import '../core/spring.dart';
import 'velvet_route.dart';

/// Entry points for app-wide Velvet page transitions.
class VelvetMotion {
  const VelvetMotion._();

  /// A [PageTransitionsTheme] that uses Velvet spring transitions.
  ///
  /// ```dart
  /// theme: ThemeData(pageTransitionsTheme: VelvetMotion.pageTransitions),
  /// ```
  static const PageTransitionsTheme pageTransitions = PageTransitionsTheme(
    // `builders` is the public name for material_ui's `this._builders` formal.
    // ignore: undefined_named_parameter
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: VelvetPageTransitionsBuilder(),
      TargetPlatform.iOS: VelvetPageTransitionsBuilder(),
      TargetPlatform.macOS: VelvetPageTransitionsBuilder(),
      TargetPlatform.linux: VelvetPageTransitionsBuilder(),
      TargetPlatform.windows: VelvetPageTransitionsBuilder(),
      TargetPlatform.fuchsia: VelvetPageTransitionsBuilder(),
    },
  );
}

/// Builds Velvet spring page transitions for [PageTransitionsTheme].
class VelvetPageTransitionsBuilder extends PageTransitionsBuilder {
  /// Creates a builder using [style] and optional [spring].
  const VelvetPageTransitionsBuilder({
    this.style = RouteStyle.push,
    this.spring,
  });

  /// Transition style applied to platform routes.
  final RouteStyle style;

  /// Optional spring override.
  final Spring? spring;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return buildVelvetTransitions(
      context: context,
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
      style: style,
      spring: spring,
    );
  }
}
