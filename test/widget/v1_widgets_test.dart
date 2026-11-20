import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velvet_motion/velvet_motion.dart';

void main() {
  testWidgets('SkeletonShimmer reveals child when loading ends', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SkeletonShimmer(
            loading: true,
            child: Text('Loaded'),
          ),
        ),
      ),
    );
    expect(find.text('Loaded'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SkeletonShimmer(
            loading: false,
            child: Text('Loaded'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Loaded'), findsOneWidget);
  });

  testWidgets('ExpandableCard toggles expanded content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExpandableCard(
            collapsed: Text('Summary'),
            expanded: Text('Details'),
          ),
        ),
      ),
    );

    expect(find.text('Summary'), findsOneWidget);
    await tester.tap(find.text('Summary'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Details'), findsOneWidget);
  });

  testWidgets('MorphIcon swaps icons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MorphIcon(
            showAlternate: false,
            icon: Icon(Icons.favorite_border, key: Key('empty')),
            alternateIcon: Icon(Icons.favorite, key: Key('filled')),
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('empty')), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MorphIcon(
            showAlternate: true,
            icon: Icon(Icons.favorite_border, key: Key('empty')),
            alternateIcon: Icon(Icons.favorite, key: Key('filled')),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(const Key('filled')), findsOneWidget);
  });

  testWidgets('IslandToast shows message when visible', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: IslandToast(visible: true, message: 'Order placed'),
        ),
      ),
    );
    expect(find.text('Order placed'), findsOneWidget);
  });

  testWidgets('SpringText renders characters', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SpringText(text: 'Hi'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('H'), findsOneWidget);
    expect(find.text('i'), findsOneWidget);
  });
}
