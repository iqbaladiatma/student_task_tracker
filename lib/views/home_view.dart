import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../routes/app_routes.dart';
import '../utils/accessibility_utils.dart';
import '../utils/performance_utils.dart';
import '../widgets/filter_chips.dart';
import '../widgets/task_card.dart';
import '../utils/colors.dart'; // Import color constants

// Konstanta warna dihapus dari sini karena sudah diimpor dari utils/colors.dart

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

  // Performance optimization: Debounced search
  Timer? _searchDebounceTimer;

  // Focus nodes untuk accessibility navigation
  final FocusNode _searchFocusNode = AccessibilityUtils.createFocusNode(
    debugLabel: 'Search Field',
  );
  final FocusNode _refreshButtonFocusNode = AccessibilityUtils.createFocusNode(
    debugLabel: 'Refresh Button',
  );
  final FocusNode _fabFocusNode = AccessibilityUtils.createFocusNode(
    debugLabel: 'Add Task FAB',
  );

  @override
  void initState() {
    super.initState();
    // Initialize TaskController jika belum ada
    if (!Get.isRegistered<TaskController>()) {
      // Controller akan di-register di main.dart atau binding
      // Ini adalah fallback jika controller belum di-register
    }

    // Announce screen load untuk screen readers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AccessibilityUtils.announceMessage('Halaman daftar tugas dimuat');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data ketika kembali ke halaman ini
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<TaskController>()) {
        final taskController = Get.find<TaskController>();
        taskController.refresh();
      }
    });
  }

  @override
  void dispose() {
    // Performance optimization: Cancel debounce timer
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _refreshButtonFocusNode.dispose();
    _fabFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(taskController),
      body: AccessibilityUtils.createSemanticWidget(
        label: 'Daftar tugas utama',
        child: Column(
          children: [
            // Modern header dengan statistik
            _buildModernHeader(taskController),

            // Filter chips dengan semantic label
            AccessibilityUtils.createSemanticWidget(
              label: 'Filter tugas',
              hint: 'Pilih filter untuk menampilkan tugas berdasarkan status',
              child: const FilterChips(),
            ),

            // Task list dengan semantic label
            Expanded(
              child: AccessibilityUtils.createSemanticWidget(
                label: 'Daftar tugas',
                child: Obx(() {
                  // AnimatedSwitcher untuk transisi halus antar state
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildTaskList(taskController),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Build AppBar dengan search functionality
  PreferredSizeWidget _buildAppBar(TaskController controller) {
    return AppBar(
      title: _isSearching
          ? _buildSearchField(controller)
          : _buildTitle(),
      // Gradasi biru modern
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColorLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      backgroundColor: Colors.transparent, // Latar belakang AppBar transparan
      elevation: 0, // Hilangkan shadow bawaan
      actions: [
        // Search toggle button dengan accessibility
        AccessibilityUtils.ensureMinTouchTarget(
          child: Semantics(
            button: true,
            label: _isSearching
                ? AccessibilityUtils.closeSearchLabel
                : AccessibilityUtils.searchButtonLabel,
            hint: _isSearching
                ? 'Tutup pencarian dan kembali ke daftar tugas'
                : 'Buka pencarian untuk mencari tugas',
            onTap: () => _toggleSearch(controller),
            child: IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search,
                  color: Colors.white, size: 28),
              onPressed: () => _toggleSearch(controller),
            ),
          ),
        ),

        // Refresh button dengan accessibility
        AccessibilityUtils.ensureMinTouchTarget(
          child: Semantics(
            button: true,
            label: AccessibilityUtils.refreshButtonLabel,
            hint: 'Muat ulang daftar tugas dari penyimpanan',
            onTap: () => controller.refresh(),
            child: IconButton(
              focusNode: _refreshButtonFocusNode,
              icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
              onPressed: () => controller.refresh(),
            ),
          ),
        ),
      ],
    );
  }

  /// Build title untuk AppBar
  Widget _buildTitle() {
    return AccessibilityUtils.createSemanticWidget(
      header: true,
      label: 'Student Task Tracker - Aplikasi Pencatat Tugas',
      child: const Text(
        'Student Task Tracker',
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
      ),
    );
  }

  /// Build search field untuk AppBar
  Widget _buildSearchField(TaskController controller) {
    return Semantics(
      textField: true,
      label: 'Pencarian tugas',
      hint:
          'Ketik untuk mencari tugas berdasarkan judul, deskripsi, atau mata pelajaran',
      value: _searchController.text,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Cari tugas...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white70),
        ),
        style: const TextStyle(color: Colors.white, fontSize: 18),
        onChanged: (query) {
          // Performance optimization: Debounced search
          _searchDebounceTimer?.cancel();
          _searchDebounceTimer = Timer(
            PerformanceUtils.searchDebounceDelay,
            () {
              controller.searchTasks(query);
              // Announce search results untuk screen readers
              if (query.isNotEmpty) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  final resultCount = controller.filteredTasks.length;
                  AccessibilityUtils.announceMessage(
                    'Ditemukan $resultCount tugas untuk pencarian "$query"',
                  );
                });
              }
            },
          );
        },
        textInputAction: TextInputAction.search,
        onSubmitted: (query) {
          // Performance optimization: Immediate search on submit
          _performImmediateSearch(query);
          final resultCount = controller.filteredTasks.length;
          AccessibilityUtils.announceMessage(
            'Pencarian selesai. Ditemukan $resultCount tugas',
          );
        },
      ),
    );
  }

  /// Build daftar tugas dengan ListView
  Widget _buildTaskList(TaskController controller) {
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
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Center(
      key: const ValueKey('loading'), // Key untuk AnimatedSwitcher
      child: Semantics(
        label: AccessibilityUtils.getLoadingSemantics('memuat daftar tugas'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              semanticsLabel: 'Sedang memuat',
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Memuat tugas...',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: textColorSecondary),
            ),
          ],
        ),
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(TaskController controller) {
    return Center(
      key: const ValueKey('error'), // Key untuk AnimatedSwitcher
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Semantics(
          label: AccessibilityUtils.getErrorSemantics(
            title: 'Terjadi Kesalahan',
            message: controller.errorMessage,
            actionLabel: 'Tekan tombol Coba Lagi',
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: accentColorRed.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Terjadi Kesalahan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: accentColorRed,
                      fontWeight: FontWeight.w600,
                    ),
              ).asSemanticHeader(label: 'Terjadi Kesalahan'),
              const SizedBox(height: 8),
              Text(
                controller.errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: textColorSecondary),
              ),
              const SizedBox(height: 24),
              AccessibilityUtils.ensureMinTouchTarget(
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.clearError();
                    controller.refresh();
                    AccessibilityUtils.announceMessage(
                      'Mencoba memuat ulang daftar tugas',
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColorRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ).asSemanticButton(
                  label: 'Coba Lagi',
                  hint: 'Muat ulang daftar tugas setelah error',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(TaskController controller) {
    final isSearching = controller.searchQuery.isNotEmpty;
    final hasFilter = controller.currentFilter != TaskFilter.all;
    final title = _getEmptyStateTitle(isSearching, hasFilter);
    final subtitle = _getEmptyStateSubtitle(isSearching, hasFilter);

    return Center(
      key: const ValueKey('empty'), // Key untuk AnimatedSwitcher
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Semantics(
          label: AccessibilityUtils.getEmptyStateSemantics(
            title: title,
            subtitle: subtitle,
            actionLabel: !isSearching && !hasFilter
                ? 'Tekan tombol Tambah Tugas Pertama'
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSearching ? Icons.search_off : Icons.assignment_outlined,
                size: 64,
                color: Colors.grey[400],
                semanticLabel: isSearching
                    ? 'Tidak ada hasil pencarian'
                    : 'Tidak ada tugas',
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: textColorPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ).asSemanticHeader(label: title),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: textColorSecondary),
              ),
              const SizedBox(height: 24),
              if (!isSearching && !hasFilter) ...[
                AccessibilityUtils.ensureMinTouchTarget(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToAddTask(),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Tugas Pertama'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ).asSemanticButton(
                    label: 'Tambah Tugas Pertama',
                    hint: 'Buat tugas pertama Anda untuk memulai',
                  ),
                ),
              ] else if (isSearching) ...[
                AccessibilityUtils.ensureMinTouchTarget(
                  child: TextButton.icon(
                    onPressed: () => _clearSearch(controller),
                    icon: const Icon(Icons.clear, color: primaryColor),
                    label:
                        const Text('Hapus Pencarian', style: TextStyle(color: primaryColor)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ).asSemanticButton(
                    label: 'Hapus Pencarian',
                    hint:
                        'Hapus kata kunci pencarian dan tampilkan semua tugas',
                  ),
                ),
              ] else if (hasFilter) ...[
                AccessibilityUtils.ensureMinTouchTarget(
                  child: TextButton.icon(
                    onPressed: () {
                      controller.setFilter(TaskFilter.all);
                      AccessibilityUtils.announceMessage(
                        'Filter dihapus, menampilkan semua tugas',
                      );
                    },
                    icon: const Icon(Icons.clear_all, color: primaryColor),
                    label: const Text('Hapus Filter',
                        style: TextStyle(color: primaryColor)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ).asSemanticButton(
                    label: 'Hapus Filter',
                    hint: 'Hapus filter dan tampilkan semua tugas',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build ListView untuk menampilkan daftar tugas
  Widget _buildTaskListView(TaskController controller) {
    return Semantics(
      key: const ValueKey('list'), // Key untuk AnimatedSwitcher
      label: 'Daftar ${controller.filteredTasks.length} tugas',
      hint: 'Geser ke bawah untuk muat ulang, ketuk tugas untuk edit',
      child: RefreshIndicator(
        onRefresh: () async {
          AccessibilityUtils.announceMessage('Memuat ulang daftar tugas');
          await controller.refresh();
          AccessibilityUtils.announceMessage(
            'Daftar tugas berhasil dimuat ulang',
          );
        },
        color: primaryColor, // Warna refresh indicator
        child: AnimationLimiter(
          // Tambahkan AnimationLimiter
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 90, top: 8), // Space for FAB
            itemCount: controller.filteredTasks.length,
            // Performance optimization: Set estimated item extent for better scrolling
            // itemExtent: PerformanceUtils.listItemExtent, // Hapus itemExtent untuk tinggi dinamis
            // Performance optimization: Cache extent for smoother scrolling
            cacheExtent: PerformanceUtils.listCacheExtent,
            itemBuilder: (context, index) {
              final task = controller.filteredTasks[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Semantics(
                      sortKey: OrdinalSortKey(index.toDouble()),
                      child: TaskCard(
                        task: task,
                        onTap: () => _navigateToEditTask(task.id),
                        onEdit: () => _navigateToEditTask(task.id),
                        onDelete: () => _handleDeleteTask(controller, task.id),
                      ),
                    ),
                  ),
                ),
              );
            },
            // Accessibility improvements untuk ListView
            semanticChildCount: controller.filteredTasks.length,
            // Performance optimization: Add physics for better scrolling
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
        ),
      ),
    );
  }

  /// Build modern header dengan statistik tugas
  Widget _buildModernHeader(TaskController controller) {
    return Obx(() {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withOpacity(0.1),
              Colors.white.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primaryColor.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.assignment_outlined,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tugas Anda',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getGreetingMessage(),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: textColorSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    controller.totalTasks.toString(),
                    Icons.list_alt,
                    primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Selesai',
                    controller.completedTasks.toString(),
                    Icons.check_circle,
                    completedColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Pending',
                    controller.pendingTasks.toString(),
                    Icons.pending_actions,
                    pendingColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Terlambat',
                    controller.overdueTasks.toString(),
                    Icons.warning,
                    accentColorRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// Build card statistik kecil
  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Get greeting message berdasarkan waktu
  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat pagi! Mari selesaikan tugas hari ini.';
    } else if (hour < 17) {
      return 'Selamat siang! Tetap semangat mengerjakan tugas.';
    } else {
      return 'Selamat sore! Jangan lupa cek tugas yang belum selesai.';
    }
  }

  /// Build FloatingActionButton untuk menambah tugas
  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        gradient: const LinearGradient(
          colors: [primaryColorLight, primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Semantics(
        button: true,
        label: AccessibilityUtils.addTaskButtonLabel,
        hint: 'Buka form untuk menambah tugas baru',
        onTap: _navigateToAddTask,
        child: FloatingActionButton.extended(
          focusNode: _fabFocusNode,
          onPressed: _navigateToAddTask,
          tooltip: AccessibilityUtils.addTaskButtonLabel,
          backgroundColor: Colors.transparent, // Transparan untuk gradasi
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add, size: 24, semanticLabel: 'Tambah'),
          label: const Text(
            'Tambah Tugas',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      ),
    );
  }

  /// Toggle search mode
  void _toggleSearch(TaskController controller) {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        controller.clearSearch();
        AccessibilityUtils.announceMessage('Pencarian ditutup');
        // Return focus to refresh button
        _refreshButtonFocusNode.requestFocus();
      } else {
        AccessibilityUtils.announceMessage('Mode pencarian dibuka');
        // Focus on search field
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFocusNode.requestFocus();
        });
      }
    });
  }

  /// Performance optimization: Immediate search (for submit)
  void _performImmediateSearch(String query) {
    _searchDebounceTimer?.cancel();
    final taskController = Get.find<TaskController>();
    taskController.searchTasks(query);
  }

  /// Clear search
  void _clearSearch(TaskController controller) {
    _searchDebounceTimer?.cancel();
    _searchController.clear();
    controller.clearSearch();
    AccessibilityUtils.announceMessage(
      'Pencarian dihapus, menampilkan semua tugas',
    );
  }

  /// Navigate to add task screen
  void _navigateToAddTask() {
    AccessibilityUtils.announceMessage('Membuka form tambah tugas');
    // Hapus parameter 'transition'
    Get.toNamed(AppRoutes.addTask);
  }

  /// Navigate to edit task screen
  void _navigateToEditTask(String taskId) {
    final taskController = Get.find<TaskController>();
    final task = taskController.getTaskById(taskId);

    if (task != null) {
      AccessibilityUtils.announceMessage(
        'Membuka form edit tugas ${task.title}',
      );
      // Hapus parameter 'transition'
      Get.toNamed(AppRoutes.editTask, arguments: task);
    } else {
      AccessibilityUtils.announceMessage('Error: Tugas tidak ditemukan');
      Get.snackbar(
        'Error',
        'Tugas tidak ditemukan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: accentColorRed,
        colorText: Colors.white,
      );
    }
  }

  /// Delete task (dipanggil oleh TaskCard)
  Future<void> _handleDeleteTask(
      TaskController controller, String taskId) async {
    final task = controller.getTaskById(taskId);
    final taskTitle = task?.title ?? 'tugas';

    AccessibilityUtils.announceMessage('Menghapus tugas $taskTitle');
    final success = await controller.deleteTask(taskId);

    if (success) {
      AccessibilityUtils.announceMessage('Tugas $taskTitle berhasil dihapus');
      Get.snackbar(
        'Berhasil',
        'Tugas berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: completedColor,
        colorText: Colors.white,
      );
    } else {
      final errorMsg = controller.errorMessage.isNotEmpty
          ? controller.errorMessage
          : 'Gagal menghapus tugas';
      AccessibilityUtils.announceMessage('Error: $errorMsg');
      Get.snackbar(
        'Error',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: accentColorRed,
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

