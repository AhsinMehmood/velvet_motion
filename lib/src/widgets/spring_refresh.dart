import 'package:flutter/widgets.dart';

import '../core/motion_value.dart';
import '../core/spring.dart';
import '../theme/motion_theme.dart';

/// Pull-to-refresh state for [SpringRefresh].
enum SpringRefreshState {
  /// Idle, waiting for a pull.
  idle,

  /// User is dragging.
  pulling,

  /// Past the trigger threshold, ready to refresh on release.
  armed,

  /// Refresh callback is running.
  refreshing,

  /// Settling back after refresh.
  settling,
}

/// Builds a branded pull indicator from progress `0..1` and [state].
typedef SpringRefreshIndicatorBuilder = Widget Function(
  BuildContext context,
  double progress,
  SpringRefreshState state,
);

/// A springy pull-to-refresh wrapper with a custom indicator builder.
///
/// ```dart
/// SpringRefresh(
///   onRefresh: fetchOrders,
///   triggerDistance: 90,
///   indicator: (context, progress, state) => LogoStroke(progress: progress),
///   child: ListView(children: tiles),
/// );
/// ```
class SpringRefresh extends StatefulWidget {
  /// Creates a spring pull-to-refresh.
  const SpringRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    required this.indicator,
    this.triggerDistance = 90,
    this.spring,
    this.displacement = 56,
  });

  /// Scrollable child.
  final Widget child;

  /// Called when a refresh is triggered.
  final Future<void> Function() onRefresh;

  /// Builds the indicator from pull progress and state.
  final SpringRefreshIndicatorBuilder indicator;

  /// Drag distance in logical pixels that arms the refresh.
  final double triggerDistance;

  /// Spring used when the indicator settles.
  final Spring? spring;

  /// How far the indicator sits below the top while refreshing.
  final double displacement;

  @override
  State<SpringRefresh> createState() => _SpringRefreshState();
}

class _SpringRefreshState extends State<SpringRefresh>
    with SingleTickerProviderStateMixin {
  late final MotionValue _offset;
  SpringRefreshState _state = SpringRefreshState.idle;
  double _drag = 0;

  @override
  void initState() {
    super.initState();
    _offset = MotionValue(
      0,
      vsync: this,
      spring: widget.spring ?? Spring.snappy,
    );
    _offset.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(SpringRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spring != null) {
      _offset.spring = widget.spring!;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _offset.spring = widget.spring ?? Spring.snappy;
  }

  double get _progress =>
      (_offset.value / widget.triggerDistance).clamp(0.0, 1.0);

  Future<void> _runRefresh() async {
    setState(() => _state = SpringRefreshState.refreshing);
    if (MotionTheme.reduceMotionOf(context)) {
      _offset.set(widget.displacement);
    } else {
      _offset.animateTo(widget.displacement);
    }
    try {
      await widget.onRefresh();
    } catch (_) {
      // Surface settle even if refresh fails.
    }
    if (!mounted) {
      return;
    }
    setState(() => _state = SpringRefreshState.settling);
    if (MotionTheme.reduceMotionOf(context)) {
      _offset.set(0);
    } else {
      await _offset.animateTo(0);
    }
    if (!mounted) {
      return;
    }
    setState(() => _state = SpringRefreshState.idle);
  }

  bool _onScroll(ScrollNotification notification) {
    if (_state == SpringRefreshState.refreshing ||
        _state == SpringRefreshState.settling) {
      return false;
    }

    if (notification is ScrollUpdateNotification) {
      final double pixels = notification.metrics.pixels;
      if (pixels < 0) {
        _drag = -pixels;
        _offset.set(_drag);
        final SpringRefreshState next = _drag >= widget.triggerDistance
            ? SpringRefreshState.armed
            : SpringRefreshState.pulling;
        if (next != _state) {
          setState(() => _state = next);
        }
      } else if (_state == SpringRefreshState.pulling ||
          _state == SpringRefreshState.armed) {
        _drag = 0;
        _offset.set(0);
        setState(() => _state = SpringRefreshState.idle);
      }
    }

    if (notification is ScrollEndNotification) {
      if (_state == SpringRefreshState.armed) {
        _runRefresh();
      } else if (_state == SpringRefreshState.pulling) {
        if (MotionTheme.reduceMotionOf(context)) {
          _offset.set(0);
        } else {
          _offset.animateTo(0);
        }
        setState(() => _state = SpringRefreshState.idle);
      }
    }

    return false;
  }

  @override
  void dispose() {
    _offset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: Stack(
        children: <Widget>[
          widget.child,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: SizedBox(
                height: _offset.value.clamp(0, widget.triggerDistance * 1.4),
                child: Center(
                  child: widget.indicator(context, _progress, _state),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
