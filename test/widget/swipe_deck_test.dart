import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velvet_motion/velvet_motion.dart';

void main() {
  testWidgets('SwipeDeck renders top card and swipes away', (
    WidgetTester tester,
  ) async {
    final List<String> swiped = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 280,
              height: 360,
              child: SwipeDeck<String>(
                items: const <String>['A', 'B', 'C'],
                onSwipe: (String item, SwipeDirection dir) => swiped.add(item),
                builder: (BuildContext context, String item, double drag) {
                  return ColoredBox(
                    color: const Color(0xFF111111),
                    child: Center(
                      child: Text(
                        item,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    await tester.fling(find.text('A'), const Offset(400, 0), 2000);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(swiped, contains('A'));
    expect(find.text('B'), findsOneWidget);
  });
}
