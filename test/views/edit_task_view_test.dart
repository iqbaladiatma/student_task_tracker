import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:student_task_tracker/controllers/task_controller.dart';
import 'package:student_task_tracker/model/task.dart';
import 'package:student_task_tracker/services/storage_service.dart';
import 'package:student_task_tracker/views/edit_task_view.dart';

// Simple mock implementation for testing
class MockStorageService implements StorageService {
  @override
  Future<void> initialize() async {}

  @override
  Future<List<Task>> getAllTasks() async => [];

  @override
  Future<void> addTask(Task task) async {}

  @override
  Future<void> updateTask(Task task) async {}

  @override
  Future<void> deleteTask(String taskId) async {}

  @override
  Future<void> toggleTaskStatus(String taskId) async {}

  @override
  Future<void> close() async {}
}

void main() {
  group('EditTaskView Widget Tests', () {
    late MockStorageService mockStorageService;
    late TaskController taskController;
    late Task testTask;

    setUp(() {
      mockStorageService = MockStorageService();
      taskController = TaskController(mockStorageService);

      // Create test task
      testTask = Task(
        id: 'test-task-1',
        title: 'Test Task',
        description: 'Test Description',
        subject: 'Mathematics',
        deadline: DateTime.now().add(const Duration(days: 1)),
        isCompleted: false,
      );

      // Register controller
      Get.put<TaskController>(taskController);
    });

    tearDown(() {
      Get.reset();
    });

    Widget createEditTaskView() {
      return GetMaterialApp(home: EditTaskView(task: testTask));
    }

    testWidgets('should display EditTaskView with pre-filled form data', (
      tester,
    ) async {
      await tester.pumpWidget(createEditTaskView());
      await tester.pumpAndSettle();

      // Verify AppBar title
      expect(find.text('Edit Tugas'), findsOneWidget);

      // Verify form fields are pre-filled
      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('Mathematics'), findsOneWidget);

      // Verify buttons are present
      expect(find.text('Simpan Perubahan'), findsOneWidget);
      expect(find.text('Hapus Tugas'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
    });

    testWidgets(
      'should show delete confirmation dialog when delete button is pressed',
      (tester) async {
        await tester.pumpWidget(createEditTaskView());
        await tester.pumpAndSettle();

        // Tap delete button
        await tester.tap(find.text('Hapus Tugas'));
        await tester.pumpAndSettle();

        // Verify confirmation dialog appears
        expect(find.text('Hapus Tugas?'), findsOneWidget);
        expect(
          find.text('Apakah Anda yakin ingin menghapus tugas ini?'),
          findsOneWidget,
        );
        expect(find.text('Judul: Test Task'), findsOneWidget);
        expect(find.text('Mata Pelajaran: Mathematics'), findsOneWidget);
        expect(
          find.text('Tindakan ini tidak dapat dibatalkan.'),
          findsOneWidget,
        );

        // Verify dialog buttons
        expect(find.text('Batal'), findsAtLeastNWidgets(1));
        expect(find.text('Hapus'), findsOneWidget);
      },
    );

    testWidgets('should dismiss delete dialog when cancel is pressed', (
      tester,
    ) async {
      await tester.pumpWidget(createEditTaskView());
      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.text('Hapus Tugas'));
      await tester.pumpAndSettle();

      // Tap cancel in dialog
      await tester.tap(find.text('Batal').last);
      await tester.pumpAndSettle();

      // Verify dialog is dismissed
      expect(find.text('Hapus Tugas?'), findsNothing);
    });

    testWidgets('should show cancel confirmation when form has changes', (
      tester,
    ) async {
      await tester.pumpWidget(createEditTaskView());
      await tester.pumpAndSettle();

      // Make changes to the form
      await tester.enterText(
        find.byType(TextFormField).first,
        'Modified Task Title',
      );
      await tester.pumpAndSettle();

      // Tap cancel button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('Batalkan Perubahan?'), findsOneWidget);
      expect(
        find.text(
          'Anda memiliki perubahan yang belum disimpan. Apakah Anda yakin ingin membatalkan?',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should validate required fields', (tester) async {
      await tester.pumpWidget(createEditTaskView());
      await tester.pumpAndSettle();

      // Clear required fields
      await tester.enterText(find.byType(TextFormField).first, ''); // Title
      await tester.enterText(find.byType(TextFormField).at(1), ''); // Subject

      // Tap save button
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      // Verify validation errors
      expect(find.text('Judul tugas tidak boleh kosong'), findsOneWidget);
      expect(find.text('Mata pelajaran tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('should validate title minimum length', (tester) async {
      await tester.pumpWidget(createEditTaskView());
      await tester.pumpAndSettle();

      // Enter short title
      await tester.enterText(find.byType(TextFormField).first, 'AB');

      // Tap save button
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      // Verify validation error
      expect(find.text('Judul tugas minimal 3 karakter'), findsOneWidget);
    });

    testWidgets('should validate description maximum length', (tester) async {
      await tester.pumpWidget(createEditTaskView());
      await tester.pumpAndSettle();

      // Enter long description (over 500 characters)
      final longDescription = 'A' * 501;
      await tester.enterText(find.byType(TextFormField).at(2), longDescription);

      // Tap save button
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      // Verify validation error
      expect(find.text('Deskripsi maksimal 500 karakter'), findsOneWidget);
    });

    testWidgets('should show existing subjects as chips', (tester) async {
      // Add some tasks to controller to have existing subjects
      taskController.allTasks.addAll([
        Task(title: 'Task 1', subject: 'Physics', deadline: DateTime.now()),
        Task(title: 'Task 2', subject: 'Chemistry', deadline: DateTime.now()),
      ]);

      await tester.pumpWidget(createEditTaskView());
      await tester.pumpAndSettle();

      // Verify existing subjects text appears
      expect(find.text('Mata pelajaran yang sudah ada:'), findsOneWidget);

      // Verify subject chips are present
      expect(find.text('Physics'), findsOneWidget);
      expect(find.text('Chemistry'), findsOneWidget);
    });

    testWidgets('should select subject when chip is tapped', (tester) async {
      // Add some tasks to controller to have existing subjects
      taskController.allTasks.addAll([
        Task(title: 'Task 1', subject: 'Physics', deadline: DateTime.now()),
      ]);

      await tester.pumpWidget(createEditTaskView());
      await tester.pumpAndSettle();

      // Tap on Physics chip
      await tester.tap(find.text('Physics'));
      await tester.pumpAndSettle();

      // Verify subject field is updated
      final subjectField = find.byType(TextFormField).at(1);
      final textField = tester.widget<TextFormField>(subjectField);
      expect(textField.controller?.text, equals('Physics'));
    });

    testWidgets('should show deadline picker when deadline field is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createEditTaskView());
      await tester.pumpAndSettle();

      // Tap deadline field
      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();

      // Verify date picker appears
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('should clear deadline when clear button is pressed', (
      tester,
    ) async {
      await tester.pumpWidget(createEditTaskView());
      await tester.pumpAndSettle();

      // Find and tap clear button (suffix icon)
      final clearButton = find.byIcon(Icons.clear);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      // Verify deadline is cleared
      expect(find.text('Pilih tanggal deadline'), findsOneWidget);
    });

    testWidgets('should show loading state when saving', (tester) async {
      await tester.pumpWidget(createEditTaskView());
      await tester.pumpAndSettle();

      // Tap save button
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pump(); // Don't settle to catch loading state

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
      expect(find.text('Menyimpan...'), findsOneWidget);
    });
  });
}
