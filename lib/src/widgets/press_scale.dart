import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../core/spring.dart';
import '../effects/spring_builder.dart';
import '../theme/motion_theme.dart';

/// Haptic feedback intensity for press interactions.
enum Haptic {
  /// No haptic feedback.
  none,

  /// Light impact, suitable for taps.
  light,

  /// Medium impact.
  medium,

  /// Heavy impact.
  heavy,
}

/// Shrinks [child] under the finger and springs back with a light haptic.
///
/// ```dart
/// PressScale(
///   onTap: () {},
///   scale: 0.96,
///   child: const MenuItemCard(),
/// );
/// ```
class PressScale extends StatefulWidget {
  /// Creates a pressable scale wrapper.
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.96,
    this.haptic = Haptic.light,
    this.spring,
  });

  /// The tappable content.
  final Widget child;

  /// Called when a tap is recognized.
  final VoidCallback? onTap;

  /// Scale while the pointer is down.
  final double scale;

  /// Haptic played on tap, when theme haptics are enabled.
  final Haptic haptic;

  /// Spring used when releasing the press.
  final Spring? spring;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  Future<void> _fireHaptic(BuildContext context) async {
    final MotionThemeData theme = MotionTheme.of(context);
    if (!theme.haptics || widget.haptic == Haptic.none) {
      return;
    }
    switch (widget.haptic) {
      case Haptic.none:
        break;
      case Haptic.light:
        await HapticFeedback.lightImpact();
      case Haptic.medium:
        await HapticFeedback.mediumImpact();
      case Haptic.heavy:
        await HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool reduce = MotionTheme.reduceMotionOf(context);
    final double target = _pressed ? widget.scale : 1;

    final Widget scaled = reduce
        ? Transform.scale(scale: target, child: widget.child)
        : SpringBuilder(
            value: target,
            spring: widget.spring ?? Spring.interactive,
            builder: (BuildContext context, double t, Widget? child) {
              return Transform.scale(scale: t, child: child);
            },
            child: widget.child,
          );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
      onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
      onTap: widget.onTap == null
          ? null
          : () {
              _setPressed(false);
              _fireHaptic(context);
              widget.onTap?.call();
            },
      child: scaled,
    );
  }
}
