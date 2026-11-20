import 'package:flutter/widgets.dart';

import '../core/motion_value.dart';
import '../core/spring.dart';
import '../gestures/rubber_band.dart';
import '../theme/motion_theme.dart';

/// Controls a [VelvetSheet] extent (visible height as a fraction of the screen).
class VelvetSheetController extends ChangeNotifier {
  /// Creates a sheet controller starting at [initialExtent].
  VelvetSheetController({double initialExtent = 0.55})
    : _extent = initialExtent;

  double _extent;
  VoidCallback? _attachAnimate;
  VoidCallback? _attachJump;

  /// Current sheet extent in `0..1` (fraction of parent height).
  double get extent => _extent;

  /// Animates to [extent] (clamped to the sheet's snap range by the sheet).
  void animateTo(double extent) {
    _extent = extent;
    notifyListeners();
    _attachAnimate?.call();
  }

  /// Jumps to [extent] without animation.
  void jumpTo(double extent) {
    _extent = extent;
    notifyListeners();
    _attachJump?.call();
  }

  void _bind({required VoidCallback onAnimate, required VoidCallback onJump}) {
    _attachAnimate = onAnimate;
    _attachJump = onJump;
  }

  void _unbind() {
    _attachAnimate = null;
    _attachJump = null;
  }

  void _syncFromSheet(double extent) {
    if (_extent == extent) {
      return;
    }
    _extent = extent;
    notifyListeners();
  }
}

/// Signature for building sheet content with a coordinated [ScrollController].
typedef VelvetSheetContentBuilder = Widget Function(
  BuildContext context,
  ScrollController scrollController,
);

/// A gesture-driven bottom sheet with snap points and spring physics.
///
/// ```dart
/// VelvetSheet(
///   snaps: const [0.2, 0.55, 0.92],
///   rubberBand: 0.55,
///   scaleBackground: true,
///   builder: (context, scroll) => ListView(controller: scroll, ...),
/// );
/// ```
class VelvetSheet extends StatefulWidget {
  /// Creates a springy bottom sheet.
  const VelvetSheet({
    super.key,
    required this.builder,
    this.snaps = const <double>[0.2, 0.55, 0.92],
    this.rubberBand = 0.55,
    this.scaleBackground = true,
    this.controller,
    this.spring,
    this.background,
    this.barrierColor = const Color(0x66000000),
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(16)),
    this.minBackdropScale = 0.92,
    this.onExtentChanged,
  });

  /// Builds the sheet body. Use [ScrollController] for nested scrolling.
  final VelvetSheetContentBuilder builder;

  /// Snap extents as fractions of the parent height (`0..1`).
  final List<double> snaps;

  /// Rubber-band softness past the extreme snaps (`0` = hard clamp).
  final double rubberBand;

  /// Whether the [background] scales down as the sheet rises.
  final bool scaleBackground;

  /// Optional external controller.
  final VelvetSheetController? controller;

  /// Spring used when settling to a snap.
  final Spring? spring;

  /// Optional backdrop content under the sheet (e.g. the map / page).
  final Widget? background;

  /// Dim color over [background] as the sheet rises.
  final Color barrierColor;

  /// Sheet corner radius.
  final BorderRadius borderRadius;

  /// Minimum backdrop scale when [scaleBackground] is true.
  final double minBackdropScale;

  /// Called whenever the animated extent changes.
  final ValueChanged<double>? onExtentChanged;

  @override
  State<VelvetSheet> createState() => _VelvetSheetState();
}

