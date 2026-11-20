import 'package:flutter/widgets.dart';

import '../core/spring.dart';
import '../effects/spring_builder.dart';
import '../theme/motion_theme.dart';
import 'press_scale.dart';

/// A card that expands in place to reveal [expanded] content.
///
/// ```dart
/// ExpandableCard(
///   collapsed: OrderSummary(order),
///   expanded: OrderDetails(order),
/// );
/// ```
class ExpandableCard extends StatefulWidget {
  /// Creates an expandable card.
  const ExpandableCard({
    super.key,
    required this.collapsed,
    required this.expanded,
    this.initiallyExpanded = false,
    this.spring,
    this.padding = const EdgeInsets.all(16),
    this.color = const Color(0xFFFFFFFF),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.onChanged,
  });

  /// Always-visible header / summary.
  final Widget collapsed;

  /// Details shown when expanded.
  final Widget expanded;

  /// Whether the card starts expanded.
  final bool initiallyExpanded;

  /// Spring for the expand animation.
  final Spring? spring;

  /// Inner padding.
  final EdgeInsetsGeometry padding;

  /// Card background.
  final Color color;

  /// Corner radius.
  final BorderRadius borderRadius;

  /// Called when expansion changes.
  final ValueChanged<bool>? onChanged;

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  late bool _open = widget.initiallyExpanded;

  void _toggle() {
    setState(() => _open = !_open);
    widget.onChanged?.call(_open);
  }

  @override
  Widget build(BuildContext context) {
    final bool reduce = MotionTheme.reduceMotionOf(context);

    return PressScale(
      onTap: _toggle,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: widget.borderRadius,
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: widget.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              widget.collapsed,
              if (reduce && _open) ...<Widget>[
                const SizedBox(height: 12),
                widget.expanded,
              ] else
                SpringBuilder(
                  value: _open ? 1 : 0,
                  spring: widget.spring ?? Spring.snappy,
                  builder: (BuildContext context, double t, Widget? child) {
                    return ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: t.clamp(0.0, 1.0),
                        child: Opacity(
                          opacity: t.clamp(0.0, 1.0),
                          child: Padding(
                            padding: EdgeInsets.only(top: 12 * t),
                            child: child,
                          ),
                        ),
                      ),
                    );
                  },
                  child: widget.expanded,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
