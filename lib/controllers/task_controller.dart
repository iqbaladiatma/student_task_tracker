import 'package:get/get.dart';
import '../model/task.dart';
import '../services/storage_service.dart';

/// Enum untuk filter status tugas
enum TaskFilter {
  all, // Semua tugas
  pending, // Tugas belum selesai
  completed, // Tugas selesai
  overdue, // Tugas terlambat
}

/// Controller untuk mengelola state dan business logic tugas
/// Menggunakan GetX untuk reactive state management
class TaskController extends GetxController {
  final StorageService _storageService;

  TaskController(this._storageService);

  // Observable lists untuk reactive UI
  final RxList<Task> _allTasks = <Task>[].obs;
  final RxList<Task> _filteredTasks = <Task>[].obs;
  final Rx<TaskFilter> _currentFilter = TaskFilter.all.obs;
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _errorMessage = ''.obs;

  // Getters untuk akses read-only
  List<Task> get allTasks => _allTasks;
  List<Task> get filteredTasks => _filteredTasks;
  TaskFilter get currentFilter => _currentFilter.value;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;
  String get errorMessage => _errorMessage.value;

  // Computed properties
  int get totalTasks => _allTasks.length;
  int get completedTasks => _allTasks.where((task) => task.isCompleted).length;
  int get pendingTasks => _allTasks.where((task) => !task.isCompleted).length;
  int get overdueTasks => _allTasks.where((task) => task.isOverdue).length;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  /// Initialize controller dan load data
  Future<void> _initializeController() async {
    try {
      _setLoading(true);
      _clearError();
      await _storageService.initialize();
      await loadTasks();
    } catch (e) {
      _setError('Gagal menginisialisasi aplikasi: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Public method untuk initialization yang bisa di-await
  Future<void> initialize() async {
    await _initializeController();
  }

  /// Load semua tugas dari storage
  Future<void> loadTasks() async {
    try {
      _setLoading(true);
      _clearError();

      final tasks = await _storageService.getAllTasks();
      _allTasks.assignAll(tasks);
      _applyCurrentFilter();
    } catch (e) {
      _setError('Gagal memuat tugas: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Tambah tugas baru
  Future<bool> addTask(Task task) async {
    try {
      _setLoading(true);
      _clearError();

      await _storageService.addTask(task);
      _allTasks.add(task);
      _applyCurrentFilter();

      return true;
    } catch (e) {
      _setError('Gagal menambah tugas: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update tugas yang sudah ada
  Future<bool> updateTask(Task task) async {
    try {
      _setLoading(true);
      _clearError();

      await _storageService.updateTask(task);

      // Update task di local list
      final index = _allTasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _allTasks[index] = task;
        _applyCurrentFilter();
      }

      return true;
    } catch (e) {
      _setError('Gagal mengupdate tugas: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Hapus tugas berdasarkan ID
  Future<bool> deleteTask(String taskId) async {
    try {
      _setLoading(true);
      _clearError();

      await _storageService.deleteTask(taskId);

      // Hapus task dari local list
      _allTasks.removeWhere((task) => task.id == taskId);
      _applyCurrentFilter();

      return true;
    } catch (e) {
      _setError('Gagal menghapus tugas: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle status completion tugas
  Future<bool> toggleTaskStatus(String taskId) async {
    try {
      _setLoading(true);
      _clearError();

      await _storageService.toggleTaskStatus(taskId);

      // Update task di local list
      final taskIndex = _allTasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        final task = _allTasks[taskIndex];
        final updatedTask = task.copyWith(
          isCompleted: !task.isCompleted,
          updatedAt: DateTime.now(),
        );
        _allTasks[taskIndex] = updatedTask;
        _applyCurrentFilter();
      }

      return true;
    } catch (e) {
      _setError('Gagal mengubah status tugas: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Set filter untuk tugas
  void setFilter(TaskFilter filter) {
    _currentFilter.value = filter;
    _applyCurrentFilter();
  }

  /// Set search query dan apply filter
  void searchTasks(String query) {
    _searchQuery.value = query.toLowerCase();
    _applyCurrentFilter();
  }

  /// Clear search query
  void clearSearch() {
    _searchQuery.value = '';
    _applyCurrentFilter();
  }

  /// Apply filter dan search ke daftar tugas
  void _applyCurrentFilter() {
    List<Task> filtered = List.from(_allTasks);

    // Apply status filter
    switch (_currentFilter.value) {
      case TaskFilter.pending:
        filtered = filtered.where((task) => !task.isCompleted).toList();
        break;
      case TaskFilter.completed:
        filtered = filtered.where((task) => task.isCompleted).toList();
        break;
      case TaskFilter.overdue:
        filtered = filtered.where((task) => task.isOverdue).toList();
        break;
      case TaskFilter.all:
        // No additional filtering needed
        break;
    }

    // Apply search filter
    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered.where((task) {
        return task.title.toLowerCase().contains(_searchQuery.value) ||
            task.description.toLowerCase().contains(_searchQuery.value) ||
            task.subject.toLowerCase().contains(_searchQuery.value);
      }).toList();
    }

    // Sort by deadline (ascending) with completed tasks at the end
    filtered.sort((a, b) {
      // Completed tasks go to the end
      if (a.isCompleted && !b.isCompleted) return 1;
      if (!a.isCompleted && b.isCompleted) return -1;

      // For tasks with same completion status, sort by deadline
      return a.deadline.compareTo(b.deadline);
    });

    _filteredTasks.assignAll(filtered);
  }

  /// Get task by ID
  Task? getTaskById(String taskId) {
    try {
      return _allTasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  /// Get tasks by subject
  List<Task> getTasksBySubject(String subject) {
    return _allTasks
        .where((task) => task.subject.toLowerCase() == subject.toLowerCase())
        .toList();
  }

  /// Get unique subjects from all tasks
  List<String> getUniqueSubjects() {
    final subjects = _allTasks.map((task) => task.subject).toSet().toList();
    subjects.sort();
    return subjects;
  }

  /// Refresh data dari storage
  Future<void> refresh() async {
    await loadTasks();
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  /// Helper methods untuk state management
  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }

  void _setError(String error) {
    _errorMessage.value = error;
  }

  void _clearError() {
    _errorMessage.value = '';
  }

  @override
  void onClose() {
    // Cleanup resources jika diperlukan
    super.onClose();
  }
}
