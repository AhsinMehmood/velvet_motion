import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../core/spring.dart';
import '../effects/spring_builder.dart';
import '../theme/motion_theme.dart';

/// Cross-fades and rotates between two icons with a spring.
///
/// ```dart
/// MorphIcon(
///   showAlternate: isFavorite,
///   icon: Icon(Icons.favorite_border),
///   alternateIcon: Icon(Icons.favorite),
/// );
/// ```
class MorphIcon extends StatelessWidget {
  /// Creates a morphing icon pair.
  const MorphIcon({
    super.key,
    required this.icon,
    required this.alternateIcon,
    required this.showAlternate,
    this.spring,
    this.size = 24,
    this.color,
  });

  /// Primary icon (shown when [showAlternate] is false).
  final Widget icon;

  /// Alternate icon (shown when [showAlternate] is true).
  final Widget alternateIcon;

  /// Which icon is active.
  final bool showAlternate;

  /// Spring for the morph.
  final Spring? spring;

  /// Icon box size.
  final double size;

  /// Optional color applied via [IconTheme].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bool reduce = MotionTheme.reduceMotionOf(context);
    final Widget content = reduce
        ? _stack(showAlternate ? 1 : 0)
        : SpringBuilder(
            value: showAlternate ? 1 : 0,
            spring: spring ?? Spring.snappy,
            builder: (BuildContext context, double t, Widget? child) {
              return _stack(t);
            },
          );

    Widget boxed = SizedBox(width: size, height: size, child: content);
    if (color != null) {
      boxed = IconTheme.merge(
        data: IconThemeData(color: color, size: size),
        child: boxed,
      );
    }
    return boxed;
  }

  Widget _stack(double t) {
    final double clamped = t.clamp(0.0, 1.0);
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Transform.rotate(
          angle: -clamped * math.pi / 2,
          child: Opacity(
            opacity: 1 - clamped,
            child: Transform.scale(scale: 1 - clamped * 0.2, child: icon),
          ),
        ),
        Transform.rotate(
          angle: (1 - clamped) * math.pi / 2,
          child: Opacity(
            opacity: clamped,
            child: Transform.scale(
              scale: 0.8 + clamped * 0.2,
              child: alternateIcon,
            ),
          ),
        ),
      ],
    );
  }
}
