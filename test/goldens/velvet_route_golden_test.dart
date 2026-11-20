@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velvet_motion/velvet_motion.dart';

void main() {
  testWidgets('route transition golden frames', (WidgetTester tester) async {
    final AnimationController controller = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 500),
    );
    addTearDown(controller.dispose);

    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    Future<void> pumpAt(double t) async {
      controller.value = t;
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: buildVelvetTransitions(
                  context: context,
                  animation: controller,
                  secondaryAnimation: const AlwaysStoppedAnimation<double>(0),
                  child: const ColoredBox(
                    color: Color(0xFFFFFFFF),
                    child: Center(child: Text('Page')),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();
    }

    await pumpAt(0);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('route_0.png'),
    );

    await pumpAt(0.5);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('route_50.png'),
    );

    await pumpAt(1);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('route_100.png'),
    );
  });
}
