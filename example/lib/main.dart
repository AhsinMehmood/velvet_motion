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
          _DemoTile(
            title: 'Elastic tab bar',
            subtitle: 'Liquid selected pill',
            onTap: () => _open(context, _TabsDemoPage(spring: spring)),
          ),
          _DemoTile(
            title: 'Pull to refresh',
            subtitle: 'Branded spring indicator',
            onTap: () => _open(context, _RefreshDemoPage(spring: spring)),
          ),
          _DemoTile(
            title: 'Hero morph',
            subtitle: 'Shared-element spring morph',
            onTap: () => _open(context, const _MorphHeroDemoPage()),
          ),
          _DemoTile(
            title: 'Swipe deck',
            subtitle: 'Parallax cards with fling',
            onTap: () => _open(context, _SwipeDemoPage(spring: spring)),
          ),
          _DemoTile(
            title: 'Skeleton shimmer',
            subtitle: 'Placeholder → content spring',
            onTap: () => _open(context, _SkeletonDemoPage(spring: spring)),
          ),
          _DemoTile(
            title: 'Expandable card',
            subtitle: 'Grow in place for details',
            onTap: () => _open(context, _ExpandDemoPage(spring: spring)),
          ),
          _DemoTile(
            title: 'Morph icon',
            subtitle: 'Heart fill with spring rotate',
            onTap: () => _open(context, _MorphIconDemoPage(spring: spring)),
          ),
          _DemoTile(
            title: 'Island toast',
            subtitle: 'Dynamic Island-style pill',
            onTap: () => _open(context, const _ToastDemoPage()),
          ),
          _DemoTile(
            title: 'Spring text',
            subtitle: 'Per-character reveal',
            onTap: () => _open(context, _SpringTextDemoPage(spring: spring)),
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

class _TabsDemoPage extends StatefulWidget {
  const _TabsDemoPage({required this.spring});

  final Spring spring;

  @override
  State<_TabsDemoPage> createState() => _TabsDemoPageState();
}

class _TabsDemoPageState extends State<_TabsDemoPage> {
  int _tab = 0;

  static const List<TabItem> _items = <TabItem>[
    TabItem(icon: Icons.home_rounded, label: 'Home'),
    TabItem(icon: Icons.receipt_long_rounded, label: 'Orders'),
    TabItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elastic tab bar')),
      body: Center(
        child: Text(
          _items[_tab].label,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      bottomNavigationBar: ElasticTabBar(
        index: _tab,
        spring: widget.spring,
        stretch: 0.35,
        onChanged: (int i) => setState(() => _tab = i),
        items: _items,
      ),
    );
  }
}

class _RefreshDemoPage extends StatefulWidget {
  const _RefreshDemoPage({required this.spring});

  final Spring spring;

  @override
  State<_RefreshDemoPage> createState() => _RefreshDemoPageState();
}

class _RefreshDemoPageState extends State<_RefreshDemoPage> {
  int _count = 8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pull to refresh')),
      body: SpringRefresh(
        spring: widget.spring,
        triggerDistance: 90,
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 900));
          if (!mounted) {
            return;
          }
          setState(() => _count += 2);
        },
        indicator:
            (BuildContext context, double progress, SpringRefreshState state) {
              return SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  value: state == SpringRefreshState.refreshing
                      ? null
                      : progress,
                  strokeWidth: 3,
                ),
              );
            },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          itemCount: _count,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(title: Text('Row ${index + 1}'));
          },
        ),
      ),
    );
  }
}

