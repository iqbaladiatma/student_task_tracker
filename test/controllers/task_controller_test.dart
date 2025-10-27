import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:student_task_tracker/controllers/task_controller.dart';
import 'package:student_task_tracker/model/task.dart';
import 'package:student_task_tracker/services/storage_service.dart';

import 'task_controller_test.mocks.dart';

// Generate mocks
@GenerateMocks([StorageService])
void main() {
  late TaskController controller;
  late MockStorageService mockStorageService;
  late List<Task> sampleTasks;

  setUp(() {
    // Initialize GetX for testing
    Get.testMode = true;

    mockStorageService = MockStorageService();
    controller = TaskController(mockStorageService);

    // Create sample tasks for testing
    sampleTasks = [
      Task(
        id: '1',
        title: 'Tugas Matematika',
        description: 'Mengerjakan soal aljabar',
        subject: 'Matematika',
        deadline: DateTime.now().add(const Duration(days: 2)),
        isCompleted: false,
      ),
      Task(
        id: '2',
        title: 'Essay Bahasa Indonesia',
        description: 'Menulis essay tentang lingkungan',
        subject: 'Bahasa Indonesia',
        deadline: DateTime.now().add(const Duration(days: 1)),
        isCompleted: true,
      ),
      Task(
        id: '3',
        title: 'Laporan Fisika',
        description: 'Laporan praktikum gerak lurus',
        subject: 'Fisika',
        deadline: DateTime.now().subtract(const Duration(days: 1)),
        isCompleted: false,
      ),
    ];
  });

  tearDown(() {
    Get.reset();
  });

  group('TaskController Initialization', () {
    test('should initialize successfully', () async {
      // Arrange
      when(mockStorageService.initialize()).thenAnswer((_) async {});
      when(
        mockStorageService.getAllTasks(),
      ).thenAnswer((_) async => sampleTasks);

      // Act
      await controller.initialize();

      // Assert
      verify(mockStorageService.initialize()).called(1);
      verify(mockStorageService.getAllTasks()).called(1);
      expect(controller.allTasks.length, equals(3));
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isEmpty);
    });

    test('should handle initialization error', () async {
      // Arrange
      when(mockStorageService.initialize()).thenThrow(Exception('Init failed'));

      // Act
      await controller.initialize();

      // Assert
      expect(controller.isLoading, isFalse);
      expect(
        controller.errorMessage,
        contains('Gagal menginisialisasi aplikasi'),
      );
    });
  });

  group('TaskController CRUD Operations', () {
    setUp(() async {
      when(mockStorageService.initialize()).thenAnswer((_) async {});
      when(
        mockStorageService.getAllTasks(),
      ).thenAnswer((_) async => sampleTasks);
      await controller.initialize();
    });

    test('should add task successfully', () async {
      // Arrange
      final newTask = Task(
        title: 'New Task',
        subject: 'Chemistry',
        deadline: DateTime.now().add(const Duration(days: 3)),
      );
      when(mockStorageService.addTask(any)).thenAnswer((_) async {});

      // Act
      final result = await controller.addTask(newTask);

      // Assert
      expect(result, isTrue);
      expect(controller.allTasks.length, equals(4));
      expect(controller.allTasks.last.title, equals('New Task'));
      verify(mockStorageService.addTask(newTask)).called(1);
    });

    test('should handle add task error', () async {
      // Arrange
      final newTask = Task(
        title: 'New Task',
        subject: 'Chemistry',
        deadline: DateTime.now().add(const Duration(days: 3)),
      );
      when(mockStorageService.addTask(any)).thenThrow(Exception('Add failed'));

      // Act
      final result = await controller.addTask(newTask);

      // Assert
      expect(result, isFalse);
      expect(controller.errorMessage, contains('Gagal menambah tugas'));
      expect(controller.allTasks.length, equals(3)); // Should remain unchanged
    });

    test('should update task successfully', () async {
      // Arrange
      final updatedTask = sampleTasks[0].copyWith(title: 'Updated Title');
      when(mockStorageService.updateTask(any)).thenAnswer((_) async {});

      // Act
      final result = await controller.updateTask(updatedTask);

      // Assert
      expect(result, isTrue);
      expect(controller.allTasks[0].title, equals('Updated Title'));
      verify(mockStorageService.updateTask(updatedTask)).called(1);
    });

    test('should handle update task error', () async {
      // Arrange
      final updatedTask = sampleTasks[0].copyWith(title: 'Updated Title');
      when(
        mockStorageService.updateTask(any),
      ).thenThrow(Exception('Update failed'));

      // Act
      final result = await controller.updateTask(updatedTask);

      // Assert
      expect(result, isFalse);
      expect(controller.errorMessage, contains('Gagal mengupdate tugas'));
    });

    test('should delete task successfully', () async {
      // Arrange
      const taskId = '1';
      when(mockStorageService.deleteTask(taskId)).thenAnswer((_) async {});

      // Act
      final result = await controller.deleteTask(taskId);

      // Assert
      expect(result, isTrue);
      expect(controller.allTasks.length, equals(2));
      expect(controller.allTasks.any((task) => task.id == taskId), isFalse);
      verify(mockStorageService.deleteTask(taskId)).called(1);
    });

    test('should handle delete task error', () async {
      // Arrange
      const taskId = '1';
      when(
        mockStorageService.deleteTask(taskId),
      ).thenThrow(Exception('Delete failed'));

      // Act
      final result = await controller.deleteTask(taskId);

      // Assert
      expect(result, isFalse);
      expect(controller.errorMessage, contains('Gagal menghapus tugas'));
      expect(controller.allTasks.length, equals(3)); // Should remain unchanged
    });

    test('should toggle task status successfully', () async {
      // Arrange
      const taskId = '1';
      final originalTask = sampleTasks[0];
      when(
        mockStorageService.toggleTaskStatus(taskId),
      ).thenAnswer((_) async {});

      // Act
      final result = await controller.toggleTaskStatus(taskId);

      // Assert
      expect(result, isTrue);
      expect(
        controller.allTasks[0].isCompleted,
        equals(!originalTask.isCompleted),
      );
      verify(mockStorageService.toggleTaskStatus(taskId)).called(1);
    });

    test('should handle toggle task status error', () async {
      // Arrange
      const taskId = '1';
      when(
        mockStorageService.toggleTaskStatus(taskId),
      ).thenThrow(Exception('Toggle failed'));

      // Act
      final result = await controller.toggleTaskStatus(taskId);

      // Assert
      expect(result, isFalse);
      expect(controller.errorMessage, contains('Gagal mengubah status tugas'));
    });
  });

  group('TaskController Filter Functionality', () {
    setUp(() async {
      when(mockStorageService.initialize()).thenAnswer((_) async {});
      when(
        mockStorageService.getAllTasks(),
      ).thenAnswer((_) async => sampleTasks);
      await controller.initialize();
    });

    test('should filter all tasks by default', () {
      // Assert
      expect(controller.currentFilter, equals(TaskFilter.all));
      expect(controller.filteredTasks.length, equals(3));
    });

    test('should filter pending tasks', () {
      // Act
      controller.setFilter(TaskFilter.pending);

      // Assert
      expect(controller.currentFilter, equals(TaskFilter.pending));
      expect(controller.filteredTasks.length, equals(2));
      expect(
        controller.filteredTasks.every((task) => !task.isCompleted),
        isTrue,
      );
    });

    test('should filter completed tasks', () {
      // Act
      controller.setFilter(TaskFilter.completed);

      // Assert
      expect(controller.currentFilter, equals(TaskFilter.completed));
      expect(controller.filteredTasks.length, equals(1));
      expect(
        controller.filteredTasks.every((task) => task.isCompleted),
        isTrue,
      );
    });

    test('should filter overdue tasks', () {
      // Act
      controller.setFilter(TaskFilter.overdue);

      // Assert
      expect(controller.currentFilter, equals(TaskFilter.overdue));
      expect(controller.filteredTasks.length, equals(1));
      expect(controller.filteredTasks.every((task) => task.isOverdue), isTrue);
    });
  });

  group('TaskController Search Functionality', () {
    setUp(() async {
      when(mockStorageService.initialize()).thenAnswer((_) async {});
      when(
        mockStorageService.getAllTasks(),
      ).thenAnswer((_) async => sampleTasks);
      await controller.initialize();
    });

    test('should search tasks by title', () {
      // Act
      controller.searchTasks('matematika');

      // Assert
      expect(controller.searchQuery, equals('matematika'));
      expect(controller.filteredTasks.length, equals(1));
      expect(controller.filteredTasks[0].title, contains('Matematika'));
    });

    test('should search tasks by description', () {
      // Act
      controller.searchTasks('essay');

      // Assert
      expect(controller.filteredTasks.length, equals(1));
      expect(controller.filteredTasks[0].description, contains('essay'));
    });

    test('should search tasks by subject', () {
      // Act
      controller.searchTasks('fisika');

      // Assert
      expect(controller.filteredTasks.length, equals(1));
      expect(controller.filteredTasks[0].subject, contains('Fisika'));
    });

    test('should return empty list for non-matching search', () {
      // Act
      controller.searchTasks('nonexistent');

      // Assert
      expect(controller.filteredTasks.length, equals(0));
    });

    test('should clear search and show all tasks', () {
      // Arrange
      controller.searchTasks('matematika');
      expect(controller.filteredTasks.length, equals(1));

      // Act
      controller.clearSearch();

      // Assert
      expect(controller.searchQuery, isEmpty);
      expect(controller.filteredTasks.length, equals(3));
    });

    test('should combine filter and search', () {
      // Act
      controller.setFilter(TaskFilter.pending);
      controller.searchTasks('fisika');

      // Assert
      expect(controller.filteredTasks.length, equals(1));
      expect(controller.filteredTasks[0].subject, equals('Fisika'));
      expect(controller.filteredTasks[0].isCompleted, isFalse);
    });
  });

  group('TaskController Computed Properties', () {
    setUp(() async {
      when(mockStorageService.initialize()).thenAnswer((_) async {});
      when(
        mockStorageService.getAllTasks(),
      ).thenAnswer((_) async => sampleTasks);
      await controller.initialize();
    });

    test('should calculate total tasks correctly', () {
      expect(controller.totalTasks, equals(3));
    });

    test('should calculate completed tasks correctly', () {
      expect(controller.completedTasks, equals(1));
    });

    test('should calculate pending tasks correctly', () {
      expect(controller.pendingTasks, equals(2));
    });

    test('should calculate overdue tasks correctly', () {
      expect(controller.overdueTasks, equals(1));
    });
  });

  group('TaskController Utility Methods', () {
    setUp(() async {
      when(mockStorageService.initialize()).thenAnswer((_) async {});
      when(
        mockStorageService.getAllTasks(),
      ).thenAnswer((_) async => sampleTasks);
      await controller.initialize();
    });

    test('should get task by ID', () {
      // Act
      final task = controller.getTaskById('1');

      // Assert
      expect(task, isNotNull);
      expect(task!.id, equals('1'));
      expect(task.title, equals('Tugas Matematika'));
    });

    test('should return null for non-existent task ID', () {
      // Act
      final task = controller.getTaskById('nonexistent');

      // Assert
      expect(task, isNull);
    });

    test('should get tasks by subject', () {
      // Act
      final mathTasks = controller.getTasksBySubject('Matematika');

      // Assert
      expect(mathTasks.length, equals(1));
      expect(mathTasks[0].subject, equals('Matematika'));
    });

    test('should get unique subjects', () {
      // Act
      final subjects = controller.getUniqueSubjects();

      // Assert
      expect(subjects.length, equals(3));
      expect(
        subjects,
        containsAll(['Matematika', 'Bahasa Indonesia', 'Fisika']),
      );
      expect(
        subjects,
        orderedEquals(['Bahasa Indonesia', 'Fisika', 'Matematika']),
      ); // Should be sorted
    });

    test('should refresh data from storage', () async {
      // Arrange
      when(mockStorageService.getAllTasks()).thenAnswer((_) async => []);

      // Act
      await controller.refresh();

      // Assert
      verify(
        mockStorageService.getAllTasks(),
      ).called(2); // Once in initialize, once in refresh
      expect(controller.allTasks.length, equals(0));
    });

    test('should clear error message', () {
      // Act & Assert
      controller.clearError();
      expect(controller.errorMessage, isEmpty);
    });
  });

  group('TaskController State Management', () {
    test('should manage loading state correctly', () async {
      // Arrange
      when(mockStorageService.initialize()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      when(mockStorageService.getAllTasks()).thenAnswer((_) async => []);

      // Act
      final future = controller.initialize();

      // Assert - should be loading
      expect(controller.isLoading, isTrue);

      await future;

      // Assert - should not be loading after completion
      expect(controller.isLoading, isFalse);
    });

    test('should manage error state correctly', () async {
      // Arrange
      when(mockStorageService.initialize()).thenThrow(Exception('Test error'));

      // Act
      await controller.initialize();

      // Assert
      expect(controller.errorMessage, isNotEmpty);
      expect(
        controller.errorMessage,
        contains('Gagal menginisialisasi aplikasi'),
      );
    });
  });
}
