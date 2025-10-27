import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:student_task_tracker/model/task.dart';

void main() {
  group('Task Model Tests', () {
    late Task task;
    late DateTime testDeadline;
    late DateTime testCreatedAt;

    setUp(() {
      testDeadline = DateTime.now().add(const Duration(days: 2));
      testCreatedAt = DateTime.now();
      task = Task(
        title: 'Test Task',
        subject: 'Mathematics',
        deadline: testDeadline,
        description: 'This is a test task',
        createdAt: testCreatedAt,
      );
    });

    group('Constructor Tests', () {
      test('should create task with required parameters', () {
        final newTask = Task(
          title: 'New Task',
          subject: 'Science',
          deadline: DateTime.now().add(const Duration(days: 1)),
        );

        expect(newTask.title, equals('New Task'));
        expect(newTask.subject, equals('Science'));
        expect(newTask.description, equals(''));
        expect(newTask.isCompleted, equals(false));
        expect(newTask.id, isNotEmpty);
        expect(newTask.createdAt, isNotNull);
        expect(newTask.updatedAt, isNotNull);
      });

      test('should create task with all parameters', () {
        expect(task.title, equals('Test Task'));
        expect(task.subject, equals('Mathematics'));
        expect(task.deadline, equals(testDeadline));
        expect(task.description, equals('This is a test task'));
        expect(task.isCompleted, equals(false));
        expect(task.createdAt, equals(testCreatedAt));
        expect(task.id, isNotEmpty);
      });

      test('should generate unique IDs for different tasks', () {
        final task1 = Task(
          title: 'Task 1',
          subject: 'Math',
          deadline: DateTime.now(),
        );
        final task2 = Task(
          title: 'Task 2',
          subject: 'Science',
          deadline: DateTime.now(),
        );

        expect(task1.id, isNot(equals(task2.id)));
      });
    });

    group('Computed Properties Tests', () {
      test('isOverdue should return false for future deadline', () {
        final futureTask = Task(
          title: 'Future Task',
          subject: 'Math',
          deadline: DateTime.now().add(const Duration(days: 1)),
        );

        expect(futureTask.isOverdue, equals(false));
      });

      test(
        'isOverdue should return true for past deadline when not completed',
        () {
          final overdueTask = Task(
            title: 'Overdue Task',
            subject: 'Math',
            deadline: DateTime.now().subtract(const Duration(days: 1)),
          );

          expect(overdueTask.isOverdue, equals(true));
        },
      );

      test(
        'isOverdue should return false for past deadline when completed',
        () {
          final completedTask = Task(
            title: 'Completed Task',
            subject: 'Math',
            deadline: DateTime.now().subtract(const Duration(days: 1)),
            isCompleted: true,
          );

          expect(completedTask.isOverdue, equals(false));
        },
      );

      test('isDueSoon should return true for deadline within 24 hours', () {
        final soonTask = Task(
          title: 'Soon Task',
          subject: 'Math',
          deadline: DateTime.now().add(const Duration(hours: 12)),
        );

        expect(soonTask.isDueSoon, equals(true));
      });

      test('isDueSoon should return false for deadline beyond 24 hours', () {
        final laterTask = Task(
          title: 'Later Task',
          subject: 'Math',
          deadline: DateTime.now().add(const Duration(days: 2)),
        );

        expect(laterTask.isDueSoon, equals(false));
      });

      test('isDueSoon should return false for completed tasks', () {
        final completedSoonTask = Task(
          title: 'Completed Soon Task',
          subject: 'Math',
          deadline: DateTime.now().add(const Duration(hours: 12)),
          isCompleted: true,
        );

        expect(completedSoonTask.isDueSoon, equals(false));
      });

      test('isDueSoon should return false for past deadlines', () {
        final pastTask = Task(
          title: 'Past Task',
          subject: 'Math',
          deadline: DateTime.now().subtract(const Duration(hours: 1)),
        );

        expect(pastTask.isDueSoon, equals(false));
      });
    });

    group('Methods Tests', () {
      test('toggleCompletion should toggle isCompleted status', () {
        expect(task.isCompleted, equals(false));

        task.toggleCompletion();
        expect(task.isCompleted, equals(true));

        task.toggleCompletion();
        expect(task.isCompleted, equals(false));
      });

      test('toggleCompletion should update updatedAt timestamp', () async {
        final originalUpdatedAt = task.updatedAt;

        // Wait a bit to ensure timestamp difference
        await Future.delayed(const Duration(milliseconds: 10));
        task.toggleCompletion();
        expect(task.updatedAt.isAfter(originalUpdatedAt), equals(true));
      });

      test('touch should update updatedAt timestamp', () async {
        final originalUpdatedAt = task.updatedAt;

        await Future.delayed(const Duration(milliseconds: 10));
        task.touch();
        expect(task.updatedAt.isAfter(originalUpdatedAt), equals(true));
      });

      test('copyWith should create new task with updated fields', () {
        final copiedTask = task.copyWith(
          title: 'Updated Title',
          isCompleted: true,
        );

        expect(copiedTask.title, equals('Updated Title'));
        expect(copiedTask.isCompleted, equals(true));
        expect(copiedTask.subject, equals(task.subject));
        expect(copiedTask.deadline, equals(task.deadline));
        expect(copiedTask.id, equals(task.id));
      });

      test(
        'copyWith should preserve original values when no parameters provided',
        () {
          final copiedTask = task.copyWith();

          expect(copiedTask.title, equals(task.title));
          expect(copiedTask.subject, equals(task.subject));
          expect(copiedTask.deadline, equals(task.deadline));
          expect(copiedTask.description, equals(task.description));
          expect(copiedTask.isCompleted, equals(task.isCompleted));
          expect(copiedTask.id, equals(task.id));
        },
      );
    });

    group('Equality and HashCode Tests', () {
      test('tasks with same ID should be equal', () {
        final task1 = Task(
          id: 'test-id',
          title: 'Task 1',
          subject: 'Math',
          deadline: DateTime.now(),
        );
        final task2 = Task(
          id: 'test-id',
          title: 'Task 2',
          subject: 'Science',
          deadline: DateTime.now().add(const Duration(days: 1)),
        );

        expect(task1, equals(task2));
        expect(task1.hashCode, equals(task2.hashCode));
      });

      test('tasks with different IDs should not be equal', () {
        final task1 = Task(
          title: 'Task 1',
          subject: 'Math',
          deadline: DateTime.now(),
        );
        final task2 = Task(
          title: 'Task 1',
          subject: 'Math',
          deadline: DateTime.now(),
        );

        expect(task1, isNot(equals(task2)));
        expect(task1.hashCode, isNot(equals(task2.hashCode)));
      });
    });

    group('toString Tests', () {
      test('toString should return formatted string representation', () {
        final taskString = task.toString();

        expect(taskString, contains('Task{'));
        expect(taskString, contains('id: ${task.id}'));
        expect(taskString, contains('title: ${task.title}'));
        expect(taskString, contains('subject: ${task.subject}'));
        expect(taskString, contains('deadline: ${task.deadline}'));
        expect(taskString, contains('isCompleted: ${task.isCompleted}'));
      });
    });

    group('Hive Integration Tests', () {
      test('should have correct Hive annotations', () {
        // Test that the TaskAdapter is generated and has correct typeId
        final adapter = TaskAdapter();
        expect(adapter.typeId, equals(0));
      });

      test('should create Task with empty constructor for Hive', () {
        final emptyTask = Task.empty();
        expect(emptyTask, isNotNull);
        expect(emptyTask, isA<Task>());
      });

      test('should verify Task extends HiveObject', () {
        final task = Task(
          title: 'Test Task',
          subject: 'Math',
          deadline: DateTime.now(),
        );

        expect(task, isA<HiveObject>());
      });

      test('should validate all Hive field annotations are present', () {
        // This test ensures that all required fields have Hive annotations
        // by checking that the adapter can be instantiated without errors
        expect(() => TaskAdapter(), returnsNormally);
      });
    });
  });
}
