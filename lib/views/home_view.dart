import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../routes/app_routes.dart';
import '../widgets/filter_chips.dart';
import '../widgets/task_card.dart';

/// HomeView sebagai main screen aplikasi Student Task Tracker
/// Menampilkan daftar tugas dengan filter, search, dan navigasi ke form tugas
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Initialize TaskController jika belum ada
    if (!Get.isRegistered<TaskController>()) {
      // Controller akan di-register di main.dart atau binding
      // Ini adalah fallback jika controller belum di-register
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    return Scaffold(
      appBar: _buildAppBar(taskController),
      body: Column(
        children: [
          // Filter chips
          const FilterChips(),

          // Task list
          Expanded(child: _buildTaskList(taskController)),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Build AppBar dengan search functionality
  PreferredSizeWidget _buildAppBar(TaskController controller) {
    return AppBar(
      title: _isSearching ? _buildSearchField(controller) : _buildTitle(),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      elevation: 2,
      actions: [
        // Search toggle button
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () => _toggleSearch(controller),
        ),

        // Refresh button
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => controller.refresh(),
        ),
      ],
    );
  }

  /// Build title untuk AppBar
  Widget _buildTitle() {
    return const Text(
      'Student Task Tracker',
      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
    );
  }

  /// Build search field untuk AppBar
  Widget _buildSearchField(TaskController controller) {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Cari tugas...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: (query) => controller.searchTasks(query),
    );
  }

  /// Build daftar tugas dengan ListView
  Widget _buildTaskList(TaskController controller) {
    return Obx(() {
      // Loading state
      if (controller.isLoading) {
        return _buildLoadingState();
      }

      // Error state
      if (controller.errorMessage.isNotEmpty) {
        return _buildErrorState(controller);
      }

      // Empty state
      if (controller.filteredTasks.isEmpty) {
        return _buildEmptyState(controller);
      }

      // Task list
      return _buildTaskListView(controller);
    });
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Memuat tugas...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(TaskController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                controller.clearError();
                controller.refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(TaskController controller) {
    final isSearching = controller.searchQuery.isNotEmpty;
    final hasFilter = controller.currentFilter != TaskFilter.all;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyStateTitle(isSearching, hasFilter),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateSubtitle(isSearching, hasFilter),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            if (!isSearching && !hasFilter) ...[
              ElevatedButton.icon(
                onPressed: () => _navigateToAddTask(),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Tugas Pertama'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ] else if (isSearching) ...[
              TextButton.icon(
                onPressed: () => _clearSearch(controller),
                icon: const Icon(Icons.clear),
                label: const Text('Hapus Pencarian'),
              ),
            ] else if (hasFilter) ...[
              TextButton.icon(
                onPressed: () => controller.setFilter(TaskFilter.all),
                icon: const Icon(Icons.clear_all),
                label: const Text('Hapus Filter'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build ListView untuk menampilkan daftar tugas
  Widget _buildTaskListView(TaskController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80), // Space for FAB
        itemCount: controller.filteredTasks.length,
        itemBuilder: (context, index) {
          final task = controller.filteredTasks[index];
          return TaskCard(
            task: task,
            onTap: () => _navigateToEditTask(task.id),
            onEdit: () => _navigateToEditTask(task.id),
            onDelete: () => _deleteTask(controller, task.id),
          );
        },
      ),
    );
  }

  /// Build FloatingActionButton untuk menambah tugas
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _navigateToAddTask,
      tooltip: 'Tambah Tugas',
      child: const Icon(Icons.add),
    );
  }

  /// Toggle search mode
  void _toggleSearch(TaskController controller) {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        controller.clearSearch();
      }
    });
  }

  /// Clear search
  void _clearSearch(TaskController controller) {
    _searchController.clear();
    controller.clearSearch();
  }

  /// Navigate to add task screen
  void _navigateToAddTask() {
    Get.toNamed(AppRoutes.addTask);
  }

  /// Navigate to edit task screen
  void _navigateToEditTask(String taskId) {
    final taskController = Get.find<TaskController>();
    final task = taskController.getTaskById(taskId);

    if (task != null) {
      Get.toNamed(AppRoutes.editTask, arguments: task)?.then((result) {
        // Refresh task list if edit was successful
        if (result == true) {
          taskController.refresh();
        }
      });
    } else {
      Get.snackbar(
        'Error',
        'Tugas tidak ditemukan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Delete task with confirmation
  Future<void> _deleteTask(TaskController controller, String taskId) async {
    final success = await controller.deleteTask(taskId);
    if (success) {
      Get.snackbar(
        'Berhasil',
        'Tugas berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        controller.errorMessage.isNotEmpty
            ? controller.errorMessage
            : 'Gagal menghapus tugas',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Get empty state title berdasarkan kondisi
  String _getEmptyStateTitle(bool isSearching, bool hasFilter) {
    if (isSearching) {
      return 'Tidak Ada Hasil';
    } else if (hasFilter) {
      return 'Tidak Ada Tugas';
    } else {
      return 'Belum Ada Tugas';
    }
  }

  /// Get empty state subtitle berdasarkan kondisi
  String _getEmptyStateSubtitle(bool isSearching, bool hasFilter) {
    if (isSearching) {
      return 'Tidak ditemukan tugas yang sesuai dengan pencarian Anda. Coba gunakan kata kunci yang berbeda.';
    } else if (hasFilter) {
      return 'Tidak ada tugas dengan filter yang dipilih. Coba ubah filter atau tambah tugas baru.';
    } else {
      return 'Mulai dengan menambahkan tugas pertama Anda. Klik tombol + di bawah untuk memulai.';
    }
  }
}
