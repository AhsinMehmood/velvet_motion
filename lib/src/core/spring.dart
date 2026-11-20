import 'package:flutter/physics.dart';

/// A spring preset modelled after SwiftUI's duration-and-bounce springs.
///
/// Use the built-in presets for common feels, or construct a custom spring.
///
/// ```dart
/// final spring = Spring.snappy;
/// final description = spring.description;
/// ```
class Spring {
  /// Creates a spring with a perceptual [duration] and [bounce].
  ///
  /// [bounce] is typically in `-1..1`. `0` is critically damped; positive
  /// values overshoot; negative values feel resistive.
  const Spring({
    this.duration = const Duration(milliseconds: 500),
    this.bounce = 0,
  });

  /// Critically damped spring with a half-second feel.
  static const Spring smooth = Spring();

  /// Slight overshoot for snappy UI feedback.
  static const Spring snappy = Spring(bounce: 0.15);

  /// Playful spring with visible bounce.
  static const Spring bouncy = Spring(bounce: 0.3);

  /// Short, lightly bouncy spring for finger-driven interactions.
  static const Spring interactive = Spring(
    duration: Duration(milliseconds: 150),
    bounce: 0.14,
  );

  /// Perceptual duration of the spring motion.
  final Duration duration;

  /// Bounce amount (`0` = no overshoot, `0.3` = playful).
  final double bounce;

  /// Flutter [SpringDescription] for simulations and spring animations.
  SpringDescription get description => SpringDescription.withDurationAndBounce(
    duration: duration,
    bounce: bounce,
  );

  /// Returns a copy with the given fields replaced.
  Spring copyWith({Duration? duration, double? bounce}) {
    return Spring(
      duration: duration ?? this.duration,
      bounce: bounce ?? this.bounce,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Spring &&
        other.duration == duration &&
        other.bounce == bounce;
  }

  @override
  int get hashCode => Object.hash(duration, bounce);

  @override
  String toString() => 'Spring(duration: $duration, bounce: $bounce)';
}
