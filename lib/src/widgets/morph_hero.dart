import 'package:flutter/widgets.dart';

import '../core/spring.dart';
import '../routes/velvet_route.dart';
import '../theme/motion_theme.dart';

/// A source widget that can morph into a matching [MorphTarget].
class MorphSource extends StatelessWidget {
  /// Creates a morph source identified by [tag].
  const MorphSource({super.key, required this.tag, required this.child});

  /// Shared tag with the destination [MorphTarget].
  final Object tag;

  /// Source content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      createRectTween: (Rect? begin, Rect? end) =>
          _SpringRectTween(begin: begin, end: end),
      child: child,
    );
  }
}

/// A destination widget that receives a morph from [MorphSource].
class MorphTarget extends StatelessWidget {
  /// Creates a morph target identified by [tag].
  const MorphTarget({
    super.key,
    required this.tag,
    required this.child,
    this.dismissOnDragDown = false,
  });

  /// Shared tag with the source [MorphSource].
  final Object tag;

  /// Destination content.
  final Widget child;

  /// When true, a downward drag pops the route.
  final bool dismissOnDragDown;

  @override
  Widget build(BuildContext context) {
    Widget content = Hero(
      tag: tag,
      createRectTween: (Rect? begin, Rect? end) =>
          _SpringRectTween(begin: begin, end: end),
      child: child,
    );
    if (!dismissOnDragDown) {
      return content;
    }
    return GestureDetector(
      onVerticalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 700) {
          Navigator.of(context).maybePop();
        }
      },
      child: content,
    );
  }
}

/// A [VelvetRoute] tuned for shared-element morph transitions.
class MorphRoute<T> extends VelvetRoute<T> {
  /// Creates a morph-friendly page route.
  MorphRoute({required super.builder, Spring? spring, super.settings})
    : super(spring: spring ?? Spring.smooth, style: RouteStyle.fade);
}

class _SpringRectTween extends RectTween {
  _SpringRectTween({super.begin, super.end});

  @override
  Rect? lerp(double t) {
    final double curved = Curves.easeOutCubic.transform(t.clamp(0.0, 1.0));
    return Rect.lerp(begin, end, curved);
  }
}

/// Returns true when reduce-motion should skip morph flourish.
bool morphReduceMotion(BuildContext context) =>
    MotionTheme.reduceMotionOf(context);
