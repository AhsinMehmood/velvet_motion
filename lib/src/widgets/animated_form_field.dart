import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../core/spring.dart';
import '../effects/spring_builder.dart';
import '../theme/motion_theme.dart';
import 'morph_icon.dart';

/// Visual validation state for [AnimatedFormField].
enum FormFieldStatus {
  /// Neutral / editing.
  idle,

  /// Validation failed — field shakes.
  error,

  /// Validation passed — success tick.
  success,
}

/// A text field with floating label, focus glow, shake, and success tick.
///
/// ```dart
/// final field = GlobalKey<AnimatedFormFieldState>();
///
/// AnimatedFormField(
///   key: field,
///   label: 'Email',
///   onChanged: (v) => email = v,
/// );
///
/// field.currentState?.shake();
/// field.currentState?.succeed();
/// ```
class AnimatedFormField extends StatefulWidget {
  /// Creates an animated form field.
  const AnimatedFormField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.status = FormFieldStatus.idle,
    this.spring,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.fillColor = const Color(0xFFF4F4F4),
    this.focusColor = const Color(0xFF111111),
    this.errorColor = const Color(0xFFD32F2F),
    this.successColor = const Color(0xFF2E7D32),
  });

  /// Floating label text.
  final String label;

  /// Optional external controller.
  final TextEditingController? controller;

  /// Optional external focus node.
  final FocusNode? focusNode;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits.
  final ValueChanged<String>? onSubmitted;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Whether to obscure input.
  final bool obscureText;

  /// Whether the field accepts input.
  final bool enabled;

  /// External status; also controllable via [AnimatedFormFieldState].
  final FormFieldStatus status;

  /// Spring for label / glow / shake.
  final Spring? spring;

  /// Field corner radius.
  final BorderRadius borderRadius;

  /// Idle fill color.
  final Color fillColor;

  /// Focus border / glow color.
  final Color focusColor;

  /// Error accent.
  final Color errorColor;

  /// Success accent.
  final Color successColor;

  @override
  State<AnimatedFormField> createState() => AnimatedFormFieldState();
}

/// State for [AnimatedFormField], exposing [shake] / [succeed] / [reset].
class AnimatedFormFieldState extends State<AnimatedFormField> {
  late TextEditingController _controller;
  late FocusNode _focus;
  late bool _ownsController;
  late bool _ownsFocus;
  FormFieldStatus _status = FormFieldStatus.idle;
  int _shakeNonce = 0;
  bool _hasFocus = false;

  /// Current validation status.
  FormFieldStatus get status => _status;

  /// Current text.
  String get text => _controller.text;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _ownsFocus = widget.focusNode == null;
    _controller = widget.controller ?? TextEditingController();
    _focus = widget.focusNode ?? FocusNode();
    _status = widget.status;
    _focus.addListener(_onFocus);
    _controller.addListener(_onText);
  }

  @override
  void didUpdateWidget(AnimatedFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status != oldWidget.status) {
      _status = widget.status;
      if (_status == FormFieldStatus.error) {
        _triggerShake();
      }
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _controller.removeListener(_onText);
    if (_ownsFocus) {
      _focus.dispose();
    }
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onFocus() {
    setState(() => _hasFocus = _focus.hasFocus);
    if (_hasFocus && _status == FormFieldStatus.error) {
      setState(() => _status = FormFieldStatus.idle);
    }
  }

  void _onText() {
    setState(() {});
    widget.onChanged?.call(_controller.text);
  }

  void _triggerShake() {
    setState(() => _shakeNonce++);
    if (MotionTheme.of(context).haptics) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Triggers the validation shake animation.
  void shake() {
    setState(() => _status = FormFieldStatus.error);
    _triggerShake();
  }

  /// Marks the field as successful.
  void succeed() {
    setState(() => _status = FormFieldStatus.success);
    if (MotionTheme.of(context).haptics) {
      HapticFeedback.lightImpact();
    }
  }

  /// Clears error / success back to idle.
  void reset() => setState(() => _status = FormFieldStatus.idle);

  @override
  Widget build(BuildContext context) {
    final bool reduce = MotionTheme.reduceMotionOf(context);
    final bool floated = _hasFocus || _controller.text.isNotEmpty;
    final Color accent = switch (_status) {
      FormFieldStatus.error => widget.errorColor,
      FormFieldStatus.success => widget.successColor,
      FormFieldStatus.idle =>
        _hasFocus ? widget.focusColor : const Color(0xFF9E9E9E),
    };

    final Widget trailing = switch (_status) {
      FormFieldStatus.success => MorphIcon(
          showAlternate: true,
          size: 22,
          color: widget.successColor,
          spring: widget.spring ?? Spring.snappy,
          icon: Icon(Icons.circle_outlined, color: accent.withValues(alpha: 0)),
          alternateIcon: Icon(
            Icons.check_circle_rounded,
            color: widget.successColor,
          ),
        ),
      FormFieldStatus.error => Icon(
          Icons.error_outline_rounded,
          color: widget.errorColor,
          size: 22,
        ),
      FormFieldStatus.idle => const SizedBox(width: 22, height: 22),
    };

    final Widget field = DecoratedBox(
      decoration: BoxDecoration(
        color: widget.fillColor,
        borderRadius: widget.borderRadius,
        border: Border.all(
          color: accent.withValues(
            alpha: _hasFocus || _status != FormFieldStatus.idle ? 1 : 0.35,
          ),
          width: _hasFocus ? 1.6 : 1,
        ),
        boxShadow: _hasFocus && !reduce
            ? <BoxShadow>[
                BoxShadow(
                  color: accent.withValues(alpha: 0.18),
                  blurRadius: 16,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SpringBuilder(
                    value: floated ? 1 : 0,
                    spring: widget.spring ?? Spring.snappy,
                    builder: (BuildContext context, double t, Widget? child) {
                      return Opacity(
                        opacity: 0.5 + t * 0.5,
                        child: Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: 16 - t * 4,
                            fontWeight: FontWeight.w500,
                            color: accent,
                            height: 1.1,
                          ),
                        ),
                      );
                    },
                  ),
                  TextField(
                    controller: _controller,
                    focusNode: _focus,
                    enabled: widget.enabled,
                    obscureText: widget.obscureText,
                    keyboardType: widget.keyboardType,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    cursorColor: accent,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111111),
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(top: 2, bottom: 4),
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );

    if (reduce) {
      return field;
    }

    return SpringBuilder(
      key: ValueKey<int>(_shakeNonce),
      value: _status == FormFieldStatus.error && _shakeNonce > 0 ? 1 : 0,
      spring: widget.spring ?? Spring.bouncy,
      builder: (BuildContext context, double t, Widget? child) {
        final double shake = t <= 0 || t >= 1
            ? 0
            : math.sin(t * math.pi * 6) * (1 - t) * 8;
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: field,
    );
  }
}
