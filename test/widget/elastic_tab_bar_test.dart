import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velvet_motion/velvet_motion.dart';

void main() {
  testWidgets('ElasticTabBar switches tabs', (WidgetTester tester) async {
    int index = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return ElasticTabBar(
                index: index,
                onChanged: (int i) => setState(() => index = i),
                items: const <TabItem>[
                  TabItem(icon: Icons.home_rounded, label: 'Home'),
                  TabItem(icon: Icons.receipt_long_rounded, label: 'Orders'),
                  TabItem(icon: Icons.person_rounded, label: 'Profile'),
                ],
              );
            },
          ),
          body: const SizedBox.expand(),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    await tester.tap(find.text('Orders'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(index, 1);
  });
}
