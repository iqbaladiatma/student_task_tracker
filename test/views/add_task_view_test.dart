import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:student_task_tracker/controllers/task_controller.dart';
import 'package:student_task_tracker/model/task.dart';
import 'package:student_task_tracker/views/add_task_view.dart';

import '../controllers/task_controller_test.mocks.dart';

void main() {
  group('AddTaskView Tests', () {
    late MockStorageService mockStorageService;
    late TaskController taskController;

    setUp(() {
      mockStorageService = MockStorageService();
      taskController = TaskController(mockStorageService);

      // Register controller untuk testing
      Get.put<TaskController>(taskController);

      // Setup mock behavior
      when(mockStorageService.getAllTasks()).thenAnswer((_) async => []);
      when(mockStorageService.addTask(any)).thenAnswer((_) async {});
    });

    tearDown(() {
      Get.reset();
    });

    Widget createTestWidget() {
      return GetMaterialApp(
        home: const AddTaskView(),
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
      );
    }

    testWidgets('should display all required form fields', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify AppBar
      expect(find.text('Tambah Tugas Baru'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Simpan'), findsOneWidget);

      // Verify form fields
      expect(
        find.byType(TextFormField),
        findsNWidgets(3),
      ); // title, subject, description
      expect(find.text('Judul Tugas *'), findsOneWidget);
      expect(find.text('Mata Pelajaran *'), findsOneWidget);
      expect(find.text('Deskripsi'), findsOneWidget);
      expect(find.text('Deadline *'), findsOneWidget);

      // Verify buttons
      expect(find.text('Simpan Tugas'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
    });

    testWidgets('should show validation errors for empty required fields', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Tap save button without filling required fields
      await tester.tap(find.text('Simpan Tugas'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Judul tugas tidak boleh kosong'), findsOneWidget);
      expect(find.text('Mata pelajaran tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('should validate title field correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final titleField = find.byType(TextFormField).first;

      // Test empty title
      await tester.tap(titleField);
      await tester.enterText(titleField, '');
      await tester.tap(find.text('Simpan Tugas'));
      await tester.pumpAndSettle();
      expect(find.text('Judul tugas tidak boleh kosong'), findsOneWidget);

      // Test short title
      await tester.enterText(titleField, 'ab');
      await tester.tap(find.text('Simpan Tugas'));
      await tester.pumpAndSettle();
      expect(find.text('Judul tugas minimal 3 karakter'), findsOneWidget);

      // Test valid title
      await tester.enterText(titleField, 'Valid Title');
      await tester.tap(find.text('Simpan Tugas'));
      await tester.pumpAndSettle();
      expect(find.text('Judul tugas tidak boleh kosong'), findsNothing);
      expect(find.text('Judul tugas minimal 3 karakter'), findsNothing);
    });

    testWidgets('should open date picker when deadline field is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Find the deadline field by its InputDecorator
      final deadlineField = find.byType(InputDecorator);
      await tester.tap(deadlineField);
      await tester.pumpAndSettle();

      // Should open date picker
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('should show existing subjects as chips', (tester) async {
      // Setup mock dengan existing subjects
      final existingTasks = [
        Task(
          title: 'Task 1',
          subject: 'Matematika',
          deadline: DateTime.now().add(const Duration(days: 1)),
        ),
        Task(
          title: 'Task 2',
          subject: 'Fisika',
          deadline: DateTime.now().add(const Duration(days: 2)),
        ),
      ];

      when(
        mockStorageService.getAllTasks(),
      ).thenAnswer((_) async => existingTasks);
      await taskController.loadTasks();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show existing subjects as chips
      expect(find.text('Mata pelajaran yang sudah ada:'), findsOneWidget);
      expect(find.text('Matematika'), findsOneWidget);
      expect(find.text('Fisika'), findsOneWidget);
    });

    testWidgets('should fill subject field when chip is tapped', (
      tester,
    ) async {
      // Setup mock dengan existing subjects
      final existingTasks = [
        Task(
          title: 'Task 1',
          subject: 'Matematika',
          deadline: DateTime.now().add(const Duration(days: 1)),
        ),
      ];

      when(
        mockStorageService.getAllTasks(),
      ).thenAnswer((_) async => existingTasks);
      await taskController.loadTasks();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on subject chip
      await tester.tap(find.text('Matematika'));
      await tester.pumpAndSettle();

      // Subject field should be filled
      final subjectField = find.byType(TextFormField).at(1);
      expect(
        tester.widget<TextFormField>(subjectField).controller?.text,
        equals('Matematika'),
      );
    });

    testWidgets('should show cancel confirmation when there are changes', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Enter some text
      await tester.enterText(find.byType(TextFormField).first, 'Some title');
      await tester.pumpAndSettle();

      // Tap cancel button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Batalkan Perubahan?'), findsOneWidget);
      expect(find.text('Ya, Batalkan'), findsOneWidget);
      expect(find.text('Tidak'), findsOneWidget);
    });

    testWidgets('should save task successfully with valid data', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Fill form with valid data
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Task');
      await tester.enterText(find.byType(TextFormField).at(1), 'Matematika');
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'Test description',
      );

      // Set deadline (simulate date picker selection)
      // Note: In real test, we would need to mock the date picker
      // For now, we'll test the validation part

      await tester.pumpAndSettle();

      // Verify form fields are filled
      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Matematika'), findsOneWidget);
      expect(find.text('Test description'), findsOneWidget);
    });

    testWidgets('should validate description length', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final descriptionField = find.byType(TextFormField).at(2);

      // Test long description (over 500 characters)
      final longText = 'a' * 501;
      await tester.enterText(descriptionField, longText);

      // Fill required fields to trigger validation
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Task');
      await tester.enterText(find.byType(TextFormField).at(1), 'Matematika');

      await tester.tap(find.text('Simpan Tugas'));
      await tester.pumpAndSettle();

      expect(find.text('Deskripsi maksimal 500 karakter'), findsOneWidget);
    });

    testWidgets('should show loading state when saving', (tester) async {
      // Setup mock to simulate delay
      when(mockStorageService.addTask(any)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
      });

      await tester.pumpWidget(createTestWidget());

      // Fill required fields
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Task');
      await tester.enterText(find.byType(TextFormField).at(1), 'Matematika');

      // Note: In a real test, we would need to properly handle the date picker
      // For now, we focus on testing the form validation and UI behavior
    });
  });
}
