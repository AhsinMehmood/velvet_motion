import 'package:cupertino_ui/cupertino_ui.dart';

import '../core/spring.dart';
import '../theme/motion_theme.dart';

/// Visual style for a [VelvetRoute] transition.
enum RouteStyle {
  /// Incoming page slides and scales in; previous page recedes.
  push,

  /// Modal rise from the bottom with dimming.
  modal,

  /// Cross-fade between pages.
  fade,
}

/// A [PageRoute] that transitions with Velvet springs.
///
/// ```dart
/// Navigator.of(context).push(
///   VelvetRoute(
///     builder: (_) => const OrderDetails(),
///     spring: Spring.smooth,
///     style: RouteStyle.push,
///   ),
/// );
/// ```
class VelvetRoute<T> extends PageRouteBuilder<T> {
  /// Creates a spring-driven page route.
  VelvetRoute({
    required WidgetBuilder builder,
    this.spring,
    this.style = RouteStyle.push,
    super.settings,
    super.fullscreenDialog,
  }) : super(
         pageBuilder:
             (
               BuildContext context,
               Animation<double> animation,
               Animation<double> secondaryAnimation,
             ) {
               return builder(context);
             },
         transitionsBuilder:
             (
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
             },
         transitionDuration: const Duration(milliseconds: 900),
         reverseTransitionDuration: const Duration(milliseconds: 900),
       );

  /// Spring used for the transition; falls back to [MotionTheme].
  final Spring? spring;

  /// Which transition look to use.
  final RouteStyle style;
}

/// Builds the Velvet transition tree used by routes and theme builders.
Widget buildVelvetTransitions({
  required BuildContext context,
  required Animation<double> animation,
  required Animation<double> secondaryAnimation,
  required Widget child,
  RouteStyle style = RouteStyle.push,
  Spring? spring,
}) {
  final bool reduce = MotionTheme.reduceMotionOf(context);
  if (reduce) {
    return FadeTransition(opacity: animation, child: child);
  }

  final Spring effective = spring ?? MotionTheme.of(context).spring;
  final Animation<double> primary = _springify(animation, effective);
  final Animation<double> secondary = _springify(secondaryAnimation, effective);

  switch (style) {
    case RouteStyle.push:
      return _PushTransition(
        primary: primary,
        secondary: secondary,
        child: child,
      );
    case RouteStyle.modal:
      return _ModalTransition(primary: primary, child: child);
    case RouteStyle.fade:
      return FadeTransition(opacity: primary, child: child);
  }
}

Animation<double> _springify(Animation<double> parent, Spring spring) {
  return CurvedAnimation(
    parent: parent,
    curve: _SpringCurve(spring),
    reverseCurve: _SpringCurve(spring),
  );
}

class _SpringCurve extends Curve {
  const _SpringCurve(this.spring);

  final Spring spring;

  @override
  double transformInternal(double t) {
    final double bounce = spring.bounce.clamp(0.0, 0.95);
    final double overshoot = 1 + bounce * 0.35 * (1 - t) * (1 - t);
    final double eased = Curves.easeOutCubic.transform(t);
    return (eased * overshoot).clamp(0.0, 1.2);
  }
}

class _PushTransition extends StatelessWidget {
  const _PushTransition({
    required this.primary,
    required this.secondary,
    required this.child,
  });

  final Animation<double> primary;
  final Animation<double> secondary;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Animation<Offset> slide = Tween<Offset>(
      begin: const Offset(0.14, 0),
      end: Offset.zero,
    ).animate(primary);
    final Animation<double> scaleIn = Tween<double>(
      begin: 0.96,
      end: 1,
    ).animate(primary);
    final Animation<double> recedeScale = Tween<double>(
      begin: 1,
      end: 0.94,
    ).animate(secondary);
    final Animation<double> recedeOpacity = Tween<double>(
      begin: 1,
      end: 0.72,
    ).animate(secondary);

    return SlideTransition(
      position: slide,
      child: ScaleTransition(
        scale: scaleIn,
        child: FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(primary),
          child: ScaleTransition(
            scale: recedeScale,
            child: FadeTransition(opacity: recedeOpacity, child: child),
          ),
        ),
      ),
    );
  }
}

class _ModalTransition extends StatelessWidget {
  const _ModalTransition({required this.primary, required this.child});

  final Animation<double> primary;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Animation<Offset> slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(primary);

    return AnimatedBuilder(
      animation: primary,
      builder: (BuildContext context, Widget? child) {
        return ColoredBox(
          color:
              Color.lerp(
                const Color(0x00000000),
                const Color(0x66000000),
                primary.value.clamp(0.0, 1.0),
              ) ??
              const Color(0x66000000),
          child: child,
        );
      },
      child: SlideTransition(
        position: slide,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1).animate(primary),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(primary),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Cupertino page route for edge-swipe back with an optional Velvet [spring].
class VelvetPageRoute<T> extends CupertinoPageRoute<T> {
  /// Creates a Cupertino page route that exposes an optional [spring].
  VelvetPageRoute({
    required super.builder,
    this.spring,
    super.settings,
    super.title,
  });

  /// Preferred spring for theme consumers; pop gesture uses Cupertino physics.
  final Spring? spring;
}
