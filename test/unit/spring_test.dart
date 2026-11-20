import 'package:flutter/physics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velvet_motion/velvet_motion.dart';

void main() {
  group('Spring', () {
    test('presets map to expected duration and bounce', () {
      expect(Spring.smooth.duration, const Duration(milliseconds: 500));
      expect(Spring.smooth.bounce, 0);

      expect(Spring.snappy.bounce, 0.15);
      expect(Spring.bouncy.bounce, 0.3);

      expect(Spring.interactive.duration, const Duration(milliseconds: 150));
      expect(Spring.interactive.bounce, 0.14);
    });

    test('description matches SpringDescription.withDurationAndBounce', () {
      const Spring spring = Spring(
        duration: Duration(milliseconds: 400),
        bounce: 0.2,
      );
      final SpringDescription expected =
          SpringDescription.withDurationAndBounce(
            duration: spring.duration,
            bounce: spring.bounce,
          );

      expect(spring.description.mass, expected.mass);
      expect(spring.description.stiffness, expected.stiffness);
      expect(spring.description.damping, expected.damping);
    });

    test('copyWith, equality and toString', () {
      const Spring base = Spring.snappy;
      final Spring copy = base.copyWith(
        duration: const Duration(milliseconds: 200),
      );

      expect(copy.duration, const Duration(milliseconds: 200));
      expect(copy.bounce, base.bounce);
      expect(base, equals(const Spring(bounce: 0.15)));
      expect(base.hashCode, const Spring(bounce: 0.15).hashCode);
      expect(base.toString(), contains('bounce: 0.15'));
    });
  });
}
