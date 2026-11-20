import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../core/motion_value.dart';
import '../core/spring.dart';
import '../theme/motion_theme.dart';

/// Swipe direction for [SwipeDeck.onSwipe].
enum SwipeDirection {
  /// Swiped to the left.
  left,

  /// Swiped to the right.
  right,
}

/// Builds a deck card with the current drag progress `-1..1`.
typedef SwipeDeckItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  double drag,
);

/// A parallax swipe card deck with spring physics.
///
/// ```dart
/// SwipeDeck<Offer>(
///   items: offers,
///   parallax: 0.12,
///   maxTilt: 0.18,
///   onSwipe: (offer, dir) => dir == SwipeDirection.right ? save(offer) : null,
///   builder: (context, offer, drag) => OfferCard(offer, drag: drag),
/// );
/// ```
class SwipeDeck<T> extends StatefulWidget {
  /// Creates a swipe deck.
  const SwipeDeck({
    super.key,
    required this.items,
    required this.builder,
    this.onSwipe,
    this.parallax = 0.12,
    this.maxTilt = 0.18,
    this.threshold = 0.35,
    this.spring,
  });

  /// Cards in the deck (first item is on top).
  final List<T> items;

  /// Builds each card.
  final SwipeDeckItemBuilder<T> builder;

  /// Called when a card is flung away.
  final void Function(T item, SwipeDirection direction)? onSwipe;

  /// How much back cards shift with the top drag.
  final double parallax;

  /// Max tilt in radians.
  final double maxTilt;

  /// Drag progress that commits a swipe (`0..1` of half-width).
  final double threshold;

  /// Spring for settle / advance.
  final Spring? spring;

  @override
  State<SwipeDeck<T>> createState() => _SwipeDeckState<T>();
}

class _SwipeDeckState<T> extends State<SwipeDeck<T>>
    with TickerProviderStateMixin {
  late final MotionValue _drag;
  late List<T> _items;
  bool _flying = false;

  @override
  void initState() {
    super.initState();
    _items = List<T>.of(widget.items);
    _drag = MotionValue(0, vsync: this, spring: widget.spring ?? Spring.snappy);
    _drag.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(SwipeDeck<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _items = List<T>.of(widget.items);
      _drag.set(0);
    }
    if (widget.spring != null) {
      _drag.spring = widget.spring!;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _drag.spring = widget.spring ?? Spring.snappy;
  }

  Future<void> _commit(SwipeDirection direction, double width) async {
    if (_flying || _items.isEmpty) {
      return;
    }
    _flying = true;
    final T item = _items.first;
    final double target = direction == SwipeDirection.right
        ? width * 1.4
        : -width * 1.4;
    if (MotionTheme.reduceMotionOf(context)) {
      _drag.set(target);
    } else {
      await _drag.animateTo(target);
    }
    widget.onSwipe?.call(item, direction);
    if (!mounted) {
      return;
    }
    setState(() {
      _items.removeAt(0);
      _drag.set(0);
      _flying = false;
    });
  }

  void _onDragUpdate(DragUpdateDetails details, double width) {
    if (_flying || _items.isEmpty || width <= 0) {
      return;
    }
    _drag.set(_drag.value + details.delta.dx);
  }

  void _onDragEnd(DragEndDetails details, double width) {
    if (_flying || _items.isEmpty || width <= 0) {
      return;
    }
    final double progress = _drag.value / (width * 0.5);
    final double velocity = details.velocity.pixelsPerSecond.dx;
    final bool goRight = progress > widget.threshold || velocity > 900;
    final bool goLeft = progress < -widget.threshold || velocity < -900;
    if (goRight) {
      _commit(SwipeDirection.right, width);
    } else if (goLeft) {
      _commit(SwipeDirection.left, width);
    } else if (MotionTheme.reduceMotionOf(context)) {
      _drag.set(0);
    } else {
      _drag.release(velocity: velocity, to: 0);
    }
  }

  @override
  void dispose() {
    _drag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double drag = _drag.value;
        final double progress = width == 0 ? 0 : (drag / (width * 0.5));
        final double tilt = progress.clamp(-1.0, 1.0) * widget.maxTilt;

        final int visible = math.min(3, _items.length);
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            for (int i = visible - 1; i >= 0; i--)
              _DeckCard(
                depth: i,
                drag: i == 0 ? drag : drag * widget.parallax * (1 / (i + 1)),
                tilt: i == 0 ? tilt : 0,
                onUpdate: i == 0
                    ? (DragUpdateDetails d) => _onDragUpdate(d, width)
                    : null,
                onEnd: i == 0
                    ? (DragEndDetails d) => _onDragEnd(d, width)
                    : null,
                child: widget.builder(
                  context,
                  _items[i],
                  i == 0 ? progress : 0,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DeckCard extends StatelessWidget {
  const _DeckCard({
    required this.depth,
    required this.drag,
    required this.tilt,
    required this.child,
    this.onUpdate,
    this.onEnd,
  });

  final int depth;
  final double drag;
  final double tilt;
  final Widget child;
  final GestureDragUpdateCallback? onUpdate;
  final GestureDragEndCallback? onEnd;

  @override
  Widget build(BuildContext context) {
    final double scale = 1 - (depth * 0.05);
    final double y = depth * 12.0;

    Widget card = Transform.translate(
      offset: Offset(drag, y),
      child: Transform.rotate(
        angle: tilt,
        child: Transform.scale(scale: scale, child: child),
      ),
    );

    if (onUpdate != null) {
      card = GestureDetector(
        onHorizontalDragUpdate: onUpdate,
        onHorizontalDragEnd: onEnd,
        child: card,
      );
    }
    return card;
  }
}
