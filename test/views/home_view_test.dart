import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:student_task_tracker/controllers/task_controller.dart';
import 'package:student_task_tracker/model/task.dart';
import 'package:student_task_tracker/views/home_view.dart';

// Import the generated mocks from controller test
import '../controllers/task_controller_test.mocks.dart';

void main() {
  group('HomeView Widget Tests', () {
    late MockStorageService mockStorageService;
    late TaskController taskController;

    setUp(() {
      // Initialize GetX for testing
      Get.testMode = true;

      mockStorageService = MockStorageService();
      taskController = TaskController(mockStorageService);

      // Setup mock behavior
      when(mockStorageService.initialize()).thenAnswer((_) async {});
      when(mockStorageService.getAllTasks()).thenAnswer((_) async => []);

      // Register controller with GetX
      Get.put<TaskController>(taskController);
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('HomeView should display app title', (
      WidgetTester tester,
    ) async {
      // Build the HomeView widget
      await tester.pumpWidget(GetMaterialApp(home: const HomeView()));

      // Wait for any async operations
      await tester.pumpAndSettle();

      // Verify that the app title is displayed
      expect(find.text('Student Task Tracker'), findsOneWidget);
    });

    testWidgets('HomeView should display FloatingActionButton', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(GetMaterialApp(home: const HomeView()));

      await tester.pumpAndSettle();

      // Verify that the FloatingActionButton is displayed
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('HomeView should display FilterChips', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(GetMaterialApp(home: const HomeView()));

      await tester.pumpAndSettle();

      // Verify that FilterChips are displayed
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Belum Selesai'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
    });

    testWidgets('HomeView should display empty state when no tasks', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(GetMaterialApp(home: const HomeView()));

      await tester.pumpAndSettle();

      // Verify empty state is displayed
      expect(find.text('Belum Ada Tugas'), findsOneWidget);
      expect(find.text('Tambah Tugas Pertama'), findsOneWidget);
    });

    testWidgets('HomeView should display search icon in AppBar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(GetMaterialApp(home: const HomeView()));

      await tester.pumpAndSettle();

      // Verify search icon is displayed
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('HomeView should display refresh icon in AppBar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(GetMaterialApp(home: const HomeView()));

      await tester.pumpAndSettle();

      // Verify refresh icon is displayed
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets(
      'HomeView should toggle search mode when search icon is tapped',
      (WidgetTester tester) async {
        await tester.pumpWidget(GetMaterialApp(home: const HomeView()));

        await tester.pumpAndSettle();

        // Tap the search icon
        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle();

        // Verify search field is displayed and close icon appears
        expect(find.byType(TextField), findsOneWidget);
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.text('Cari tugas...'), findsOneWidget);
      },
    );

    testWidgets('HomeView should show snackbar when FAB is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(GetMaterialApp(home: const HomeView()));

      await tester.pumpAndSettle();

      // Tap the FloatingActionButton
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify snackbar is displayed (placeholder implementation)
      expect(
        find.text(
          'Navigasi ke AddTaskView akan diimplementasi di task selanjutnya',
        ),
        findsOneWidget,
      );
    });

    testWidgets('HomeView should display tasks when available', (
      WidgetTester tester,
    ) async {
      // Create mock tasks
      final mockTasks = [
        Task(
          title: 'Test Task 1',
          subject: 'Math',
          deadline: DateTime.now().add(const Duration(days: 1)),
          description: 'Test description 1',
        ),
        Task(
          title: 'Test Task 2',
          subject: 'Science',
          deadline: DateTime.now().add(const Duration(days: 2)),
          description: 'Test description 2',
        ),
      ];

      // Setup mock to return tasks
      when(mockStorageService.getAllTasks()).thenAnswer((_) async => mockTasks);

      // Reinitialize controller with tasks
      await taskController.loadTasks();

      await tester.pumpWidget(GetMaterialApp(home: const HomeView()));

      await tester.pumpAndSettle();

      // Verify tasks are displayed
      expect(find.text('Test Task 1'), findsOneWidget);
      expect(find.text('Test Task 2'), findsOneWidget);
    });
  });
}
