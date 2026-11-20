import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velvet_motion/velvet_motion.dart';

void main() {
  testWidgets('animateTo moves toward the target', (WidgetTester tester) async {
    late MotionValue motion;
    await tester.pumpWidget(
      _MotionHarness(onCreated: (MotionValue value) => motion = value),
    );

    final TickerFuture future = motion.animateTo(1);
    expect(motion.isAnimating, isTrue);

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await future;

    expect(motion.value, closeTo(1, 0.01));
    expect(motion.velocity, 0);
  });

  testWidgets('retargeting mid-flight preserves velocity', (
    WidgetTester tester,
  ) async {
    late MotionValue motion;
    await tester.pumpWidget(
      _MotionHarness(
        spring: const Spring(duration: Duration(milliseconds: 800)),
        onCreated: (MotionValue value) => motion = value,
      ),
    );

    motion.animateTo(1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final double velocityBefore = motion.velocity;
    expect(velocityBefore, greaterThan(0));

    motion.animateTo(2);
    expect(motion.velocity, closeTo(velocityBefore, 0.0001));
  });

  testWidgets('set jumps and clears velocity', (WidgetTester tester) async {
    late MotionValue motion;
    await tester.pumpWidget(
      _MotionHarness(onCreated: (MotionValue value) => motion = value),
    );

    motion.animateTo(1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(motion.isAnimating, isTrue);

    motion.set(0.25);
    expect(motion.value, 0.25);
    expect(motion.velocity, 0);
    expect(motion.isAnimating, isFalse);
  });

  testWidgets('release uses the provided velocity', (
    WidgetTester tester,
  ) async {
    late MotionValue motion;
    await tester.pumpWidget(
      _MotionHarness(
        spring: Spring.snappy,
        onCreated: (MotionValue value) => motion = value,
      ),
    );

    motion.release(velocity: 12, to: 1);
    expect(motion.velocity, closeTo(12, 0.0001));
    expect(motion.isAnimating, isTrue);

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(motion.value, closeTo(1, 0.05));
  });

  testWidgets('stop clears velocity without changing value', (
    WidgetTester tester,
  ) async {
    late MotionValue motion;
    await tester.pumpWidget(
      _MotionHarness(onCreated: (MotionValue value) => motion = value),
    );

    motion.animateTo(1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    final double mid = motion.value;

    motion.stop();
    expect(motion.value, mid);
    expect(motion.velocity, 0);
    expect(motion.isAnimating, isFalse);
  });
}

class _MotionHarness extends StatefulWidget {
  const _MotionHarness({required this.onCreated, this.spring = Spring.smooth});

  final ValueChanged<MotionValue> onCreated;
  final Spring spring;

  @override
  State<_MotionHarness> createState() => _MotionHarnessState();
}

class _MotionHarnessState extends State<_MotionHarness>
    with SingleTickerProviderStateMixin {
  late final MotionValue _motion;

  @override
  void initState() {
    super.initState();
    _motion = MotionValue(0, vsync: this, spring: widget.spring);
    widget.onCreated(_motion);
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
