import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velvet_motion/velvet_motion.dart';

void main() {
  testWidgets('MorphSource to MorphTarget via MorphRoute', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: Center(
                child: MorphSource(
                  tag: 'card',
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MorphRoute<void>(
                          builder: (_) => const Scaffold(
                            body: Center(
                              child: MorphTarget(
                                tag: 'card',
                                child: SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: ColoredBox(color: Color(0xFF222222)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: const SizedBox(
                      width: 80,
                      height: 80,
                      child: ColoredBox(
                        color: Color(0xFF222222),
                        child: Center(child: Text('Open')),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(MorphTarget), findsOneWidget);
  });
}
