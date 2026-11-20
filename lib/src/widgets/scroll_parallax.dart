import 'package:flutter/widgets.dart';

import '../effects/spring_builder.dart';
import '../theme/motion_theme.dart';

/// Maps a scroll [offset] into a parallax translation.
double parallaxOffset({
  required double offset,
  double factor = 0.35,
  double max = 80,
}) {
  final double raw = offset * factor;
  if (raw.abs() <= max) {
    return raw;
  }
  return raw.sign * max;
}

/// Builds a child from the enclosing scrollable's pixels.
///
/// Place inside a scroll view (or pass [controller]):
///
/// ```dart
/// ListView(
///   children: [
///     ScrollMotionBuilder(
///       builder: (context, offset, child) => Opacity(
///         opacity: (1 - offset / 200).clamp(0.4, 1),
///         child: child,
///       ),
///       child: const Header(),
///     ),
///   ],
/// );
/// ```
class ScrollMotionBuilder extends StatefulWidget {
  /// Creates a scroll-linked builder.
  const ScrollMotionBuilder({
    super.key,
    required this.builder,
    this.child,
    this.controller,
  });

  /// Builds from the current scroll [offset] in pixels.
  final Widget Function(BuildContext context, double offset, Widget? child)
      builder;

  /// Optional child passed through to [builder].
  final Widget? child;

  /// Optional explicit [ScrollController]; otherwise uses enclosing [Scrollable].
  final ScrollController? controller;

  @override
  State<ScrollMotionBuilder> createState() => _ScrollMotionBuilderState();
}

class _ScrollMotionBuilderState extends State<ScrollMotionBuilder> {
  double _offset = 0;
  ScrollPosition? _position;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onController);
    if (widget.controller?.hasClients ?? false) {
      _offset = widget.controller!.offset;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.controller != null) {
      return;
    }
    final ScrollPosition? next = Scrollable.maybeOf(context)?.position;
    if (_position != next) {
      _position?.isScrollingNotifier.removeListener(_onPosition);
      _position?.removeListener(_onPosition);
      _position = next;
      _position?.addListener(_onPosition);
      _offset = _position?.pixels ?? 0;
    }
  }

  @override
  void didUpdateWidget(ScrollMotionBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onController);
      widget.controller?.addListener(_onController);
      if (widget.controller?.hasClients ?? false) {
        _offset = widget.controller!.offset;
      }
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onController);
    _position?.removeListener(_onPosition);
    super.dispose();
  }

  void _onController() {
    final double next = widget.controller?.offset ?? 0;
    if (next != _offset) {
      setState(() => _offset = next);
    }
  }

  void _onPosition() {
    final double next = _position?.pixels ?? 0;
    if (next != _offset) {
      setState(() => _offset = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _offset, widget.child);
  }
}

/// Translates [child] against scroll for a parallax layer.
///
/// ```dart
/// ScrollParallax(
///   factor: 0.4,
///   child: Image.asset('hero.jpg', fit: BoxFit.cover),
/// );
/// ```
class ScrollParallax extends StatelessWidget {
  /// Creates a parallax layer.
  const ScrollParallax({
    super.key,
    required this.child,
    this.controller,
    this.factor = 0.35,
    this.max = 80,
    this.axis = Axis.vertical,
    this.springToRest = false,
  });

  /// Layer content.
  final Widget child;

  /// Optional scroll controller.
  final ScrollController? controller;

  /// How strongly the layer moves with scroll (`0` = locked).
  final double factor;

  /// Caps the parallax translation.
  final double max;

  /// Scroll axis to follow.
  final Axis axis;

  /// When true, springs toward the mapped offset instead of 1:1 tracking.
  final bool springToRest;

  @override
  Widget build(BuildContext context) {
    final bool reduce = MotionTheme.reduceMotionOf(context);

    return ScrollMotionBuilder(
      controller: controller,
      builder: (BuildContext context, double offset, Widget? child) {
        final double shifted = parallaxOffset(
          offset: offset,
          factor: factor,
          max: max,
        );
        final Offset translation = axis == Axis.vertical
            ? Offset(0, shifted)
            : Offset(shifted, 0);

        if (reduce || !springToRest) {
          return Transform.translate(offset: translation, child: child);
        }

        return SpringBuilder(
          value: shifted,
          builder: (BuildContext context, double t, Widget? c) {
            final Offset o =
                axis == Axis.vertical ? Offset(0, t) : Offset(t, 0);
            return Transform.translate(offset: o, child: c);
          },
          child: child,
        );
      },
      child: child,
    );
  }
}
