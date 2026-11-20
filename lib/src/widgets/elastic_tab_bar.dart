import 'package:material_ui/material_ui.dart';

import '../core/spring.dart';
import '../effects/spring_builder.dart';
import '../theme/motion_theme.dart';

/// A single item in an [ElasticTabBar].
@immutable
class TabItem {
  /// Creates a tab item.
  const TabItem({required this.icon, required this.label});

  /// Tab icon.
  final IconData icon;

  /// Tab label.
  final String label;
}

/// An elastic bottom tab bar with a liquid selected pill.
///
/// ```dart
/// ElasticTabBar(
///   index: tab,
///   onChanged: (i) => setState(() => tab = i),
///   stretch: 0.35,
///   items: const [
///     TabItem(icon: Icons.home_rounded, label: 'Home'),
///     TabItem(icon: Icons.receipt_long_rounded, label: 'Orders'),
///     TabItem(icon: Icons.person_rounded, label: 'Profile'),
///   ],
/// );
/// ```
class ElasticTabBar extends StatelessWidget {
  /// Creates an elastic tab bar.
  const ElasticTabBar({
    super.key,
    required this.index,
    required this.onChanged,
    required this.items,
    this.stretch = 0.35,
    this.spring,
    this.height = 64,
    this.backgroundColor,
    this.pillColor,
    this.selectedColor,
    this.unselectedColor,
  });

  /// Currently selected index.
  final int index;

  /// Called when the user selects a tab.
  final ValueChanged<int> onChanged;

  /// Tabs to display.
  final List<TabItem> items;

  /// How far the pill stretches toward the destination (`0..1`).
  final double stretch;

  /// Spring for pill motion and icon pop.
  final Spring? spring;

  /// Bar height.
  final double height;

  /// Bar background color.
  final Color? backgroundColor;

  /// Selected pill color.
  final Color? pillColor;

  /// Selected icon/label color.
  final Color? selectedColor;

  /// Unselected icon/label color.
  final Color? unselectedColor;

  @override
  Widget build(BuildContext context) {
    assert(items.length >= 2, 'ElasticTabBar needs at least 2 items');
    assert(index >= 0 && index < items.length);

    final ThemeData theme = Theme.of(context);
    final Color bg = backgroundColor ?? theme.colorScheme.surface;
    final Color pill = pillColor ?? theme.colorScheme.primaryContainer;
    final Color selected =
        selectedColor ?? theme.colorScheme.onPrimaryContainer;
    final Color unselected =
        unselectedColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.55);
    final Spring effective = spring ?? Spring.snappy;
    final bool reduce = MotionTheme.reduceMotionOf(context);

    return Material(
      color: bg,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: height,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double width = constraints.maxWidth;
              final double slot = width / items.length;

              return SpringBuilder(
                value: index.toDouble(),
                spring: effective,
                builder: (BuildContext context, double t, Widget? child) {
                  final double frac = (t - t.floorToDouble()).clamp(0.0, 1.0);
                  final double stretchWidth = reduce
                      ? 0
                      : slot * stretch * 4 * frac * (1 - frac);
                  final double pillWidth = (slot * 0.76) + stretchWidth;
                  final double center = (t + 0.5) * slot;
                  final double pillLeft = (center - pillWidth / 2).clamp(
                    0.0,
                    width - pillWidth,
                  );

                  return Stack(
                    children: <Widget>[
                      Positioned(
                        left: pillLeft,
                        width: pillWidth,
                        top: 8,
                        bottom: 8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: pill,
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          for (int i = 0; i < items.length; i++)
                            Expanded(
                              child: _TabButton(
                                item: items[i],
                                selected: i == index,
                                progress: (1 - (t - i).abs()).clamp(0.0, 1.0),
                                selectedColor: selected,
                                unselectedColor: unselected,
                                onTap: () => onChanged(i),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.item,
    required this.selected,
    required this.progress,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final TabItem item;
  final bool selected;
  final double progress;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = Color.lerp(unselectedColor, selectedColor, progress)!;
    final double scale = 0.92 + 0.12 * progress;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Transform.scale(
            scale: scale,
            child: Icon(item.icon, color: color, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
