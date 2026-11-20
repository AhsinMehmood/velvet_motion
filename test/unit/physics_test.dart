import 'package:flutter_test/flutter_test.dart';
import 'package:velvet_motion/velvet_motion.dart';

void main() {
  group('VelocityTracker', () {
    test('returns 0 with fewer than two samples', () {
      final VelocityTracker tracker = VelocityTracker();
      expect(tracker.velocity, 0);
      tracker.add(time: Duration.zero, position: 0);
      expect(tracker.velocity, 0);
    });

    test('estimates velocity from samples', () {
      final VelocityTracker tracker = VelocityTracker();
      tracker.add(time: Duration.zero, position: 0);
      tracker.add(
        time: const Duration(milliseconds: 100),
        position: 50,
      );
      expect(tracker.velocity, closeTo(500, 0.1));
    });

    test('reset clears samples', () {
      final VelocityTracker tracker = VelocityTracker();
      tracker.add(time: Duration.zero, position: 0);
      tracker.add(time: const Duration(milliseconds: 50), position: 10);
      tracker.reset();
      expect(tracker.velocity, 0);
    });
  });

  group('DecayFling', () {
    test('project moves in the velocity direction', () {
      const DecayFling decay = DecayFling();
      final double end = decay.project(start: 0, velocity: 800);
      expect(end, greaterThan(0));
    });

    test('projectToSnap picks nearest projected snap', () {
      const DecayFling decay = DecayFling();
      final double snap = decay.projectToSnap(
        start: 0.2,
        velocity: 0,
        snaps: const <double>[0, 0.5, 1],
      );
      expect(snap, 0);
    });
  });

  group('HapticThreshold', () {
    test('fires once per crossing', () {
      final HapticThreshold haptic = HapticThreshold(0.5);
      expect(haptic.crossed(0.4), isFalse);
      expect(haptic.crossed(0.6), isTrue);
      expect(haptic.crossed(0.7), isFalse);
      expect(haptic.crossed(0.3), isTrue);
    });
  });

  group('clampWithRubber', () {
    test('hard clamps when rubber is 0', () {
      expect(
        clampWithRubber(value: 2, min: 0, max: 1, rubber: 0),
        1,
      );
    });

    test('soft bands past the edge', () {
      final double banded =
          clampWithRubber(value: 2, min: 0, max: 1, rubber: 0.55);
      expect(banded, greaterThan(1));
      expect(banded, lessThan(2));
    });
  });
}
