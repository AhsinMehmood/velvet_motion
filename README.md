# Velvet Motion

Premium spring-physics motion for Flutter.

[![pub package](https://img.shields.io/pub/v/velvet_motion.svg)](https://pub.dev/packages/velvet_motion)
[![CI](https://github.com/AhsinMehmood/velvet_motion/actions/workflows/ci.yml/badge.svg)](https://github.com/AhsinMehmood/velvet_motion/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-black.svg)](LICENSE)

Hand-crafted, physics-based motion for Flutter apps. Springs, gestures and premium defaults in one line of code, with no animation files.

## Why Velvet Motion

- **Springs, not durations** — SwiftUI-style presets via `SpringDescription.withDurationAndBounce`
- **Interruptible** — retarget mid-flight and keep velocity
- **Gesture-aware** — follow the finger, then release into a spring
- **Accessible** — honours reduce-motion; haptics can be turned off
- **Tiny footprint** — Flutter SDK plus official `material_ui` / `cupertino_ui`, one import

## Install

```yaml
dependencies:
  velvet_motion: ^0.5.0
```

```dart
import 'package:velvet_motion/velvet_motion.dart';
```

## Quick start

```dart
MaterialApp(
  builder: (context, child) => MotionTheme(
    data: const MotionThemeData(spring: Spring.smooth),
    child: child!,
  ),
  theme: ThemeData(pageTransitionsTheme: VelvetMotion.pageTransitions),
  home: const Home(),
);
```

```dart
Text('Welcome').motion.fadeUp();
Image.asset('hero.png').motion.scaleIn(spring: Spring.bouncy);
Card(child: child).motion.pressable(onTap: open);
```

## Animations

### Spring route transition

<!-- GIF: route transition -->

```dart
Navigator.of(context).push(
  VelvetRoute(
    builder: (_) => const Details(),
    spring: Spring.smooth,
    style: RouteStyle.push,
  ),
);
```

### Press scale + haptic

<!-- GIF: press scale -->

```dart
PressScale(
  onTap: () {},
  scale: 0.96,
  child: const MenuCard(),
);
```

### Staggered list entrance

<!-- GIF: staggered list -->

```dart
StaggeredList(
  interval: const Duration(milliseconds: 40),
  effect: Effect.fadeUp(distance: 12),
  children: tiles,
);
```

### Rolling number

<!-- GIF: rolling number -->

```dart
RollingNumber(
  value: total,
  format: (v) => 'Rs ${v.round()}',
  spring: Spring.snappy,
);
```

### Morphing button

<!-- GIF: morph button -->

```dart
final controller = MorphButtonController();
MorphButton(
  controller: controller,
  idle: const Text('Place order'),
  onPressed: () async {
    controller.loading();
    final ok = await placeOrder();
    ok ? controller.success() : controller.error();
  },
);
```

### Gesture bottom sheet

```dart
VelvetSheet(
  snaps: const [0.2, 0.55, 0.92],
  rubberBand: 0.55,
  scaleBackground: true,
  builder: (context, scroll) => ListView(controller: scroll, children: tiles),
);
```

### Elastic tab bar

```dart
ElasticTabBar(
  index: tab,
  onChanged: (i) => setState(() => tab = i),
  items: const [
    TabItem(icon: Icons.home_rounded, label: 'Home'),
    TabItem(icon: Icons.receipt_long_rounded, label: 'Orders'),
    TabItem(icon: Icons.person_rounded, label: 'Profile'),
  ],
);
```

### Pull to refresh

```dart
SpringRefresh(
  onRefresh: fetchOrders,
  indicator: (context, progress, state) => LogoStroke(progress: progress),
  child: ListView(children: tiles),
);
```

### Hero morph

```dart
MorphSource(tag: 'dish-1', child: DishCard(dish));
// push MorphRoute →
MorphTarget(tag: 'dish-1', dismissOnDragDown: true, child: DishDetails(dish));
```

### Swipe deck

```dart
SwipeDeck<Offer>(
  items: offers,
  onSwipe: (offer, dir) => dir == SwipeDirection.right ? save(offer) : null,
  builder: (context, offer, drag) => OfferCard(offer, drag: drag),
);
```

## Theming and reduce motion

```dart
MotionTheme(
  data: const MotionThemeData(
    spring: Spring.smooth,
    respectReduceMotion: true,
    haptics: true,
  ),
  child: child,
);
```

When `MediaQuery.disableAnimations` is true and the theme respects it, widgets jump or fade instead of springing.

## Roadmap

Each item will be tracked as a GitHub issue. See [open issues](https://github.com/AhsinMehmood/velvet_motion/issues).

**v0.5 (shipped)** — bottom sheet, elastic tabs, pull-to-refresh, hero morph, swipe deck.

**Next** — physics helpers, more widgets, and a stable v1.0 API.

## Contributing

PRs and new animation proposals are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) and the animation proposal issue template.

## License

MIT © 2026 Ahsan Mehmood (MehmoodTech)
