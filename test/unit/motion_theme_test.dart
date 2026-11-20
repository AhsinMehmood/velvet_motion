import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velvet_motion/velvet_motion.dart';

void main() {
  testWidgets('of falls back to defaults when absent', (
    WidgetTester tester,
  ) async {
    late MotionThemeData data;
    await tester.pumpWidget(
      Builder(
        builder: (BuildContext context) {
          data = MotionTheme.of(context);
          return const SizedBox.shrink();
        },
      ),
    );

    expect(data, MotionThemeData.fallback);
    expect(data.spring, Spring.smooth);
    expect(data.respectReduceMotion, isTrue);
    expect(data.haptics, isTrue);
  });

  testWidgets('of returns the nearest theme data', (WidgetTester tester) async {
    late MotionThemeData data;
    await tester.pumpWidget(
      MotionTheme(
        data: const MotionThemeData(spring: Spring.bouncy, haptics: false),
        child: Builder(
          builder: (BuildContext context) {
            data = MotionTheme.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(data.spring, Spring.bouncy);
    expect(data.haptics, isFalse);
  });

  testWidgets('reduceMotionOf is false when theme ignores it', (
    WidgetTester tester,
  ) async {
    late bool reduce;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MotionTheme(
          data: const MotionThemeData(respectReduceMotion: false),
          child: Builder(
            builder: (BuildContext context) {
              reduce = MotionTheme.reduceMotionOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(reduce, isFalse);
  });

  testWidgets('reduceMotionOf is true when theme and platform agree', (
    WidgetTester tester,
  ) async {
    late bool reduce;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MotionTheme(
          data: const MotionThemeData(),
          child: Builder(
            builder: (BuildContext context) {
              reduce = MotionTheme.reduceMotionOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(reduce, isTrue);
  });

  testWidgets('reduceMotionOf is false when platform allows motion', (
    WidgetTester tester,
  ) async {
    late bool reduce;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(),
        child: MotionTheme(
          data: const MotionThemeData(),
          child: Builder(
            builder: (BuildContext context) {
              reduce = MotionTheme.reduceMotionOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(reduce, isFalse);
  });
}
