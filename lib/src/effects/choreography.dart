import 'package:flutter/widgets.dart';

import '../core/spring.dart';
import '../theme/motion_theme.dart';
import 'effect.dart';
import 'spring_builder.dart';

/// How [Choreography] plays its children.
enum ChoreoMode {
  /// All children spring in together.
  parallel,

  /// Children spring in one after another.
  sequence,

  /// Children spring in with a fixed [Choreography.interval] stagger.
  stagger,
}

/// Plays entrance effects across children as a group.
///
/// ```dart
/// Choreography(
///   mode: ChoreoMode.stagger,
///   interval: const Duration(milliseconds: 70),
///   children: [
///     Logo(),
///     Title(),
///     Subtitle(),
///   ],
/// );
/// ```
class Choreography extends StatefulWidget {
  /// Creates a choreographed entrance.
  const Choreography({
    super.key,
    required this.children,
    this.mode = ChoreoMode.stagger,
    this.interval = const Duration(milliseconds: 60),
    this.spring,
    this.effect,
    this.play = true,
  });

  /// Children to choreograph.
  final List<Widget> children;

  /// Playback mode.
  final ChoreoMode mode;

  /// Delay between items for [ChoreoMode.stagger] / sequence pacing.
  final Duration interval;

  /// Spring for each item.
  final Spring? spring;

  /// Visual effect; defaults to [Effect.fadeUp].
  final Effect? effect;

  /// When false, shows children fully revealed.
  final bool play;

  @override
  State<Choreography> createState() => _ChoreographyState();
}

class _ChoreographyState extends State<Choreography> {
  late List<double> _targets;

  @override
  void initState() {
    super.initState();
    _targets = List<double>.filled(widget.children.length, widget.play ? 0 : 1);
    if (widget.play) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _start());
    }
  }

  @override
  void didUpdateWidget(Choreography oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      _targets = List<double>.filled(widget.children.length, widget.play ? 0 : 1);
    }
    if (widget.play && (!oldWidget.play || oldWidget.children.length != widget.children.length)) {
      _targets = List<double>.filled(widget.children.length, 0);
      WidgetsBinding.instance.addPostFrameCallback((_) => _start());
    } else if (!widget.play) {
      setState(() => _targets = List<double>.filled(widget.children.length, 1));
    }
  }

  Future<void> _start() async {
    if (!mounted) {
      return;
    }
    final bool reduce = MotionTheme.reduceMotionOf(context);
    if (reduce) {
      setState(() => _targets = List<double>.filled(widget.children.length, 1));
      return;
    }

    switch (widget.mode) {
      case ChoreoMode.parallel:
        setState(() => _targets = List<double>.filled(widget.children.length, 1));
      case ChoreoMode.stagger:
      case ChoreoMode.sequence:
        for (int i = 0; i < widget.children.length; i++) {
          if (!mounted) {
            return;
          }
          setState(() => _targets[i] = 1);
          if (i < widget.children.length - 1) {
            await Future<void>.delayed(widget.interval);
          }
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Effect effect = widget.effect ?? Effect.fadeUp();
    final Spring spring = widget.spring ?? MotionTheme.of(context).spring;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < widget.children.length; i++)
          SpringBuilder(
            value: i < _targets.length ? _targets[i] : 1,
            spring: spring,
            builder: (BuildContext context, double t, Widget? child) {
              return _applyEffect(effect, t, child);
            },
            child: widget.children[i],
          ),
      ],
    );
  }

  Widget _applyEffect(Effect effect, double t, Widget? child) {
    final double clamped = t.clamp(0.0, 1.0);
    switch (effect.kind) {
      case EffectKind.fadeUp:
        return Opacity(
          opacity: clamped,
          child: Transform.translate(
            offset: Offset(0, (1 - clamped) * effect.distance),
            child: child,
          ),
        );
      case EffectKind.scaleIn:
        return Opacity(
          opacity: clamped,
          child: Transform.scale(
            scale: effect.beginScale + (1 - effect.beginScale) * clamped,
            child: child,
          ),
        );
    }
  }
}

/// Controllable multi-track progress for custom timelines.
///
/// ```dart
/// final timeline = MotionTimeline({'logo': 0, 'title': 0});
/// timeline.animate('logo', to: 1);
/// await timeline.animate('title', to: 1);
/// ```
class MotionTimeline extends ChangeNotifier {
  /// Creates a timeline with named tracks starting at [initial] values.
  MotionTimeline([Map<String, double>? initial])
      : _values = Map<String, double>.of(initial ?? <String, double>{});

  final Map<String, double> _values;

  /// Current value for [id], or `0` if unknown.
  double operator [](String id) => _values[id] ?? 0;

  /// Sets [id] immediately and notifies.
  void set(String id, double value) {
    if (_values[id] == value) {
      return;
    }
    _values[id] = value;
    notifyListeners();
  }

  /// Marks [ids] as `1` together (parallel cue).
  void parallel(Iterable<String> ids) {
    for (final String id in ids) {
      _values[id] = 1;
    }
    notifyListeners();
  }

  /// Sets tracks to `1` in order with [interval] between them.
  Future<void> sequence(
    Iterable<String> ids, {
    Duration interval = const Duration(milliseconds: 60),
  }) async {
    for (final String id in ids) {
      _values[id] = 1;
      notifyListeners();
      await Future<void>.delayed(interval);
    }
  }

  /// All track ids.
  Iterable<String> get ids => _values.keys;
}
