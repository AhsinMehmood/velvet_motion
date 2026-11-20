import 'package:flutter/widgets.dart';

import '../core/spring.dart';
import '../effects/spring_builder.dart';
import '../theme/motion_theme.dart';

/// A shimmering placeholder that springs into [child] when [loading] becomes false.
///
/// ```dart
/// SkeletonShimmer(
///   loading: isLoading,
///   child: OrderTile(order),
/// );
/// ```
class SkeletonShimmer extends StatefulWidget {
  /// Creates a skeleton shimmer cross-fade.
  const SkeletonShimmer({
    super.key,
    required this.loading,
    required this.child,
    this.skeleton,
    this.spring,
    this.baseColor = const Color(0xFFE8E8E8),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  /// When true, shows the shimmer skeleton.
  final bool loading;

  /// Real content revealed when not loading.
  final Widget child;

  /// Optional custom skeleton; defaults to a rounded rect shimmer.
  final Widget? skeleton;

  /// Spring used when revealing content.
  final Spring? spring;

  /// Base skeleton color.
  final Color baseColor;

  /// Highlight sweep color.
  final Color highlightColor;

  /// Corner radius for the default skeleton.
  final BorderRadius borderRadius;

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.loading) {
      _shimmer.repeat();
    }
  }

  @override
  void didUpdateWidget(SkeletonShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loading && !_shimmer.isAnimating) {
      _shimmer.repeat();
    } else if (!widget.loading && _shimmer.isAnimating) {
      _shimmer.stop();
    }
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduce = MotionTheme.reduceMotionOf(context);
    final double reveal = widget.loading ? 0 : 1;

    final Widget skeleton = widget.skeleton ??
        AnimatedBuilder(
          animation: _shimmer,
          builder: (BuildContext context, Widget? child) {
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                gradient: LinearGradient(
                  begin: Alignment(-1 - _shimmer.value * 2, 0),
                  end: Alignment(1 + _shimmer.value * 2, 0),
                  colors: <Color>[
                    widget.baseColor,
                    widget.highlightColor,
                    widget.baseColor,
                  ],
                ),
              ),
              child: child,
            );
          },
          child: const SizedBox(height: 72, width: double.infinity),
        );

    if (reduce) {
      return widget.loading ? skeleton : widget.child;
    }

    return SpringBuilder(
      value: reveal,
      spring: widget.spring ?? Spring.snappy,
      builder: (BuildContext context, double t, Widget? child) {
        return Stack(
          children: <Widget>[
            Opacity(opacity: (1 - t).clamp(0.0, 1.0), child: skeleton),
            Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, (1 - t) * 8),
                child: child,
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}
