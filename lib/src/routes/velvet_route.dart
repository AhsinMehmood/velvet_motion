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

  /// Material shared-axis along X (horizontal).
  sharedAxisX,

  /// Material shared-axis along Y (vertical).
  sharedAxisY,

  /// Material shared-axis along Z (scale + fade).
  sharedAxisZ,

  /// Material fade-through (outgoing fades out, incoming fades in).
  fadeThrough,
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
    case RouteStyle.sharedAxisX:
      return _SharedAxisTransition(
        primary: primary,
        secondary: secondary,
        axis: Axis.horizontal,
        child: child,
      );
    case RouteStyle.sharedAxisY:
      return _SharedAxisTransition(
        primary: primary,
        secondary: secondary,
        axis: Axis.vertical,
        child: child,
      );
    case RouteStyle.sharedAxisZ:
      return _SharedAxisZTransition(
        primary: primary,
        secondary: secondary,
        child: child,
      );
    case RouteStyle.fadeThrough:
      return _FadeThroughTransition(primary: primary, child: child);
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

class _SharedAxisTransition extends StatelessWidget {
  const _SharedAxisTransition({
    required this.primary,
    required this.secondary,
    required this.child,
    required this.axis,
  });

  final Animation<double> primary;
  final Animation<double> secondary;
  final Widget child;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final Offset begin = axis == Axis.horizontal
        ? const Offset(0.08, 0)
        : const Offset(0, 0.08);
    final Offset exit = axis == Axis.horizontal
        ? const Offset(-0.04, 0)
        : const Offset(0, -0.04);

    return SlideTransition(
      position: Tween<Offset>(begin: begin, end: Offset.zero).animate(primary),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(primary),
        child: SlideTransition(
          position: Tween<Offset>(begin: Offset.zero, end: exit).animate(secondary),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0.85).animate(secondary),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _SharedAxisZTransition extends StatelessWidget {
  const _SharedAxisZTransition({
    required this.primary,
    required this.secondary,
    required this.child,
  });

  final Animation<double> primary;
  final Animation<double> secondary;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.92, end: 1).animate(primary),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(primary),
        child: ScaleTransition(
          scale: Tween<double>(begin: 1, end: 1.04).animate(secondary),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0.6).animate(secondary),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _FadeThroughTransition extends StatelessWidget {
  const _FadeThroughTransition({
    required this.primary,
    required this.child,
  });

  final Animation<double> primary;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Animation<double> fadeOut = CurvedAnimation(
      parent: primary,
      curve: const Interval(0, 0.35, curve: Curves.easeIn),
    );
    final Animation<double> fadeIn = CurvedAnimation(
      parent: primary,
      curve: const Interval(0.35, 1, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(fadeIn),
      child: FadeTransition(
        opacity: Tween<double>(begin: 1, end: 1).animate(fadeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(fadeIn),
          child: child,
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
