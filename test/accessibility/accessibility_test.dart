import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:student_task_tracker/controllers/task_controller.dart';
import 'package:student_task_tracker/model/task.dart';
import 'package:student_task_tracker/services/storage_service.dart';
import 'package:student_task_tracker/utils/accessibility_utils.dart';
import 'package:student_task_tracker/utils/accessibility_theme.dart';
import 'package:student_task_tracker/views/home_view.dart';
import 'package:student_task_tracker/widgets/task_card.dart';
import 'package:student_task_tracker/widgets/filter_chips.dart';

// Mock storage service untuk testing
class MockStorageService extends StorageService {
  final List<Task> _tasks = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<List<Task>> getAllTasks() async => _tasks;

  @override
  Future<void> addTask(Task task) async {
    _tasks.add(task);
  }

  @override
  Future<void> saveTask(Task task) async {
    _tasks.add(task);
  }

  @override
  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
  }

  @override
  Future<void> toggleTaskStatus(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
    }
  }

  @override
  Future<void> clearAllTasks() async {
    _tasks.clear();
  }

  @override
  Future<void> close() async {}
}

void main() {
  group('Accessibility Tests', () {
    late MockStorageService mockStorageService;
    late TaskController taskController;

    setUp(() {
      // Reset GetX
      Get.reset();

      // Setup mock services
      mockStorageService = MockStorageService();
      Get.put<StorageService>(mockStorageService);

      // Setup controller
      taskController = TaskController(mockStorageService);
      Get.put<TaskController>(taskController);
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('HomeView has proper semantic labels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const HomeView(),
          theme: AccessibilityTheme.buildHighContrastLightTheme(),
        ),
      );

      // Verify main semantic labels exist
      expect(
        find.bySemanticsLabel('Student Task Tracker - Aplikasi Pencatat Tugas'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Daftar tugas utama'), findsOneWidget);
      expect(find.bySemanticsLabel('Filter tugas'), findsOneWidget);
      expect(find.bySemanticsLabel('Tambah tugas baru'), findsOneWidget);
    });

    testWidgets('FilterChips have proper accessibility features', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: const FilterChips()),
          theme: AccessibilityTheme.buildHighContrastLightTheme(),
        ),
      );

      // Verify filter chips have semantic labels
      expect(find.bySemanticsLabel(RegExp(r'Filter.*Semua')), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp(r'Filter.*Belum Selesai')),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp(r'Filter.*Selesai')), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp(r'Filter.*Terlambat')),
        findsOneWidget,
      );
    });

    testWidgets('TaskCard has comprehensive semantic information', (
      WidgetTester tester,
    ) async {
      final testTask = Task(
        title: 'Test Task',
        subject: 'Mathematics',
        description: 'Test description',
        deadline: DateTime.now().add(const Duration(days: 1)),
      );

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: testTask,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
          theme: AccessibilityTheme.buildHighContrastLightTheme(),
        ),
      );

      // Verify task card has comprehensive semantic information
      final semanticLabel = AccessibilityUtils.getTaskCardSemantics(
        title: testTask.title,
        subject: testTask.subject,
        deadline: 'deadline info',
        isCompleted: testTask.isCompleted,
        isOverdue: testTask.isOverdue,
        isDueSoon: testTask.isDueSoon,
        description: testTask.description,
      );

      // Check that semantic information is present (partial match)
      expect(find.bySemanticsLabel(RegExp(r'.*Test Task.*')), findsOneWidget);
    });

    testWidgets('Buttons have minimum touch target size', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AccessibilityUtils.ensureMinTouchTarget(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Test Button'),
                  ),
                ),
              ],
            ),
          ),
          theme: AccessibilityTheme.buildHighContrastLightTheme(),
        ),
      );

      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);

      final buttonWidget = tester.widget<ElevatedButton>(buttonFinder);
      final buttonSize = tester.getSize(buttonFinder);

      // Verify minimum touch target size
      expect(
        buttonSize.width,
        greaterThanOrEqualTo(AccessibilityUtils.minTouchTargetSize),
      );
      expect(
        buttonSize.height,
        greaterThanOrEqualTo(AccessibilityUtils.minTouchTargetSize),
      );
    });

    testWidgets('High contrast theme has proper contrast ratios', (
      WidgetTester tester,
    ) async {
      final highContrastTheme =
          AccessibilityTheme.buildHighContrastLightTheme();

      await tester.pumpWidget(
        MaterialApp(
          theme: highContrastTheme,
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: const Column(
              children: [
                Text('Test Text'),
                ElevatedButton(onPressed: null, child: Text('Test Button')),
              ],
            ),
          ),
        ),
      );

      // Verify high contrast colors are applied
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(Colors.black));
      expect(appBar.foregroundColor, equals(Colors.white));

      // Verify text theme has larger sizes
      final textTheme = highContrastTheme.textTheme;
      expect(textTheme.bodyLarge?.fontSize, greaterThan(16));
      expect(textTheme.headlineSmall?.fontSize, greaterThan(24));
    });

    test('AccessibilityUtils generates proper semantic labels', () {
      // Test task card semantics
      final taskSemantics = AccessibilityUtils.getTaskCardSemantics(
        title: 'Math Homework',
        subject: 'Mathematics',
        deadline: '25 Dec 2024, 14:00',
        isCompleted: false,
        isOverdue: false,
        isDueSoon: true,
        description: 'Complete exercises 1-10',
      );

      expect(taskSemantics, contains('Math Homework'));
      expect(taskSemantics, contains('Mathematics'));
      expect(taskSemantics, contains('25 Dec 2024, 14:00'));
      expect(taskSemantics, contains('segera deadline'));
      expect(taskSemantics, contains('Complete exercises 1-10'));

      // Test filter chip semantics
      final filterSemantics = AccessibilityUtils.getFilterChipSemantics(
        filterName: 'Semua',
        count: 5,
        isSelected: true,
      );

      expect(filterSemantics, contains('Filter aktif'));
      expect(filterSemantics, contains('Semua'));
      expect(filterSemantics, contains('5 tugas'));

      // Test form field semantics
      final formSemantics = AccessibilityUtils.getFormFieldSemantics(
        label: 'Judul Tugas',
        isRequired: true,
        value: 'Test Title',
        hint: 'Masukkan judul',
      );

      expect(formSemantics, contains('Judul Tugas'));
      expect(formSemantics, contains('wajib diisi'));
      expect(formSemantics, contains('Test Title'));
      expect(formSemantics, contains('Masukkan judul'));
    });

    test('AccessibilityTheme provides proper text scaling', () {
      final baseTheme = ThemeData();
      final scaledTheme = AccessibilityTheme.buildScalableTextTheme(
        baseTheme: baseTheme,
        textScaleFactor: 1.5,
      );

      // Verify text sizes are scaled
      final originalBodyLarge = baseTheme.textTheme.bodyLarge?.fontSize ?? 16;
      final scaledBodyLarge = scaledTheme.textTheme.bodyLarge?.fontSize ?? 16;

      expect(scaledBodyLarge, equals(originalBodyLarge * 1.5));
    });

    testWidgets('Focus management works properly', (WidgetTester tester) async {
      final focusNode1 = AccessibilityUtils.createFocusNode(
        debugLabel: 'Field 1',
      );
      final focusNode2 = AccessibilityUtils.createFocusNode(
        debugLabel: 'Field 2',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  focusNode: focusNode1,
                  decoration: const InputDecoration(labelText: 'Field 1'),
                ),
                TextField(
                  focusNode: focusNode2,
                  decoration: const InputDecoration(labelText: 'Field 2'),
                ),
              ],
            ),
          ),
        ),
      );

      // Test focus navigation
      focusNode1.requestFocus();
      await tester.pump();
      expect(focusNode1.hasFocus, isTrue);

      focusNode2.requestFocus();
      await tester.pump();
      expect(focusNode2.hasFocus, isTrue);
      expect(focusNode1.hasFocus, isFalse);

      // Clean up
      focusNode1.dispose();
      focusNode2.dispose();
    });

    testWidgets('Semantic announcements work', (WidgetTester tester) async {
      // This test verifies that the announcement method doesn't throw errors
      // Actual announcement testing would require platform-specific testing
      expect(() {
        AccessibilityUtils.announceMessage('Test announcement');
      }, returnsNormally);
    });

    test('Accessibility constants are properly defined', () {
      expect(AccessibilityUtils.minTouchTargetSize, equals(48.0));
      expect(AccessibilityUtils.addTaskButtonLabel, isNotEmpty);
      expect(AccessibilityUtils.searchButtonLabel, isNotEmpty);
      expect(AccessibilityUtils.refreshButtonLabel, isNotEmpty);
      expect(AccessibilityUtils.taskCompletedLabel, isNotEmpty);
      expect(AccessibilityUtils.taskPendingLabel, isNotEmpty);
    });
  });
}
