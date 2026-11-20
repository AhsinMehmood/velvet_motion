## 1.0.0

Stable API freeze for the 1.x line.

* Physics: `VelocityTracker`, `DecayFling`, `HapticThreshold`, `clampWithRubber`
* `MotionValue.fling` / `MotionValue.animateWith` for friction and custom simulations
* `SkeletonShimmer` — shimmer placeholder that springs into content
* `ExpandableCard` — in-place expand/collapse
* `MorphIcon` — spring cross-fade between icon pairs
* `IslandToast` — Dynamic Island-style notification pill (`show` helper)
* `SpringText` — staggered per-character reveal

## 0.5.0

* `VelvetSheet` — snap points, rubber-banding, velocity fling, backdrop scale
* `ElasticTabBar` — liquid selected pill with icon pop
* `SpringRefresh` — branded pull-to-refresh with progress builder
* `MorphSource` / `MorphTarget` / `MorphRoute` — shared-element morph
* `SwipeDeck` — parallax swipe cards with spring settle
* Gesture helpers: `rubberBand`, `nearestSnap`

## 0.1.1

* Migrate Material and Cupertino imports to `material_ui` and `cupertino_ui` for Flutter 3.50+ static analysis
* Raise SDK floor to Dart `^3.13.0` / Flutter `>=3.47.0`

## 0.1.0

* Spring presets (`smooth`, `snappy`, `bouncy`, `interactive`) and interruptible `MotionValue`
* `MotionTheme` with reduce-motion and haptics defaults
* `SpringBuilder` and `.motion` extensions (`fadeUp`, `scaleIn`, `pressable`)
* Spring route transitions (`VelvetRoute`, `VelvetMotion.pageTransitions`)
* `PressScale` press feedback with haptics
* `StaggeredList` entrance animation
* `RollingNumber` odometer counter
* `MorphButton` idle / loading / success / error morph
* Example gallery app
