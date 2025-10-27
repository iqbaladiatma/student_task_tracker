import 'dart:async';
import 'dart:developer' as developer;

/// Utility class for performance monitoring and optimization
class PerformanceUtils {
  static const bool _isDebugMode = true; // Set to false in production

  /// Measure execution time of a function
  static Future<T> measureAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    if (!_isDebugMode) return await operation();

    final stopwatch = Stopwatch()..start();
    try {
      final result = await operation();
      stopwatch.stop();
      developer.log(
        'Performance: $operationName took ${stopwatch.elapsedMilliseconds}ms',
        name: 'Performance',
      );
      return result;
    } catch (e) {
      stopwatch.stop();
      developer.log(
        'Performance: $operationName failed after ${stopwatch.elapsedMilliseconds}ms',
        name: 'Performance',
        error: e,
      );
      rethrow;
    }
  }

  /// Measure execution time of a synchronous function
  static T measureSync<T>(String operationName, T Function() operation) {
    if (!_isDebugMode) return operation();

    final stopwatch = Stopwatch()..start();
    try {
      final result = operation();
      stopwatch.stop();
      developer.log(
        'Performance: $operationName took ${stopwatch.elapsedMilliseconds}ms',
        name: 'Performance',
      );
      return result;
    } catch (e) {
      stopwatch.stop();
      developer.log(
        'Performance: $operationName failed after ${stopwatch.elapsedMilliseconds}ms',
        name: 'Performance',
        error: e,
      );
      rethrow;
    }
  }

  /// Log memory usage information
  static void logMemoryUsage(String context) {
    if (!_isDebugMode) return;

    developer.log('Memory usage at $context', name: 'Performance');
  }

  /// Debounce utility for performance optimization
  static void debounce(String key, Duration delay, void Function() action) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(delay, action);
  }

  static final Map<String, Timer> _debounceTimers = {};

  /// Clear all debounce timers (useful for cleanup)
  static void clearDebounceTimers() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
  }

  /// Performance constants for the app
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const double listItemExtent = 120.0;
  static const double listCacheExtent = 600.0;

  /// Check if performance monitoring is enabled
  static bool get isPerformanceMonitoringEnabled => _isDebugMode;
}
