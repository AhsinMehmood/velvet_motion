import 'dart:math' as math;

/// Applies resistive rubber-banding outside [[min], [max]].
///
/// [factor] is typically `0.0..1.0` (higher = softer edge). `0` clamps hard.
double rubberBand({
  required double value,
  required double min,
  required double max,
  double factor = 0.55,
  double dimension = 1,
}) {
  assert(max >= min);
  if (value >= min && value <= max) {
    return value;
  }
  if (factor <= 0) {
    return value.clamp(min, max);
  }

  final double overflow = value < min ? min - value : value - max;
  final double banded =
      (1 - (1 / ((overflow * factor / dimension) + 1))) * dimension;
  return value < min ? min - banded : max + banded;
}

/// Picks the snap fraction to settle on from position and fling velocity.
///
/// Positive [velocity] means the sheet is expanding (finger moving up).
double nearestSnap({
  required double value,
  required List<double> snaps,
  double velocity = 0,
  double velocityThreshold = 1.2,
}) {
  assert(snaps.isNotEmpty);
  final List<double> sorted = List<double>.of(snaps)..sort();

  if (velocity.abs() >= velocityThreshold) {
    if (velocity > 0) {
      for (final double snap in sorted) {
        if (snap > value + 0.001) {
          return snap;
        }
      }
      return sorted.last;
    }
    for (final double snap in sorted.reversed) {
      if (snap < value - 0.001) {
        return snap;
      }
    }
    return sorted.first;
  }

  double best = sorted.first;
  double bestDistance = (value - best).abs();
  for (final double snap in sorted.skip(1)) {
    final double distance = (value - snap).abs();
    if (distance < bestDistance) {
      best = snap;
      bestDistance = distance;
    }
  }
  return best;
}

/// Linearly maps [t] through an ease-out curve for background dimming/scale.
double sheetBackdropProgress({
  required double extent,
  required double minSnap,
  required double maxSnap,
}) {
  if (maxSnap <= minSnap) {
    return 1;
  }
  return ((extent - minSnap) / (maxSnap - minSnap)).clamp(0.0, 1.0);
}

/// Soft scale for a backdrop that shrinks as the sheet rises.
double sheetBackdropScale({required double progress, double minScale = 0.92}) {
  return minScale + (1 - minScale) * (1 - progress);
}

/// Convenience clamp used by sheet math.
double clamp01(double value) => math.max(0, math.min(1, value));
