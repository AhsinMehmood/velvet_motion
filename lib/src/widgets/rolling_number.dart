import 'package:flutter/widgets.dart';

import '../core/spring.dart';
import '../effects/spring_builder.dart';
import '../theme/motion_theme.dart';

/// Formats a numeric [value] for display in [RollingNumber].
typedef RollingNumberFormatter = String Function(double value);

/// An odometer-style number that rolls digits on a spring.
///
/// ```dart
/// RollingNumber(
///   value: cart.total,
///   format: (v) => 'Rs ${v.toStringAsFixed(0)}',
///   spring: Spring.snappy,
/// );
/// ```
class RollingNumber extends StatelessWidget {
  /// Creates a rolling number display.
  const RollingNumber({
    super.key,
    required this.value,
    this.format,
    this.spring,
    this.style,
  });

  /// The numeric value to display.
  final double value;

  /// Optional formatter; defaults to an integer string.
  final RollingNumberFormatter? format;

  /// Spring used when digits change.
  final Spring? spring;

  /// Text style; tabular figures are preferred.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final TextStyle resolved = (style ?? DefaultTextStyle.of(context).style)
        .copyWith(
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        );
    final String formatted = (format ?? (double v) => v.round().toString())(
      value,
    );

    return AnimatedSize(
      duration: MotionTheme.reduceMotionOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < formatted.length; i++)
            _RollingGlyph(
              key: ValueKey<int>(i),
              glyph: formatted[i],
              style: resolved,
              spring: spring,
            ),
        ],
      ),
    );
  }
}

class _RollingGlyph extends StatelessWidget {
  const _RollingGlyph({
    super.key,
    required this.glyph,
    required this.style,
    this.spring,
  });

  final String glyph;
  final TextStyle style;
  final Spring? spring;

  @override
  Widget build(BuildContext context) {
    final int? digit = int.tryParse(glyph);
    if (digit == null) {
      return Text(glyph, style: style);
    }

    final bool reduce = MotionTheme.reduceMotionOf(context);
    if (reduce) {
      return Text(glyph, style: style);
    }

    return SpringBuilder(
      value: digit.toDouble(),
      spring: spring ?? Spring.snappy,
      builder: (BuildContext context, double t, Widget? child) {
        final double height = (style.fontSize ?? 14) * (style.height ?? 1.2);
        final TextPainter painter = TextPainter(
          text: TextSpan(text: '0', style: style),
        )
          ..textDirection = TextDirection.ltr
          ..layout();
        return SizedBox(
          width: painter.width,
          height: height,
          child: ClipRect(
            child: OverflowBox(
              maxHeight: height * 10,
              alignment: Alignment.topCenter,
              child: Transform.translate(
                offset: Offset(0, -t * height),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (int i = 0; i <= 9; i++)
                      SizedBox(
                        height: height,
                        child: Center(child: Text('$i', style: style)),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
