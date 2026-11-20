@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velvet_motion/velvet_motion.dart';

void main() {
  Future<void> prepare(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
  }

  testWidgets('press scale golden settled', (WidgetTester tester) async {
    await prepare(tester);
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: PressScale(
              child: SizedBox(
                width: 160,
                height: 80,
                child: ColoredBox(color: Color(0xFF111111)),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('press_settled.png'),
    );
  });

  testWidgets('staggered list golden settled', (WidgetTester tester) async {
    await prepare(tester);
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: StaggeredList(
            shrinkWrap: true,
            children: <Widget>[
              ListTile(title: Text('One')),
              ListTile(title: Text('Two')),
              ListTile(title: Text('Three')),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('stagger_settled.png'),
    );
  });

  testWidgets('rolling number golden settled', (WidgetTester tester) async {
    await prepare(tester);
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: RollingNumber(
              value: 42,
              style: TextStyle(fontSize: 32, color: Color(0xFF111111)),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('rolling_settled.png'),
    );
  });

  testWidgets('morph button golden settled', (WidgetTester tester) async {
    await prepare(tester);
    final MorphButtonController controller = MorphButtonController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 280,
              child: MorphButton(
                controller: controller,
                idle: const Text('Place order'),
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('morph_idle.png'),
    );

    controller.loading();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('morph_loading.png'),
    );
  });
}
