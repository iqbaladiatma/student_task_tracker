import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:student_task_tracker/model/task.dart';
import 'package:student_task_tracker/services/storage_service.dart';
import 'package:student_task_tracker/services/hive_storage_service.dart';
import 'package:student_task_tracker/services/hive_manager.dart';

void main() {
  group('HiveStorageService Tests', () {
    late HiveStorageService storageService;
    late Task testTask1;
    late Task testTask2;

    setUpAll(() async {
      await HiveManager.initialize(forTesting: true);
    });

    setUp(() async {
      storageService = HiveStorageService();
      await storageService.initialize();

      testTask1 = Task(
        title: 'Test Task 1',
        subject: 'Mathematics',
        deadline: DateTime.now().add(const Duration(days: 7)),
        description: 'This is a test task',
      );

      testTask2 = Task(
        title: 'Test Task 2',
        subject: 'Science',
        deadline: DateTime.now().add(const Duration(days: 3)),
        description: 'Another test task',
        isCompleted: true,
      );
    });

    tearDown(() async {
      await storageService.clearAllTasks();
      await storageService.close();
    });

    group('CRUD Operations', () {
      test('should add task successfully', () async {
        await storageService.addTask(testTask1);

        final tasks = await storageService.getAllTasks();
        expect(tasks.length, equals(1));
        expect(tasks.first.title, equals(testTask1.title));
      });

      test('should get all tasks', () async {
        await storageService.addTask(testTask1);
        await storageService.addTask(testTask2);

        final tasks = await storageService.getAllTasks();
        expect(tasks.length, equals(2));
      });

      test('should update task', () async {
        await storageService.addTask(testTask1);

        final updatedTask = testTask1.copyWith(title: 'Updated Task');
        await storageService.updateTask(updatedTask);

        final tasks = await storageService.getAllTasks();
        expect(tasks.first.title, equals('Updated Task'));
      });

      test('should delete task', () async {
        await storageService.addTask(testTask1);
        await storageService.deleteTask(testTask1.id);

        final tasks = await storageService.getAllTasks();
        expect(tasks.length, equals(0));
      });

      test('should toggle task status', () async {
        await storageService.addTask(testTask1);

        await storageService.toggleTaskStatus(testTask1.id);

        final tasks = await storageService.getAllTasks();
        expect(tasks.first.isCompleted, isTrue);
      });
    });

    group('Error Handling', () {
      test('should throw exception for non-existent task update', () async {
        final nonExistentTask = Task(
          title: 'Non-existent',
          subject: 'Test',
          deadline: DateTime.now(),
        );

        expect(
          () => storageService.updateTask(nonExistentTask),
          throwsA(isA<StorageException>()),
        );
      });

      test('should throw exception for non-existent task delete', () async {
        expect(
          () => storageService.deleteTask('non-existent-id'),
          throwsA(isA<StorageException>()),
        );
      });

      test('should throw exception for non-existent task toggle', () async {
        expect(
          () => storageService.toggleTaskStatus('non-existent-id'),
          throwsA(isA<StorageException>()),
        );
      });
    });

    group('Utility Methods', () {
      test('should get correct task count', () async {
        expect(storageService.getTaskCount(), equals(0));

        await storageService.addTask(testTask1);
        expect(storageService.getTaskCount(), equals(1));
      });

      test('should check task existence', () async {
        expect(storageService.taskExists(testTask1.id), isFalse);

        await storageService.addTask(testTask1);
        expect(storageService.taskExists(testTask1.id), isTrue);
      });
    });
  });

  group('HiveManager Tests', () {
    test('should initialize successfully', () async {
      await HiveManager.initialize(forTesting: true);
      expect(HiveManager.isInitialized, isTrue);
    });

    test('StorageException should work correctly', () {
      const exception = StorageException('Test error');
      expect(exception.message, equals('Test error'));
      expect(exception.toString(), contains('StorageException'));
    });
  });
}
