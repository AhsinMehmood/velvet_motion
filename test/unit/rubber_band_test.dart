import 'package:flutter_test/flutter_test.dart';
import 'package:velvet_motion/velvet_motion.dart';

void main() {
  group('rubberBand', () {
    test('passes through values inside the range', () {
      expect(rubberBand(value: 0.5, min: 0.2, max: 0.9, factor: 0.55), 0.5);
    });

    test('resists past the max', () {
      final double banded = rubberBand(
        value: 1.2,
        min: 0.2,
        max: 0.9,
        factor: 0.55,
      );
      expect(banded, greaterThan(0.9));
      expect(banded, lessThan(1.2));
    });

    test('factor 0 clamps hard', () {
      expect(rubberBand(value: 1.4, min: 0.2, max: 0.9, factor: 0), 0.9);
    });
  });

  group('nearestSnap', () {
    const List<double> snaps = <double>[0.2, 0.55, 0.92];

    test('picks closest snap without velocity', () {
      expect(nearestSnap(value: 0.3, snaps: snaps), 0.2);
      expect(nearestSnap(value: 0.5, snaps: snaps), 0.55);
      expect(nearestSnap(value: 0.8, snaps: snaps), 0.92);
    });

    test('flings upward to the next snap', () {
      expect(nearestSnap(value: 0.3, snaps: snaps, velocity: 2), 0.55);
    });

    test('flings downward to the previous snap', () {
      expect(nearestSnap(value: 0.7, snaps: snaps, velocity: -2), 0.55);
    });
  });
}
