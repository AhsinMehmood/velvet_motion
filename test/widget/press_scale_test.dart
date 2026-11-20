import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velvet_motion/velvet_motion.dart';

void main() {
  testWidgets('PressScale tap fires onTap', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: PressScale(
            onTap: () => tapped = true,
            child: const Text('Press'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Press'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('PressScale cancel does not tap', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: PressScale(
            onTap: () => tapped = true,
            child: const SizedBox(width: 80, height: 40, child: Text('Press')),
          ),
        ),
      ),
    );

    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.text('Press')),
    );
    await tester.pump();
    await gesture.moveBy(const Offset(100, 100));
    await gesture.up();
    await tester.pump();
    expect(tapped, isFalse);
  });
}
