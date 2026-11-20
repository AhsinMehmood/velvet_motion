import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velvet_motion/velvet_motion.dart';

void main() {
  testWidgets('MorphButton state machine', (WidgetTester tester) async {
    final MorphButtonController controller = MorphButtonController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: MorphButton(
              controller: controller,
              idle: const Text('Place order'),
              onPressed: controller.loading,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Place order'), findsOneWidget);
    await tester.tap(find.text('Place order'));
    await tester.pump();
    expect(controller.phase, MorphButtonPhase.loading);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    controller.success();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    controller.error();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    controller.reset();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Place order'), findsOneWidget);
  });
}
