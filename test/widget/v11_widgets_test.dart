import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velvet_motion/velvet_motion.dart';

void main() {
  testWidgets('AnimatedFormField shakes and succeeds', (
    WidgetTester tester,
  ) async {
    final GlobalKey<AnimatedFormFieldState> key =
        GlobalKey<AnimatedFormFieldState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedFormField(key: key, label: 'Email'),
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    key.currentState!.shake();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(key.currentState!.status, FormFieldStatus.error);

    key.currentState!.succeed();
    await tester.pump();
    expect(key.currentState!.status, FormFieldStatus.success);
  });

  testWidgets('ScrollParallax builds child', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: ScrollParallax(child: Text('Hero')),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 800)),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Hero'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -120));
    await tester.pump();
    expect(find.text('Hero'), findsOneWidget);
  });

  testWidgets('Choreography reveals children', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Choreography(
            mode: ChoreoMode.parallel,
            children: <Widget>[
              Text('A'),
              Text('B'),
              Text('C'),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
  });

  testWidgets('shared-axis route pushes', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      VelvetRoute<void>(
                        style: RouteStyle.sharedAxisX,
                        builder: (_) => const Scaffold(
                          body: Text('Shared'),
                        ),
                      ),
                    );
                  },
                  child: const Text('Go'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Go'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Shared'), findsOneWidget);
  });

  test('parallaxOffset clamps', () {
    expect(parallaxOffset(offset: 10, factor: 0.5, max: 80), 5);
    expect(parallaxOffset(offset: 1000, factor: 0.5, max: 80), 80);
  });

  test('MotionTimeline parallel and set', () {
    final MotionTimeline timeline = MotionTimeline(<String, double>{
      'a': 0,
      'b': 0,
    });
    timeline.parallel(<String>['a', 'b']);
    expect(timeline['a'], 1);
    expect(timeline['b'], 1);
    timeline.set('a', 0.5);
    expect(timeline['a'], 0.5);
  });
}