class _MorphHeroDemoPage extends StatelessWidget {
  const _MorphHeroDemoPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero morph')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: <Widget>[
          for (int i = 0; i < 4; i++)
            MorphSource(
              tag: 'dish-$i',
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MorphRoute<void>(
                      builder: (_) => _MorphDetailPage(index: i),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ColoredBox(
                    color: Color.lerp(
                      const Color(0xFF222222),
                      const Color(0xFF888888),
                      i / 4,
                    )!,
                    child: Center(
                      child: Text(
                        'Card $i',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MorphDetailPage extends StatelessWidget {
  const _MorphDetailPage({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dish $index')),
      body: ListView(
        children: <Widget>[
          MorphTarget(
            tag: 'dish-$index',
            dismissOnDragDown: true,
            child: AspectRatio(
              aspectRatio: 1,
              child: ColoredBox(
                color: Color.lerp(
                  const Color(0xFF222222),
                  const Color(0xFF888888),
                  index / 4,
                )!,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Drag down to dismiss. Shared morph uses Hero + spring curve.',
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeDemoPage extends StatefulWidget {
  const _SwipeDemoPage({required this.spring});

  final Spring spring;

  @override
  State<_SwipeDemoPage> createState() => _SwipeDemoPageState();
}

class _SwipeDemoPageState extends State<_SwipeDemoPage> {
  final List<String> _items = List<String>.generate(
    6,
    (int i) => 'Offer ${i + 1}',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Swipe deck')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _items.isEmpty
            ? const Center(child: Text('Deck empty'))
            : SwipeDeck<String>(
                items: _items,
                spring: widget.spring,
                onSwipe: (String item, SwipeDirection dir) {
                  setState(() => _items.remove(item));
                },
                builder: (BuildContext context, String item, double drag) {
                  return Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Center(
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _SkeletonDemoPage extends StatefulWidget {
  const _SkeletonDemoPage({required this.spring});

  final Spring spring;

  @override
  State<_SkeletonDemoPage> createState() => _SkeletonDemoPageState();
}

class _SkeletonDemoPageState extends State<_SkeletonDemoPage> {
  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skeleton shimmer')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            SkeletonShimmer(
              loading: _loading,
              spring: widget.spring,
              child: Material(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: const SizedBox(
                  height: 72,
                  width: double.infinity,
                  child: Center(child: Text('Order #1842 ready')),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => setState(() => _loading = !_loading),
              child: Text(_loading ? 'Reveal' : 'Reload'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandDemoPage extends StatelessWidget {
  const _ExpandDemoPage({required this.spring});

  final Spring spring;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expandable card')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ExpandableCard(
          spring: spring,
          color: Theme.of(context).colorScheme.surface,
          collapsed: Text(
            'Margherita · Rs 890',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          expanded: Text(
            'San Marzano tomato, fresh mozzarella, basil. '
            'Ready in ~18 minutes. Tap again to collapse.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}

class _MorphIconDemoPage extends StatefulWidget {
  const _MorphIconDemoPage({required this.spring});

  final Spring spring;

  @override
  State<_MorphIconDemoPage> createState() => _MorphIconDemoPageState();
}

class _MorphIconDemoPageState extends State<_MorphIconDemoPage> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Morph icon')),
      body: Center(
        child: IconButton(
          iconSize: 48,
          onPressed: () => setState(() => _liked = !_liked),
          icon: MorphIcon(
            showAlternate: _liked,
            spring: widget.spring,
            size: 48,
            color: _liked ? Colors.red : Theme.of(context).iconTheme.color,
            icon: const Icon(Icons.favorite_border),
            alternateIcon: const Icon(Icons.favorite),
          ),
        ),
      ),
    );
  }
}

class _ToastDemoPage extends StatelessWidget {
  const _ToastDemoPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Island toast')),
      body: Center(
        child: FilledButton(
          onPressed: () {
            IslandToast.show(
              context,
              message: 'Order placed',
              leading: const Icon(Icons.check_circle, color: Colors.white, size: 18),
            );
          },
          child: const Text('Show toast'),
        ),
      ),
    );
  }
}

class _SpringTextDemoPage extends StatefulWidget {
  const _SpringTextDemoPage({required this.spring});

  final Spring spring;

  @override
  State<_SpringTextDemoPage> createState() => _SpringTextDemoPageState();
}

class _SpringTextDemoPageState extends State<_SpringTextDemoPage> {
  int _nonce = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spring text')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SpringText(
              key: ValueKey<int>(_nonce),
              text: 'Delivered',
              spring: widget.spring,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => setState(() => _nonce++),
              child: const Text('Replay'),
            ),
          ],
        ),
      ),
    );
  }
}
