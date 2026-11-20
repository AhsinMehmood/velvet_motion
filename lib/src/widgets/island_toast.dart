import 'package:flutter/widgets.dart';

import '../core/spring.dart';
import '../effects/spring_builder.dart';
import '../theme/motion_theme.dart';

/// A Dynamic-Island style notification pill that springs in from the top.
///
/// Use [IslandToast.show] for a one-shot overlay, or place [IslandToast]
/// in the tree with [visible] / [message] for controlled use.
class IslandToast extends StatelessWidget {
  /// Creates a controlled island toast.
  const IslandToast({
    super.key,
    required this.visible,
    required this.message,
    this.leading,
    this.spring,
    this.backgroundColor = const Color(0xFF111111),
    this.foregroundColor = const Color(0xFFFFFFFF),
  });

  /// Whether the toast is shown.
  final bool visible;

  /// Toast message.
  final String message;

  /// Optional leading widget (icon / avatar).
  final Widget? leading;

  /// Spring for show/hide.
  final Spring? spring;

  /// Pill background.
  final Color backgroundColor;

  /// Text color.
  final Color foregroundColor;

  /// Shows a transient island toast above [context].
  static Future<void> show(
    BuildContext context, {
    required String message,
    Widget? leading,
    Duration duration = const Duration(milliseconds: 2200),
    Spring? spring,
    Color backgroundColor = const Color(0xFF111111),
    Color foregroundColor = const Color(0xFFFFFFFF),
  }) async {
    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }

    late OverlayEntry entry;
    final ValueNotifier<bool> visible = ValueNotifier<bool>(true);

    entry = OverlayEntry(
      builder: (BuildContext context) {
        return Positioned(
          top: MediaQuery.paddingOf(context).top + 8,
          left: 24,
          right: 24,
          child: ValueListenableBuilder<bool>(
            valueListenable: visible,
            builder: (BuildContext context, bool show, Widget? child) {
              return IslandToast(
                visible: show,
                message: message,
                leading: leading,
                spring: spring,
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
              );
            },
          ),
        );
      },
    );

    overlay.insert(entry);
    await Future<void>.delayed(duration);
    visible.value = false;
    await Future<void>.delayed(const Duration(milliseconds: 420));
    entry.remove();
    visible.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduce = MotionTheme.reduceMotionOf(context);
    if (reduce) {
      return visible ? _pill() : const SizedBox.shrink();
    }

    return SpringBuilder(
      value: visible ? 1 : 0,
      spring: spring ?? Spring.bouncy,
      builder: (BuildContext context, double t, Widget? child) {
        final double clamped = t.clamp(0.0, 1.0);
        if (clamped <= 0.001) {
          return const SizedBox.shrink();
        }
        return Opacity(
          opacity: clamped,
          child: Transform.translate(
            offset: Offset(0, (1 - clamped) * -28),
            child: Transform.scale(
              scale: 0.88 + clamped * 0.12,
              child: child,
            ),
          ),
        );
      },
      child: _pill(),
    );
  }

  Widget _pill() {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (leading != null) ...<Widget>[
                leading!,
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
