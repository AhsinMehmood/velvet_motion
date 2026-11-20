import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velvet_motion/velvet_motion.dart';

void main() {
  testWidgets('SpringBuilder animates to a new value', (
    WidgetTester tester,
  ) async {
    double latest = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: SpringBuilder(
          value: 0,
          builder: (BuildContext context, double t, Widget? child) {
            latest = t;
            return const SizedBox();
          },
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SpringBuilder(
          value: 1,
          builder: (BuildContext context, double t, Widget? child) {
            latest = t;
            return const SizedBox();
          },
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(latest, closeTo(1, 0.02));
  });

  testWidgets('SpringBuilder jumps under reduce motion', (
    WidgetTester tester,
  ) async {
    double latest = 0;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: MotionTheme(
            data: const MotionThemeData(),
            child: SpringBuilder(
              value: 0,
              builder: (BuildContext context, double t, Widget? child) {
                latest = t;
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: MotionTheme(
            data: const MotionThemeData(),
            child: SpringBuilder(
              value: 1,
              builder: (BuildContext context, double t, Widget? child) {
                latest = t;
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(latest, 1);
  });

  testWidgets('motion.fadeUp and scaleIn render', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: <Widget>[
            const Text('A').motion.fadeUp(),
            const Text('B').motion.scaleIn(),
          ],
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('motion.pressable handles tap', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: const Text('Tap').motion.pressable(onTap: () => tapped = true),
        ),
      ),
    );

    await tester.tap(find.text('Tap'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tapped, isTrue);
  });
}
