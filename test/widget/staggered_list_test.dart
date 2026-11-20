import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velvet_motion/velvet_motion.dart';

void main() {
  testWidgets('StaggeredList renders and settles', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StaggeredList(
            shrinkWrap: true,
            children: <Widget>[Text('One'), Text('Two'), Text('Three')],
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('One'), findsOneWidget);
    expect(find.text('Three'), findsOneWidget);
  });

  testWidgets('StaggeredList is instant under reduce motion', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MotionTheme(
          data: MotionThemeData(),
          child: MaterialApp(
            home: Scaffold(
              body: StaggeredList(
                shrinkWrap: true,
                children: <Widget>[Text('A'), Text('B')],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('A'), findsOneWidget);
  });
}
