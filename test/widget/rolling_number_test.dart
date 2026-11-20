import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velvet_motion/velvet_motion.dart';

void main() {
  testWidgets('RollingNumber shows formatted value', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RollingNumber(
              value: 42,
              format: (double v) => v.round().toString(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('4'), findsWidgets);
    expect(find.text('2'), findsWidgets);
  });

  testWidgets('RollingNumber updates when value changes', (
    WidgetTester tester,
  ) async {
    double value = 10;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              body: Column(
                children: <Widget>[
                  RollingNumber(value: value),
                  TextButton(
                    onPressed: () => setState(() => value = 25),
                    child: const Text('Bump'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Bump'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('2'), findsWidgets);
    expect(find.text('5'), findsWidgets);
  });
}
