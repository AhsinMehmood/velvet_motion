import 'dart:math' as math;

import 'package:flutter/physics.dart';

import '../gestures/rubber_band.dart';

/// A friction/decay helper that glides then stops.
///
/// Use with [MotionValue.fling] / [MotionValue.animateWith], or call
/// [DecayFling.project] to estimate where a fling would land.
class DecayFling {
  /// Creates a decay helper with [drag] (higher = stops sooner).
  const DecayFling({this.drag = 0.015, this.tolerance = 0.5});

  /// Drag coefficient for [FrictionSimulation].
  final double drag;

  /// Speed below which motion is considered done (units/sec).
  final double tolerance;

  /// Flutter [FrictionSimulation] for the given [start] and [velocity].
  FrictionSimulation simulation({
    required double start,
    required double velocity,
  }) {
    return FrictionSimulation(
      drag,
      start,
      velocity,
      tolerance: Tolerance(velocity: tolerance, distance: 0.5),
    );
  }

  /// Projects the final rest position for [start] + [velocity].
  double project({required double start, required double velocity}) {
    if (velocity.abs() < tolerance) {
      return start;
    }
    final FrictionSimulation sim = simulation(start: start, velocity: velocity);
    double t = 0;
    while (!sim.isDone(t) && t < 10) {
      t += 1 / 120;
    }
    return sim.x(t);
  }

  /// Picks a snap near the projected fling end.
  double projectToSnap({
    required double start,
    required double velocity,
    required List<double> snaps,
  }) {
    assert(snaps.isNotEmpty);
    final double projected = project(start: start, velocity: velocity);
    return nearestSnap(value: projected, snaps: snaps);
  }
}

/// Applies a haptic tick when [value] crosses [threshold] in either direction.
class HapticThreshold {
  /// Creates a threshold watcher.
  HapticThreshold(this.threshold);

  /// Threshold value to watch.
  final double threshold;

  bool? _wasAbove;

  /// Returns true exactly when a crossing happens.
  bool crossed(double value) {
    final bool above = value >= threshold;
    if (_wasAbove == null) {
      _wasAbove = above;
      return false;
    }
    if (_wasAbove != above) {
      _wasAbove = above;
      return true;
    }
    return false;
  }

  /// Resets crossing memory.
  void reset() => _wasAbove = null;
}

/// Clamps [value] into [[min], [max]] with optional soft rubber-band.
double clampWithRubber({
  required double value,
  required double min,
  required double max,
  double rubber = 0,
  double dimension = 1,
}) {
  if (rubber <= 0) {
    return value.clamp(min, max);
  }
  return rubberBand(
    value: value,
    min: min,
    max: max,
    factor: rubber,
    dimension: dimension,
  );
}

/// Maps a value through an ease-out exponential curve.
double easeOutExpo(double t) {
  final double x = t.clamp(0.0, 1.0);
  return x >= 1 ? 1 : 1 - math.pow(2, -10 * x).toDouble();
}
