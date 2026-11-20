import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';

import 'spring.dart';

/// A spring-driven [ValueListenable] that stays interruptible.
///
/// Retargeting mid-flight keeps the current velocity. Use [set] to track a
/// finger 1:1, then [release] so fling velocity carries into the spring.
///
/// ```dart
/// final x = MotionValue(0, vsync: this, spring: Spring.snappy);
/// x.animateTo(1);
/// x.set(dragOffset);
/// x.release(velocity: v, to: target);
/// ```
class MotionValue extends ChangeNotifier implements ValueListenable<double> {
  /// Creates a motion value starting at [value].
  ///
  /// [vsync] drives the ticker. [spring] defaults to [Spring.smooth].
  MotionValue(
    double value, {
    required TickerProvider vsync,
    this.spring = Spring.smooth,
    this.tolerance = const Tolerance(distance: 0.001, velocity: 0.001),
  }) : _value = value {
    _ticker = vsync.createTicker(_onTick);
  }

  /// Settling tolerance for the underlying [SpringSimulation].
  final Tolerance tolerance;

  late final Ticker _ticker;

  /// Spring used for subsequent animations.
  Spring spring;

  double _value;
  double _velocity = 0;
  SpringSimulation? _simulation;

  /// Current velocity in units per second.
  double get velocity => _velocity;

  /// Whether a spring animation is currently running.
  bool get isAnimating => _ticker.isActive;

  @override
  double get value => _value;

  /// Animates to [target], keeping current velocity when retargeting.
  ///
  /// Returns a [TickerFuture] that completes when the spring settles, or when
  /// the animation is interrupted by [stop], [set], or another animate call.
  TickerFuture animateTo(double target) {
    _simulation = SpringSimulation(
      spring.description,
      _value,
      target,
      _velocity,
      tolerance: tolerance,
    );
    return _restartTicker();
  }

  /// Jumps to [value], stops any running animation, and clears velocity.
  void set(double value) {
    _halt(canceled: true);
    _velocity = 0;
    if (_value != value) {
      _value = value;
      notifyListeners();
    }
  }

  /// Springs to [to] starting with the given gesture [velocity].
  TickerFuture release({required double velocity, required double to}) {
    _velocity = velocity;
    return animateTo(to);
  }

  /// Stops the ticker and clears velocity without changing [value].
  void stop() {
    _halt(canceled: true);
    _velocity = 0;
  }

  @override
  void dispose() {
    _halt(canceled: true);
    _ticker.dispose();
    super.dispose();
  }

  TickerFuture _restartTicker() {
    if (_ticker.isActive) {
      _ticker.stop(canceled: true);
    }
    return _ticker.start();
  }

  void _halt({required bool canceled}) {
    _simulation = null;
    if (_ticker.isActive) {
      _ticker.stop(canceled: canceled);
    }
  }

  void _onTick(Duration elapsed) {
    final SpringSimulation? simulation = _simulation;
    if (simulation == null) {
      _halt(canceled: true);
      return;
    }

    final double t = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final double next = simulation.x(t);
    _velocity = simulation.dx(t);

    if (_value != next) {
      _value = next;
      notifyListeners();
    }

    if (simulation.isDone(t)) {
      _value = next;
      _velocity = 0;
      _simulation = null;
      notifyListeners();
      if (_ticker.isActive) {
        _ticker.stop(canceled: false);
      }
    }
  }
}
