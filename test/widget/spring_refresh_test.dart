import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velvet_motion/velvet_motion.dart';

void main() {
  testWidgets('SpringRefresh renders child and indicator builder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SpringRefresh(
            onRefresh: () async {},
            indicator:
                (
                  BuildContext context,
                  double progress,
                  SpringRefreshState state,
                ) {
                  return Text('p=${progress.toStringAsFixed(1)}');
                },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: const <Widget>[
                SizedBox(height: 1200, child: Text('Content')),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Content'), findsOneWidget);
  });
}
