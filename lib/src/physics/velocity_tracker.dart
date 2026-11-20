import 'dart:collection';

/// A timestamped pointer sample for [VelocityTracker].
class VelocitySample {
  /// Creates a sample at [time] with [position] in logical pixels.
  const VelocitySample({required this.time, required this.position});

  /// Sample time.
  final Duration time;

  /// Position along the tracked axis (or primary axis magnitude).
  final double position;
}

/// Smooths recent drag samples into a velocity in units per second.
///
/// ```dart
/// final tracker = VelocityTracker();
/// tracker.add(time: elapsed, position: dx);
/// final v = tracker.velocity;
/// ```
class VelocityTracker {
  /// Creates a tracker that keeps at most [horizon] of recent samples.
  VelocityTracker({this.horizon = const Duration(milliseconds: 100)});

  /// How far back samples are considered.
  final Duration horizon;

  final ListQueue<VelocitySample> _samples = ListQueue<VelocitySample>();

  /// Adds a sample. Call from pointer move handlers.
  void add({required Duration time, required double position}) {
    _samples.addLast(VelocitySample(time: time, position: position));
    _prune(time);
  }

  /// Clears all samples.
  void reset() => _samples.clear();

  /// Estimated velocity in units per second (0 if unknown).
  double get velocity {
    _prune(_samples.isEmpty ? Duration.zero : _samples.last.time);
    if (_samples.length < 2) {
      return 0;
    }
    final VelocitySample newest = _samples.last;
    final VelocitySample oldest = _samples.first;
    final double dt =
        (newest.time - oldest.time).inMicroseconds / Duration.microsecondsPerSecond;
    if (dt <= 0) {
      return 0;
    }
    return (newest.position - oldest.position) / dt;
  }

  void _prune(Duration now) {
    while (_samples.length > 1 &&
        now - _samples.first.time > horizon) {
      _samples.removeFirst();
    }
  }
}
