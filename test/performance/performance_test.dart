import 'package:flutter_test/flutter_test.dart';
import 'package:student_task_tracker/utils/performance_utils.dart';

void main() {
  group('Performance Utils Tests', () {
    test('should measure sync operation performance', () {
      final result = PerformanceUtils.measureSync('test_operation', () {
        // Simulate some work
        int sum = 0;
        for (int i = 0; i < 1000; i++) {
          sum += i;
        }
        return sum;
      });

      expect(result, equals(499500)); // Sum of 0 to 999
    });

    test('should measure async operation performance', () async {
      final result = await PerformanceUtils.measureAsync(
        'test_async_operation',
        () async {
          // Simulate async work
          await Future.delayed(const Duration(milliseconds: 10));
          return 'completed';
        },
      );

      expect(result, equals('completed'));
    });

    test('should have correct performance constants', () {
      expect(
        PerformanceUtils.searchDebounceDelay,
        equals(const Duration(milliseconds: 300)),
      );
      expect(
        PerformanceUtils.animationDuration,
        equals(const Duration(milliseconds: 200)),
      );
      expect(PerformanceUtils.listItemExtent, equals(120.0));
      expect(PerformanceUtils.listCacheExtent, equals(600.0));
    });

    test('should clear debounce timers', () {
      // Add some timers
      PerformanceUtils.debounce(
        'test1',
        const Duration(milliseconds: 100),
        () {},
      );
      PerformanceUtils.debounce(
        'test2',
        const Duration(milliseconds: 100),
        () {},
      );

      // Clear all timers
      PerformanceUtils.clearDebounceTimers();

      // This should not throw any errors
      expect(() => PerformanceUtils.clearDebounceTimers(), returnsNormally);
    });
  });
}
