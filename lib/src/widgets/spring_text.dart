import 'package:flutter/widgets.dart';

import '../core/spring.dart';
import '../effects/spring_builder.dart';
import '../theme/motion_theme.dart';

/// Reveals [text] character-by-character with staggered springs.
///
/// ```dart
/// SpringText(
///   text: 'Delivered',
///   style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
/// );
/// ```
class SpringText extends StatefulWidget {
  /// Creates a spring character reveal.
  const SpringText({
    super.key,
    required this.text,
    this.style,
    this.spring,
    this.stagger = const Duration(milliseconds: 28),
    this.play = true,
    this.textAlign = TextAlign.start,
  });

  /// Text to reveal.
  final String text;

  /// Text style.
  final TextStyle? style;

  /// Spring per character wave.
  final Spring? spring;

  /// Delay between consecutive characters.
  final Duration stagger;

  /// When false, shows the full string immediately.
  final bool play;

  /// Alignment of the row of characters.
  final TextAlign textAlign;

  @override
  State<SpringText> createState() => _SpringTextState();
}

class _SpringTextState extends State<SpringText> {
  double _target = 0;

  @override
  void initState() {
    super.initState();
    if (widget.play) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _target = 1);
        }
      });
    } else {
      _target = 1;
    }
  }

  @override
  void didUpdateWidget(SpringText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.play != widget.play) {
      if (!widget.play) {
        _target = 1;
      } else {
        _target = 0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _target = 1);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool reduce = MotionTheme.reduceMotionOf(context);
    if (reduce || !widget.play || widget.text.isEmpty) {
      return Text(widget.text, style: widget.style, textAlign: widget.textAlign);
    }

    final List<String> chars = widget.text.characters.toList();
    final int total = chars.length;
    final double staggerFraction =
        widget.stagger.inMilliseconds / (total * 40 + 1);

    return SpringBuilder(
      value: _target,
      spring: widget.spring ?? Spring.snappy,
      builder: (BuildContext context, double t, Widget? child) {
        return _CharRow(
          chars: chars,
          style: widget.style,
          textAlign: widget.textAlign,
          progress: t,
          staggerFraction: staggerFraction,
        );
      },
    );
  }
}

class _CharRow extends StatelessWidget {
  const _CharRow({
    required this.chars,
    required this.style,
    required this.textAlign,
    required this.progress,
    required this.staggerFraction,
  });

  final List<String> chars;
  final TextStyle? style;
  final TextAlign textAlign;
  final double progress;
  final double staggerFraction;

  @override
  Widget build(BuildContext context) {
    final MainAxisAlignment align = switch (textAlign) {
      TextAlign.center => MainAxisAlignment.center,
      TextAlign.end || TextAlign.right => MainAxisAlignment.end,
      _ => MainAxisAlignment.start,
    };

    final double span = (1 - staggerFraction.clamp(0.0, 0.9)).clamp(0.05, 1.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: align,
      children: <Widget>[
        for (int i = 0; i < chars.length; i++)
          _Char(
            char: chars[i],
            style: style,
            local: ((progress - i * staggerFraction) / span).clamp(0.0, 1.0),
          ),
      ],
    );
  }
}

class _Char extends StatelessWidget {
  const _Char({
    required this.char,
    required this.style,
    required this.local,
  });

  final String char;
  final TextStyle? style;
  final double local;

  @override
  Widget build(BuildContext context) {
    if (char == ' ') {
      return Text(' ', style: style);
    }
    return Opacity(
      opacity: local,
      child: Transform.translate(
        offset: Offset(0, (1 - local) * 10),
        child: Transform.scale(
          scale: 0.85 + local * 0.15,
          child: Text(char, style: style),
        ),
      ),
    );
  }
}
