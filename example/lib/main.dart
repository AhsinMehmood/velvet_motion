import 'package:material_ui/material_ui.dart';
import 'package:velvet_motion/velvet_motion.dart';

void main() {
  runApp(const VelvetGalleryApp());
}

/// Example gallery for Velvet Motion.
class VelvetGalleryApp extends StatefulWidget {
  /// Creates the gallery app.
  const VelvetGalleryApp({super.key});

  @override
  State<VelvetGalleryApp> createState() => _VelvetGalleryAppState();
}

class _VelvetGalleryAppState extends State<VelvetGalleryApp> {
  bool _reduceMotion = false;
  bool _dark = false;
  double _durationMs = 500;
  double _bounce = 0.15;

  Spring get _spring => Spring(
    duration: Duration(milliseconds: _durationMs.round()),
    bounce: _bounce,
  );

  @override
  Widget build(BuildContext context) {
    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: _dark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF111111),
        brightness: _dark ? Brightness.dark : Brightness.light,
      ),
      scaffoldBackgroundColor: _dark
          ? const Color(0xFF000000)
          : const Color(0xFFF7F7F7),
      appBarTheme: AppBarTheme(
        backgroundColor: _dark
            ? const Color(0xFF000000)
            : const Color(0xFFF7F7F7),
        foregroundColor: _dark ? Colors.white : Colors.black,
        elevation: 0,
        centerTitle: false,
      ),
      pageTransitionsTheme: VelvetMotion.pageTransitions,
    );

    return MotionTheme(
      data: MotionThemeData(
        spring: _spring,
        respectReduceMotion: true,
        haptics: true,
      ),
      child: MaterialApp(
        title: 'Velvet Motion',
        debugShowCheckedModeBanner: false,
        theme: base,
        builder: (BuildContext context, Widget? child) {
          final MediaQueryData mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(disableAnimations: _reduceMotion),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: _GalleryHome(
          spring: _spring,
          durationMs: _durationMs,
          bounce: _bounce,
          reduceMotion: _reduceMotion,
          dark: _dark,
          onDuration: (double v) => setState(() => _durationMs = v),
          onBounce: (double v) => setState(() => _bounce = v),
          onReduceMotion: (bool v) => setState(() => _reduceMotion = v),
          onDark: (bool v) => setState(() => _dark = v),
        ),
      ),
    );
  }
}

class _GalleryHome extends StatelessWidget {
  const _GalleryHome({
    required this.spring,
    required this.durationMs,
    required this.bounce,
    required this.reduceMotion,
    required this.dark,
    required this.onDuration,
    required this.onBounce,
    required this.onReduceMotion,
    required this.onDark,
  });

  final Spring spring;
  final double durationMs;
  final double bounce;
  final bool reduceMotion;
  final bool dark;
  final ValueChanged<double> onDuration;
  final ValueChanged<double> onBounce;
  final ValueChanged<bool> onReduceMotion;
  final ValueChanged<bool> onDark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Velvet Motion'),
        actions: <Widget>[
          IconButton(
            tooltip: dark ? 'Light' : 'Dark',
            onPressed: () => onDark(!dark),
            icon: Icon(
              dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: <Widget>[
          Text(
            'Premium spring motion',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.6),
          ),
          const SizedBox(height: 8),
          Text(
            'Tune the shared spring, then open a demo.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          _ControlsCard(
            durationMs: durationMs,
            bounce: bounce,
            reduceMotion: reduceMotion,
            onDuration: onDuration,
            onBounce: onBounce,
            onReduceMotion: onReduceMotion,
          ),
          const SizedBox(height: 16),
          _DemoTile(
            title: 'Route transition',
            subtitle: 'Spring push between screens',
            onTap: () {
              Navigator.of(context).push(
                VelvetRoute<void>(
                  spring: spring,
                  builder: (_) => const _RouteDemoPage(),
                ),
              );
            },
          ),
          _DemoTile(
            title: 'Press scale',
            subtitle: 'Haptic tap with overshoot',
            onTap: () => _open(context, const _PressDemoPage()),
          ),
          _DemoTile(
            title: 'Staggered list',
            subtitle: 'Fade-up entrances',
            onTap: () => _open(context, _StaggerDemoPage(spring: spring)),
          ),
          _DemoTile(
            title: 'Rolling number',
            subtitle: 'Odometer price counter',
            onTap: () => _open(context, _RollingDemoPage(spring: spring)),
          ),
          _DemoTile(
            title: 'Morph button',
            subtitle: 'Idle → loading → success',
            onTap: () => _open(context, _MorphDemoPage(spring: spring)),
          ),
          _DemoTile(
            title: 'Bottom sheet',
            subtitle: 'Snaps, fling, rubber-band',
            onTap: () => _open(context, _SheetDemoPage(spring: spring)),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context)
        .push(VelvetRoute<void>(spring: spring, builder: (_) => page));
  }
}

class _ControlsCard extends StatelessWidget {
  const _ControlsCard({
    required this.durationMs,
    required this.bounce,
    required this.reduceMotion,
    required this.onDuration,
    required this.onBounce,
    required this.onReduceMotion,
  });

  final double durationMs;
  final double bounce;
  final bool reduceMotion;
  final ValueChanged<double> onDuration;
  final ValueChanged<double> onBounce;
  final ValueChanged<bool> onReduceMotion;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Duration  ${durationMs.round()} ms'),
            Slider(
              value: durationMs,
              min: 150,
              max: 900,
              onChanged: onDuration,
            ),
            Text('Bounce  ${bounce.toStringAsFixed(2)}'),
            Slider(value: bounce, min: -0.2, max: 0.5, onChanged: onBounce),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reduce motion'),
              value: reduceMotion,
              onChanged: onReduceMotion,
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  const _DemoTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ).motion.pressable(onTap: onTap),
    );
  }
}

