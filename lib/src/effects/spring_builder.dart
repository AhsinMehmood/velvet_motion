import 'package:flutter/widgets.dart';

import '../core/motion_value.dart';
import '../core/spring.dart';
import '../theme/motion_theme.dart';

/// Implicitly animates [value] with a spring and rebuilds via [builder].
///
/// ```dart
/// SpringBuilder(
///   value: isOpen ? 1.0 : 0.0,
///   spring: Spring.bouncy,
///   builder: (context, t, child) => Transform.scale(
///     scale: 0.9 + 0.1 * t,
///     child: child,
///   ),
///   child: const Panel(),
/// );
/// ```
class SpringBuilder extends StatefulWidget {
  /// Creates a spring-driven implicit animation.
  const SpringBuilder({
    super.key,
    required this.value,
    required this.builder,
    this.spring,
    this.child,
  });

  /// Target value to spring toward when it changes.
  final double value;

  /// Spring used for the animation; falls back to [MotionTheme].
  final Spring? spring;

  /// Builds the animated subtree from the current spring progress [t].
  final TransitionBuilderWithValue builder;

  /// Optional child passed through to [builder] for subtree reuse.
  final Widget? child;

  @override
  State<SpringBuilder> createState() => _SpringBuilderState();
}

/// Signature for [SpringBuilder.builder].
typedef TransitionBuilderWithValue =
    Widget Function(BuildContext context, double t, Widget? child);

class _SpringBuilderState extends State<SpringBuilder>
    with SingleTickerProviderStateMixin {
  late MotionValue _motion;

  @override
  void initState() {
    super.initState();
    _motion = MotionValue(widget.value, vsync: this);
    _motion.addListener(_onMotion);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motion.spring = widget.spring ?? MotionTheme.of(context).spring;
  }

  @override
  void didUpdateWidget(SpringBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    _motion.spring = widget.spring ?? MotionTheme.of(context).spring;
    if (widget.value != oldWidget.value) {
      if (MotionTheme.reduceMotionOf(context)) {
        _motion.set(widget.value);
      } else {
        _motion.animateTo(widget.value);
      }
    }
  }

  void _onMotion() {
    setState(() {});
  }

  @override
  void dispose() {
    _motion
      ..removeListener(_onMotion)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: widget.builder(context, _motion.value, widget.child),
    );
  }
}
