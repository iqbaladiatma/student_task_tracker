import 'package:hive_flutter/hive_flutter.dart';
import '../model/task.dart';
import 'storage_service.dart';

/// Hive implementation of StorageService
/// Provides local data persistence using Hive database
class HiveStorageService implements StorageService {
  static const String _boxName = 'tasks';
  Box<Task>? _taskBox;

  /// Get the task box, throw exception if not initialized
  Box<Task> get taskBox {
    if (_taskBox == null || !_taskBox!.isOpen) {
      throw const StorageException(
        'Storage service not initialized. Call initialize() first.',
      );
    }
    return _taskBox!;
  }

  @override
  Future<void> initialize() async {
    try {
      // Initialize Hive if not already done
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TaskAdapter());
      }

      // Open the tasks box
      _taskBox = await Hive.openBox<Task>(_boxName);
    } catch (e) {
      throw StorageException('Failed to initialize storage service', e);
    }
  }

  @override
  Future<List<Task>> getAllTasks() async {
    try {
      final box = taskBox;
      return box.values.toList();
    } catch (e) {
      throw StorageException('Failed to retrieve tasks', e);
    }
  }

  @override
  Future<void> addTask(Task task) async {
    try {
      final box = taskBox;
      await box.put(task.id, task);
    } catch (e) {
      throw StorageException('Failed to add task', e);
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    try {
      final box = taskBox;

      // Check if task exists
      if (!box.containsKey(task.id)) {
        throw StorageException('Task with ID ${task.id} not found');
      }

      // Update the task
      await box.put(task.id, task);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException('Failed to update task', e);
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      final box = taskBox;

      // Check if task exists
      if (!box.containsKey(taskId)) {
        throw StorageException('Task with ID $taskId not found');
      }

      // Delete the task
      await box.delete(taskId);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException('Failed to delete task', e);
    }
  }

  @override
  Future<void> toggleTaskStatus(String taskId) async {
    try {
      final box = taskBox;

      // Get the task
      final task = box.get(taskId);
      if (task == null) {
        throw StorageException('Task with ID $taskId not found');
      }

      // Toggle completion status and update timestamp
      final updatedTask = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        subject: task.subject,
        deadline: task.deadline,
        isCompleted: !task.isCompleted,
        createdAt: task.createdAt,
        updatedAt: DateTime.now(),
      );

      // Save the updated task
      await box.put(taskId, updatedTask);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException('Failed to toggle task status', e);
    }
  }

  @override
  Future<void> close() async {
    try {
      if (_taskBox != null && _taskBox!.isOpen) {
        await _taskBox!.close();
      }
    } catch (e) {
      throw StorageException('Failed to close storage service', e);
    }
  }

  /// Clear all tasks from storage (useful for testing)
  Future<void> clearAllTasks() async {
    try {
      final box = taskBox;
      await box.clear();
    } catch (e) {
      throw StorageException('Failed to clear all tasks', e);
    }
  }

  /// Get task count
  int getTaskCount() {
    try {
      final box = taskBox;
      return box.length;
    } catch (e) {
      throw StorageException('Failed to get task count', e);
    }
  }

  /// Check if a task exists
  bool taskExists(String taskId) {
    try {
      final box = taskBox;
      return box.containsKey(taskId);
    } catch (e) {
      throw StorageException('Failed to check task existence', e);
    }
  }
}