class _RouteDemoPage extends StatelessWidget {
  const _RouteDemoPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: const Center(child: Text('Arrived on a spring.')),
    );
  }
}

class _PressDemoPage extends StatelessWidget {
  const _PressDemoPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Press scale')),
      body: Center(
        child: PressScale(
          onTap: () {},
          child: Container(
            width: 220,
            height: 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Press me',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StaggerDemoPage extends StatelessWidget {
  const _StaggerDemoPage({required this.spring});

  final Spring spring;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staggered list')),
      body: StaggeredList(
        spring: spring,
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          for (int i = 1; i <= 12; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                tileColor: Theme.of(context).colorScheme.surface,
                title: Text('Order #$i'),
                subtitle: const Text('Ready for pickup'),
              ),
            ),
        ],
      ),
    );
  }
}

class _RollingDemoPage extends StatefulWidget {
  const _RollingDemoPage({required this.spring});

  final Spring spring;

  @override
  State<_RollingDemoPage> createState() => _RollingDemoPageState();
}

class _RollingDemoPageState extends State<_RollingDemoPage> {
  double _value = 1280;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rolling number')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RollingNumber(
              value: _value,
              spring: widget.spring,
              format: (double v) => 'Rs ${v.round()}',
              style: Theme.of(context).textTheme.displaySmall
                  ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -1),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => setState(() => _value += 137),
              child: const Text('Add to cart'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MorphDemoPage extends StatefulWidget {
  const _MorphDemoPage({required this.spring});

  final Spring spring;

  @override
  State<_MorphDemoPage> createState() => _MorphDemoPageState();
}

class _MorphDemoPageState extends State<_MorphDemoPage> {
  final MorphButtonController _controller = MorphButtonController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Morph button')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            const Spacer(),
            MorphButton(
              controller: _controller,
              spring: widget.spring,
              idle: const Text('Place order'),
              onPressed: () async {
                _controller.loading();
                await Future<void>.delayed(const Duration(milliseconds: 1200));
                if (!mounted) {
                  return;
                }
                _controller.success();
                await Future<void>.delayed(const Duration(milliseconds: 900));
                if (!mounted) {
                  return;
                }
                _controller.reset();
              },
            ),
            const Spacer(),
            TextButton(
              onPressed: () async {
                _controller.loading();
                await Future<void>.delayed(const Duration(milliseconds: 800));
                if (!mounted) {
                  return;
                }
                _controller.error();
                await Future<void>.delayed(const Duration(milliseconds: 900));
                if (!mounted) {
                  return;
                }
                _controller.reset();
              },
              child: const Text('Simulate error'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetDemoPage extends StatefulWidget {
  const _SheetDemoPage({required this.spring});

  final Spring spring;

  @override
  State<_SheetDemoPage> createState() => _SheetDemoPageState();
}

class _SheetDemoPageState extends State<_SheetDemoPage> {
  final VelvetSheetController _sheet = VelvetSheetController(
    initialExtent: 0.55,
  );

  @override
  void dispose() {
    _sheet.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bottom sheet')),
      body: VelvetSheet(
        controller: _sheet,
        spring: widget.spring,
        snaps: const <double>[0.22, 0.55, 0.92],
        scaleBackground: true,
        background: ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(child: Text('Map / page behind the sheet')),
        ),
        builder: (BuildContext context, ScrollController scroll) {
          return ListView.builder(
            controller: scroll,
            itemCount: 20,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text('Stop ${index + 1}'),
                subtitle: const Text('Drag the sheet or fling to snap'),
              );
            },
          );
        },
      ),
    );
  }
}
