import 'package:material_ui/material_ui.dart';

import '../core/spring.dart';
import '../effects/spring_builder.dart';
import '../theme/motion_theme.dart';

/// Visual phases for [MorphButton].
enum MorphButtonPhase {
  /// Full-width idle content.
  idle,

  /// Circular spinner.
  loading,

  /// Success check.
  success,

  /// Error shake / mark.
  error,
}

/// Controls the phase of a [MorphButton].
class MorphButtonController extends ChangeNotifier {
  MorphButtonPhase _phase = MorphButtonPhase.idle;

  /// Current phase.
  MorphButtonPhase get phase => _phase;

  /// Enter the loading phase.
  void loading() => _set(MorphButtonPhase.loading);

  /// Enter the success phase.
  void success() => _set(MorphButtonPhase.success);

  /// Enter the error phase.
  void error() => _set(MorphButtonPhase.error);

  /// Return to idle.
  void reset() => _set(MorphButtonPhase.idle);

  void _set(MorphButtonPhase phase) {
    if (_phase == phase) {
      return;
    }
    _phase = phase;
    notifyListeners();
  }
}

/// A button that morphs between idle, loading, success, and error.
///
/// ```dart
/// final controller = MorphButtonController();
/// MorphButton(
///   controller: controller,
///   idle: const Text('Place order'),
///   onPressed: () async {
///     controller.loading();
///     final ok = await placeOrder();
///     ok ? controller.success() : controller.error();
///   },
/// );
/// ```
class MorphButton extends StatefulWidget {
  /// Creates a morphing button.
  const MorphButton({
    super.key,
    required this.controller,
    required this.idle,
    this.onPressed,
    this.spring,
    this.height = 52,
    this.expandedWidth,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Phase controller.
  final MorphButtonController controller;

  /// Idle label / content.
  final Widget idle;

  /// Called when the idle button is pressed.
  final VoidCallback? onPressed;

  /// Spring used for morphing.
  final Spring? spring;

  /// Button height.
  final double height;

  /// Width while expanded; defaults to parent max width.
  final double? expandedWidth;

  /// Background color.
  final Color? backgroundColor;

  /// Foreground color for spinner / icons.
  final Color? foregroundColor;

  @override
  State<MorphButton> createState() => _MorphButtonState();
}

class _MorphButtonState extends State<MorphButton> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onPhase);
  }

  @override
  void didUpdateWidget(MorphButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onPhase);
      widget.controller.addListener(_onPhase);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPhase);
    super.dispose();
  }

  void _onPhase() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color bg = widget.backgroundColor ?? theme.colorScheme.primary;
    final Color fg = widget.foregroundColor ?? theme.colorScheme.onPrimary;
    final MorphButtonPhase phase = widget.controller.phase;
    final bool reduce = MotionTheme.reduceMotionOf(context);
    final bool collapsed = phase != MorphButtonPhase.idle;
    final double progress = collapsed ? 1 : 0;

    Widget content;
    switch (phase) {
      case MorphButtonPhase.idle:
        content = widget.idle;
      case MorphButtonPhase.loading:
        content = SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
        );
      case MorphButtonPhase.success:
        content = Icon(Icons.check_rounded, color: fg, size: 26);
      case MorphButtonPhase.error:
        content = Icon(Icons.close_rounded, color: fg, size: 26);
    }

    final Widget button = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxWidth =
            widget.expandedWidth ??
            (constraints.maxWidth.isFinite ? constraints.maxWidth : 280);
        final double width = reduce
            ? (collapsed ? widget.height : maxWidth)
            : maxWidth;

        final Widget shaped = SpringBuilder(
          value: progress,
          spring: widget.spring ?? Spring.snappy,
          builder: (BuildContext context, double t, Widget? child) {
            final double w = reduce
                ? width
                : maxWidth + (widget.height - maxWidth) * t;
            final double radius = 12 + (widget.height / 2 - 12) * t;
            final double shake = phase == MorphButtonPhase.error
                ? (1 - t).abs() * 0 + (t > 0.2 ? (0.08 * (1 - t) * 20) : 0)
                : 0;
            return Transform.translate(
              offset: Offset(
                phase == MorphButtonPhase.error
                    ? (shake * ((t * 40).floor().isEven ? 1 : -1))
                    : 0,
                0,
              ),
              child: SizedBox(
                width: w.clamp(widget.height, maxWidth),
                height: widget.height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(radius),
                  ),
                  child: Center(child: child),
                ),
              ),
            );
          },
          child: AnimatedSwitcher(
            duration: reduce
                ? Duration.zero
                : const Duration(milliseconds: 180),
            child: KeyedSubtree(
              key: ValueKey<MorphButtonPhase>(phase),
              child: DefaultTextStyle(
                style:
                    theme.textTheme.labelLarge?.copyWith(color: fg) ??
                    TextStyle(color: fg),
                child: IconTheme(
                  data: IconThemeData(color: fg),
                  child: content,
                ),
              ),
            ),
          ),
        );

        return shaped;
      },
    );

    return GestureDetector(
      onTap: phase == MorphButtonPhase.idle ? widget.onPressed : null,
      child: button,
    );
  }
}
