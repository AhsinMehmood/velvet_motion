import 'package:flutter_test/flutter_test.dart';
import 'package:velvet_motion_example/main.dart';

void main() {
  testWidgets('gallery loads', (WidgetTester tester) async {
    await tester.pumpWidget(const VelvetGalleryApp());
    await tester.pump();
    expect(find.text('Velvet Motion'), findsOneWidget);
  });
}
