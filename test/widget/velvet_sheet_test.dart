import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velvet_motion/velvet_motion.dart';

void main() {
  testWidgets('VelvetSheet renders and settles to a snap', (
    WidgetTester tester,
  ) async {
    final VelvetSheetController controller = VelvetSheetController(
      initialExtent: 0.55,
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VelvetSheet(
            controller: controller,
            snaps: const <double>[0.2, 0.55, 0.92],
            background: const ColoredBox(color: Color(0xFFEEEEEE)),
            builder: (BuildContext context, ScrollController scroll) {
              return ListView(
                controller: scroll,
                children: const <Widget>[
                  ListTile(title: Text('Item 1')),
                  ListTile(title: Text('Item 2')),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Item 1'), findsOneWidget);
    expect(controller.extent, closeTo(0.55, 0.001));

    controller.animateTo(0.92);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(controller.extent, closeTo(0.92, 0.05));
  });

  testWidgets('VelvetSheet jumps under reduce motion', (
    WidgetTester tester,
  ) async {
    final VelvetSheetController controller = VelvetSheetController(
      initialExtent: 0.55,
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MotionTheme(
          data: const MotionThemeData(),
          child: MaterialApp(
            home: Scaffold(
              body: VelvetSheet(
                controller: controller,
                snaps: const <double>[0.2, 0.55, 0.92],
                builder: (BuildContext context, ScrollController scroll) {
                  return const Center(child: Text('Sheet'));
                },
              ),
            ),
          ),
        ),
      ),
    );

    controller.animateTo(0.2);
    await tester.pump();
    expect(controller.extent, closeTo(0.2, 0.001));
  });

  testWidgets('VelvetSheet drag settles upward', (WidgetTester tester) async {
    final VelvetSheetController controller = VelvetSheetController(
      initialExtent: 0.55,
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 800,
            child: VelvetSheet(
              controller: controller,
              snaps: const <double>[0.2, 0.55, 0.92],
              builder: (BuildContext context, ScrollController scroll) {
                return const Center(child: Text('Drag me'));
              },
            ),
          ),
        ),
      ),
    );

    await tester.fling(find.text('Drag me'), const Offset(0, -300), 2000);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(controller.extent, greaterThan(0.55));
  });
}
