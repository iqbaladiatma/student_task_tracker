import '../model/task.dart';

/// Abstract interface for data storage operations
/// Defines CRUD methods for Task management
abstract class StorageService {
  /// Initialize the storage service
  /// Should be called before any other operations
  Future<void> initialize();

  /// Retrieve all tasks from storage
  /// Returns empty list if no tasks exist
  Future<List<Task>> getAllTasks();

  /// Add a new task to storage
  /// Throws StorageException if operation fails
  Future<void> addTask(Task task);

  /// Update an existing task in storage
  /// Throws StorageException if task not found or operation fails
  Future<void> updateTask(Task task);

  /// Delete a task from storage by ID
  /// Throws StorageException if task not found or operation fails
  Future<void> deleteTask(String taskId);

  /// Toggle the completion status of a task
  /// Throws StorageException if task not found or operation fails
  Future<void> toggleTaskStatus(String taskId);

  /// Close the storage service and cleanup resources
  Future<void> close();
}

/// Custom exception for storage operations
class StorageException implements Exception {
  final String message;
  final dynamic originalError;

  const StorageException(this.message, [this.originalError]);

  @override
  String toString() => 'StorageException: $message';
}