class _VelvetSheetState extends State<VelvetSheet>
    with SingleTickerProviderStateMixin {
  late final MotionValue _extent;
  late final ScrollController _scrollController;
  late List<double> _snaps;
  late double _minSnap;
  late double _maxSnap;

  VelvetSheetController? _internalController;
  double _dragStartExtent = 0;
  double _dragAccumulated = 0;

  VelvetSheetController get _controller =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    _prepareSnaps();
    final double initial =
        (widget.controller?.extent ?? _snaps[_snaps.length ~/ 2]).clamp(
          _minSnap,
          _maxSnap,
        );
    _extent = MotionValue(
      initial,
      vsync: this,
      spring: widget.spring ?? Spring.interactive,
    );
    _extent.addListener(_onExtentTick);
    _scrollController = ScrollController();
    _bindController();
  }

  @override
  void didUpdateWidget(VelvetSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._unbind();
      _bindController();
    }
    if (oldWidget.snaps != widget.snaps) {
      _prepareSnaps();
    }
    if (widget.spring != null) {
      _extent.spring = widget.spring!;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _extent.spring = widget.spring ?? Spring.interactive;
  }

  void _prepareSnaps() {
    assert(widget.snaps.isNotEmpty, 'VelvetSheet requires at least one snap');
    _snaps = List<double>.of(widget.snaps)..sort();
    _minSnap = _snaps.first;
    _maxSnap = _snaps.last;
  }

  void _bindController() {
    if (widget.controller == null) {
      _internalController ??= VelvetSheetController(
        initialExtent: _extent.value,
      );
    }
    _controller._bind(
      onAnimate: () => _animateTo(_controller.extent),
      onJump: () => _jumpTo(_controller.extent),
    );
  }

  void _onExtentTick() {
    _controller._syncFromSheet(_extent.value);
    widget.onExtentChanged?.call(_extent.value);
    setState(() {});
  }

  void _animateTo(double target) {
    final double clamped = target.clamp(_minSnap, _maxSnap);
    if (MotionTheme.reduceMotionOf(context)) {
      _jumpTo(clamped);
      return;
    }
    _extent.animateTo(clamped);
  }

  void _jumpTo(double target) {
    _extent.set(target.clamp(_minSnap, _maxSnap));
  }

  void _onDragStart(DragStartDetails details) {
    _dragStartExtent = _extent.value;
    _dragAccumulated = 0;
    _extent.stop();
  }

  void _onDragUpdate(DragUpdateDetails details, double height) {
    if (height <= 0) {
      return;
    }
    // Finger up expands the sheet.
    _dragAccumulated += -(details.primaryDelta ?? 0) / height;
    final double live = rubberBand(
      value: _dragStartExtent + _dragAccumulated,
      min: _minSnap,
      max: _maxSnap,
      factor: widget.rubberBand,
      dimension: 1,
    );
    _extent.set(live);
  }

  void _onDragEnd(DragEndDetails details, double height) {
    if (height <= 0) {
      return;
    }
    // pixels/sec upward (expanding) is negative dy in Flutter coordinates.
    final double pixelsPerSecond = -(details.velocity.pixelsPerSecond.dy);
    final double extentVelocity = pixelsPerSecond / height;
    final double target = nearestSnap(
      value: _extent.value.clamp(_minSnap, _maxSnap),
      snaps: _snaps,
      velocity: extentVelocity,
    );
    if (MotionTheme.reduceMotionOf(context)) {
      _jumpTo(target);
      return;
    }
    _extent.release(velocity: extentVelocity, to: target);
  }

  @override
  void dispose() {
    _controller._unbind();
    _extent
      ..removeListener(_onExtentTick)
      ..dispose();
    _scrollController.dispose();
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double height = constraints.maxHeight;
        final double width = constraints.maxWidth;
        final double extent = _extent.value;
        final double progress = sheetBackdropProgress(
          extent: extent,
          minSnap: _minSnap,
          maxSnap: _maxSnap,
        );
        final double scale = widget.scaleBackground
            ? sheetBackdropScale(
                progress: progress,
                minScale: widget.minBackdropScale,
              )
            : 1;
        final Color barrier =
            Color.lerp(
              const Color(0x00000000),
              widget.barrierColor,
              progress,
            ) ??
            widget.barrierColor;

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (widget.background != null)
              Transform.scale(
                scale: scale,
                alignment: Alignment.topCenter,
                child: widget.background,
              ),
            if (widget.background != null)
              IgnorePointer(child: ColoredBox(color: barrier)),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onVerticalDragStart: _onDragStart,
                onVerticalDragUpdate: (DragUpdateDetails d) =>
                    _onDragUpdate(d, height),
                onVerticalDragEnd: (DragEndDetails d) => _onDragEnd(d, height),
                child: SizedBox(
                  height: (extent * height).clamp(0, height),
                  width: width,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: widget.borderRadius,
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 24,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: widget.borderRadius,
                      child: Column(
                        children: <Widget>[
                          const _SheetHandle(),
                          Expanded(
                            child: widget.builder(context, _scrollController),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 28,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0x33000000),
            borderRadius: BorderRadius.all(Radius.circular(99)),
          ),
          child: SizedBox(width: 36, height: 4),
        ),
      ),
    );
  }
}
