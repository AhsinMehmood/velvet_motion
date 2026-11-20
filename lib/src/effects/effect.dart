import 'package:flutter/foundation.dart';

/// A reusable entrance or transition effect description.
@immutable
class Effect {
  const Effect._({
    required this.kind,
    this.distance = 12,
    this.beginScale = 0.92,
  });

  /// Fade in while translating up by [distance] logical pixels.
  factory Effect.fadeUp({double distance = 12}) {
    return Effect._(kind: EffectKind.fadeUp, distance: distance);
  }

  /// Fade in while scaling from [beginScale] to `1`.
  factory Effect.scaleIn({double beginScale = 0.92}) {
    return Effect._(kind: EffectKind.scaleIn, beginScale: beginScale);
  }

  /// Which visual transform this effect applies.
  final EffectKind kind;

  /// Travel distance for slide-style effects, in logical pixels.
  final double distance;

  /// Starting scale for scale-in effects.
  final double beginScale;
}

/// Supported [Effect] kinds for v0.1.
enum EffectKind {
  /// Opacity + upward translation.
  fadeUp,

  /// Opacity + scale.
  scaleIn,
}
