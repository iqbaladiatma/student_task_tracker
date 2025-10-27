import 'package:hive_flutter/hive_flutter.dart';
import '../model/task.dart';
import 'storage_service.dart';

/// Utility class for managing Hive initialization and configuration
class HiveManager {
  static bool _isInitialized = false;

  /// Initialize Hive with Flutter support
  /// Should be called once at app startup
  /// For testing, pass forTesting: true to use Hive.init() instead
  static Future<void> initialize({bool forTesting = false}) async {
    if (_isInitialized) return;

    try {
      // Initialize Hive
      if (forTesting) {
        Hive.init('./test/hive_test_db');
      } else {
        await Hive.initFlutter();
      }

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TaskAdapter());
      }

      _isInitialized = true;
    } catch (e) {
      throw StorageException('Failed to initialize Hive', e);
    }
  }

  /// Check if Hive is initialized
  static bool get isInitialized => _isInitialized;

  /// Close all open boxes and cleanup Hive
  static Future<void> cleanup() async {
    try {
      await Hive.close();
      _isInitialized = false;
    } catch (e) {
      throw StorageException('Failed to cleanup Hive', e);
    }
  }

  /// Delete all data (useful for testing or reset functionality)
  static Future<void> deleteAllData() async {
    try {
      await Hive.deleteFromDisk();
      _isInitialized = false;
    } catch (e) {
      throw StorageException('Failed to delete all data', e);
    }
  }

  /// Get list of all open box names
  static List<String> getOpenBoxNames() {
    // Note: Hive doesn't provide a direct way to get all box names
    // This is a placeholder implementation
    return [];
  }

  /// Check if a specific box is open
  static bool isBoxOpen(String boxName) {
    return Hive.isBoxOpen(boxName);
  }
}
