import 'package:flutter/widgets.dart';

import '../core/spring.dart';
import '../theme/motion_theme.dart';
import '../widgets/press_scale.dart';
import 'effect.dart';
import 'spring_builder.dart';

/// Adds a `.motion` getter for one-line entrance and press effects.
extension MotionWidgetX on Widget {
  /// Motion helpers for this widget.
  MotionProxy get motion => MotionProxy(this);
}

/// Fluent wrappers around common Velvet Motion effects.
class MotionProxy {
  /// Creates a proxy for [child].
  const MotionProxy(this.child);

  /// The widget receiving motion effects.
  final Widget child;

  /// Fades up by [distance] when first built, optionally after [delay].
  Widget fadeUp({
    Duration delay = Duration.zero,
    double distance = 12,
    Spring? spring,
  }) {
    return _EntranceMotion(
      delay: delay,
      spring: spring,
      effect: Effect.fadeUp(distance: distance),
      child: child,
    );
  }

  /// Scales in when first built, optionally after [delay].
  Widget scaleIn({
    Duration delay = Duration.zero,
    Spring? spring,
    double beginScale = 0.92,
  }) {
    return _EntranceMotion(
      delay: delay,
      spring: spring,
      effect: Effect.scaleIn(beginScale: beginScale),
      child: child,
    );
  }

  /// Makes the widget pressable with scale and haptic feedback.
  Widget pressable({
    VoidCallback? onTap,
    double scale = 0.96,
    Haptic haptic = Haptic.light,
    Spring? spring,
  }) {
    return PressScale(
      onTap: onTap,
      scale: scale,
      haptic: haptic,
      spring: spring,
      child: child,
    );
  }
}

class _EntranceMotion extends StatefulWidget {
  const _EntranceMotion({
    required this.child,
    required this.effect,
    required this.delay,
    this.spring,
  });

  final Widget child;
  final Effect effect;
  final Duration delay;
  final Spring? spring;

  @override
  State<_EntranceMotion> createState() => _EntranceMotionState();
}

class _EntranceMotionState extends State<_EntranceMotion> {
  double _target = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _arm());
  }

  Future<void> _arm() async {
    if (!mounted) {
      return;
    }
    if (MotionTheme.reduceMotionOf(context)) {
      setState(() => _target = 1);
      return;
    }
    if (widget.delay > Duration.zero) {
      await Future<void>.delayed(widget.delay);
      if (!mounted) {
        return;
      }
    }
    setState(() => _target = 1);
  }

  @override
  Widget build(BuildContext context) {
    return SpringBuilder(
      value: _target,
      spring: widget.spring,
      builder: (BuildContext context, double t, Widget? child) {
        switch (widget.effect.kind) {
          case EffectKind.fadeUp:
            return Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, (1 - t) * widget.effect.distance),
                child: child,
              ),
            );
          case EffectKind.scaleIn:
            final double scale =
                widget.effect.beginScale + (1 - widget.effect.beginScale) * t;
            return Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: Transform.scale(scale: scale, child: child),
            );
        }
      },
      child: widget.child,
    );
  }
}
