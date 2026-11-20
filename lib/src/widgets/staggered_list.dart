import 'package:flutter/widgets.dart';

import '../core/spring.dart';
import '../effects/effect.dart';
import '../effects/spring_builder.dart';
import '../theme/motion_theme.dart';

/// Staggers entrance animations for a list of children.
///
/// ```dart
/// StaggeredList(
///   interval: const Duration(milliseconds: 40),
///   effect: Effect.fadeUp(distance: 12),
///   children: [for (final o in orders) OrderTile(o)],
/// );
/// ```
class StaggeredList extends StatelessWidget {
  /// Creates a staggered entrance list.
  const StaggeredList({
    super.key,
    required this.children,
    this.interval = const Duration(milliseconds: 40),
    this.effect,
    this.spring,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.controller,
  });

  /// Children to animate in.
  final List<Widget> children;

  /// Delay between consecutive item starts.
  final Duration interval;

  /// Entrance effect; defaults to [Effect.fadeUp].
  final Effect? effect;

  /// Spring for each item.
  final Spring? spring;

  /// Optional list padding.
  final EdgeInsetsGeometry? padding;

  /// Scroll physics.
  final ScrollPhysics? physics;

  /// Whether the list should shrink-wrap its contents.
  final bool shrinkWrap;

  /// Optional scroll controller.
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final Effect resolved = effect ?? Effect.fadeUp();
    return ListView.builder(
      controller: controller,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: children.length,
      itemBuilder: (BuildContext context, int index) {
        return _StaggeredItem(
          delay: interval * index,
          effect: resolved,
          spring: spring,
          child: children[index],
        );
      },
    );
  }
}

class _StaggeredItem extends StatefulWidget {
  const _StaggeredItem({
    required this.child,
    required this.delay,
    required this.effect,
    this.spring,
  });

  final Widget child;
  final Duration delay;
  final Effect effect;
  final Spring? spring;

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem> {
  double _target = 0;
  bool _armed = false;

  @override
  Widget build(BuildContext context) {
    return _VisibilityDetector(
      onVisible: _arm,
      child: SpringBuilder(
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
      ),
    );
  }

  Future<void> _arm() async {
    if (_armed) {
      return;
    }
    _armed = true;
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
}

class _VisibilityDetector extends StatefulWidget {
  const _VisibilityDetector({required this.child, required this.onVisible});

  final Widget child;
  final VoidCallback onVisible;

  @override
  State<_VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<_VisibilityDetector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onVisible();
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
