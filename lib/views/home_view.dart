import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer
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

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false; // <-- Logika baru untuk toggle logo

  // Performance optimization: Debounced search
  Timer? _searchDebounceTimer;

  // Kontroler untuk animasi latar belakang bergerak
  late final AnimationController _gradientController;
  late final Animation<Alignment> _topAlignmentAnimation;
  late final Animation<Alignment> _bottomAlignmentAnimation;

  // Focus node untuk accessibility navigation (dideklarasikan satu kali)
  late final FocusNode _searchFocusNode;
  final FocusNode _refreshButtonFocusNode = AccessibilityUtils.createFocusNode(
    debugLabel: 'Refresh Button',
  );
  final FocusNode _fabFocusNode = AccessibilityUtils.createFocusNode(
    debugLabel: 'Floating Action Button',
  );

  Timer? _hintTimer;
  int _hintIndex = 0;
  bool _isDeletingHint = false;
  final String _baseHint = "Mana Tugas?";
  String _animatedHint = "";

  // Kontroler untuk animasi FAB
  late final ScrollController _scrollController;
  bool _isFabVisible = true;

  // Add animation controller for search bar width
  late final AnimationController _searchBarController;
  late final Animation<double> _searchBarWidthAnimation;

  // Add search bar width and margin for animation
  double _searchBarWidthFraction = 0.75;
  EdgeInsets _searchBarMargin = const EdgeInsets.symmetric(
    vertical: 8,
    horizontal: 12,
  );

  @override
  void initState() {
    super.initState();

    _searchFocusNode = AccessibilityUtils.createFocusNode(
      debugLabel: 'Search Field',
    );
    _searchFocusNode.addListener(_onSearchFocusChange);

    // Mulai animasi placeholder
    _startHintAnimation();

    // Inisialisasi Kontroler Gradien Latar Belakang
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _topAlignmentAnimation = AlignmentTween(
      begin: Alignment.topLeft,
      end: Alignment.topRight,
    ).animate(_gradientController);

    _bottomAlignmentAnimation = AlignmentTween(
      begin: Alignment.bottomRight,
      end: Alignment.bottomLeft,
    ).animate(_gradientController);

    // Inisialisasi Kontroler Scroll FAB
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;
      if (direction == ScrollDirection.reverse && _isFabVisible) {
        setState(() => _isFabVisible = false);
      } else if (direction == ScrollDirection.forward && !_isFabVisible) {
        setState(() => _isFabVisible = true);
      }
    });

    // Animation controller for search bar expansion
    _searchBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _searchBarWidthAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _searchBarController, curve: Curves.easeOutExpo),
    );

    // Set initial width and margin to push search bar to the left
    _searchBarWidthFraction = 0.75;
    _searchBarMargin = const EdgeInsets.symmetric(
      vertical: 8,
      horizontal: 40, // Push search bar to the right by 40 logical pixels to not overlap the logo
    ).copyWith(left: 64); // Push search bar to the left by 64 logical pixels to not overlap the logo
    _searchBarWidthFraction = 0.75;
    _searchBarMargin = const EdgeInsets.symmetric(vertical: 8, horizontal: 12);

    // Announce screen load untuk screen readers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AccessibilityUtils.announceMessage('Halaman daftar tugas dimuat');
    });
  }

  // --- Logika untuk Animasi Placeholder ---
  void _startHintAnimation() {
    _hintTimer?.cancel();
    _hintIndex = 0;
    _isDeletingHint = false;
    _animatedHint = "";
    _hintTimer = Timer.periodic(const Duration(milliseconds: 120), _updateHint);
  }

  void _stopHintAnimation() {
    _hintTimer?.cancel();
  }

  void _updateHint(Timer timer) {
    if (_isSearchActive) return; // Hentikan animasi jika sedang mengetik

    setState(() {
      if (_isDeletingHint) {
        if (_hintIndex > 0) {
          _hintIndex--;
          _animatedHint = _baseHint.substring(0, _hintIndex);
        } else {
          _isDeletingHint = false;
          timer.cancel();
          Future.delayed(
            const Duration(milliseconds: 500),
            _startHintAnimation,
          );
        }
      } else {
        if (_hintIndex < _baseHint.length) {
          _hintIndex++;
          _animatedHint = _baseHint.substring(0, _hintIndex);
        } else {
          _isDeletingHint = true;
          timer.cancel();
          Future.delayed(const Duration(seconds: 2), _startHintAnimation);
        }
      }
    });
  }
  // --- Akhir Logika Animasi Placeholder ---

  // --- Logika untuk Toggle Search/Logo ---
  void _onSearchFocusChange() {
    if (_searchFocusNode.hasFocus && !_isSearchActive) {
      _toggleSearch(true, Get.find<TaskController>());
    } else if (!_searchFocusNode.hasFocus && _isSearchActive) {
      _toggleSearch(false, Get.find<TaskController>());
    }
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
    _hintTimer?.cancel(); // Hentikan timer placeholder
    _searchFocusNode.removeListener(_onSearchFocusChange); // Hapus listener
    _searchFocusNode.dispose();
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _gradientController.dispose(); // Dispose gradient controller
    _scrollController.dispose(); // Dispose scroll controller
    _refreshButtonFocusNode.dispose();
    _fabFocusNode.dispose();
    _searchBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(taskController),
      // Gunakan Stack untuk menempatkan latar belakang bergerak di belakang
      body: Stack(
        children: [
          // Anda bisa menambahkan latar belakang bergerak di sini jika mau
          // _buildAnimatedBackground(),
          AccessibilityUtils.createSemanticWidget(
            label: 'Daftar tugas utama',
            child: Column(
              children: [
                // Modern header dengan statistik
                _buildModernHeader(taskController),

                // Filter chips dengan semantic label
                AccessibilityUtils.createSemanticWidget(
                  label: 'Filter tugas',
                  hint:
                      'Pilih filter untuk menampilkan tugas berdasarkan status',
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
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Build AppBar with animated logo and search bar
  PreferredSizeWidget _buildAppBar(TaskController controller) {
    Widget logoWidget = AnimatedScale(
      scale: _isSearchActive ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutExpo,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: Icon(Icons.school_rounded, color: Colors.white, size: 32),
      ),
    );

    // Calculate margin that will animate between states
    EdgeInsets searchMargin = _isSearchActive 
        ? const EdgeInsets.symmetric(vertical: 8, horizontal: 16) // Equal margins when active
        : const EdgeInsets.only(top: 8, bottom: 8, left: 60, right: 16); // Tight to logo when inactive

    // Calculate width including the space where logo was
    double screenWidth = MediaQuery.of(context).size.width;
    double searchBarWidth = _isSearchActive
        ? screenWidth - 32 // Full width minus margins (16 each side)
        : screenWidth * 0.75; // 75% width when inactive

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: const [primaryColor, primaryColorLight],
            begin: _topAlignmentAnimation.value,
            end: _bottomAlignmentAnimation.value,
          ),
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Logo as background layer
              logoWidget,
              // Search bar as top layer, will slide left to cover logo space
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                width: searchBarWidth,
                margin: searchMargin,
                child: Semantics(
                  textField: true,
                  label: 'Pencarian tugas',
                  hint: 'Ketik untuk mencari tugas',
                  child: Center(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: _isSearchActive
                            ? 'Cari berdasarkan judul, mapel...'
                            : _animatedHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.12),
                        hintStyle: TextStyle(
                          color: _isSearchActive
                              ? Colors.white70
                              : Colors.white,
                          fontWeight: _isSearchActive
                              ? FontWeight.normal
                              : FontWeight.w500,
                          height: 1.2, // Untuk vertical center
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18, // Lebih tinggi agar teks di tengah
                          horizontal: 16,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      textAlignVertical: TextAlignVertical.center,
                      onTap: () {
                        if (!_isSearchActive) {
                          _toggleSearch(true, controller);
                        }
                      },
                      onChanged: (query) {
                        _onSearchChanged(query, controller);
                      },
                      textInputAction: TextInputAction.search,
                      onSubmitted: (query) {
                        _performImmediateSearch(query);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Logika Debounce untuk search
  void _onSearchChanged(String query, TaskController controller) {
    // Performance optimization: Debounced search
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(PerformanceUtils.searchDebounceDelay, () {
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
    });
  }

  /// Logika search submit
  void _performImmediateSearch(String query) {
    _searchDebounceTimer?.cancel();
    final taskController = Get.find<TaskController>();
    taskController.searchTasks(query);
    final resultCount = taskController.filteredTasks.length;
    AccessibilityUtils.announceMessage(
      'Pencarian selesai. Ditemukan $resultCount tugas',
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
    // Gunakan Shimmer effect untuk loading state yang lebih premium
    return Shimmer.fromColors(
      key: const ValueKey('loading'),
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5, // Tampilkan 5 skeleton card
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            height: 120, // Sesuaikan tinggi dengan TaskCard
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
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
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: textColorSecondary),
              ),
              const SizedBox(height: 24),
              AccessibilityUtils.ensureMinTouchTarget(
                child:
                    ElevatedButton.icon(
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
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: textColorSecondary),
              ),
              const SizedBox(height: 24),
              if (!isSearching && !hasFilter) ...[
                AccessibilityUtils.ensureMinTouchTarget(
                  child:
                      ElevatedButton.icon(
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ).asSemanticButton(
                        label: 'Tambah Tugas Pertama',
                        hint: 'Buat tugas pertama Anda untuk memulai',
                      ),
                ),
              ] else if (isSearching) ...[
                AccessibilityUtils.ensureMinTouchTarget(
                  child:
                      TextButton.icon(
                        onPressed: () => _clearSearch(controller),
                        icon: const Icon(Icons.clear, color: primaryColor),
                        label: const Text(
                          'Hapus Pencarian',
                          style: TextStyle(color: primaryColor),
                        ),
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
                  child:
                      TextButton.icon(
                        onPressed: () {
                          controller.setFilter(TaskFilter.all);
                          AccessibilityUtils.announceMessage(
                            'Filter dihapus, menampilkan semua tugas',
                          );
                        },
                        icon: const Icon(Icons.clear_all, color: primaryColor),
                        label: const Text(
                          'Hapus Filter',
                          style: TextStyle(color: primaryColor),
                        ),
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
            controller: _scrollController, // Tautkan scroll controller
            itemCount: controller.filteredTasks.length,
            // Performance optimization: Set estimated item extent for better scrolling
            // itemExtent: PerformanceUtils.listItemExtent, // Hapus itemExtent untuk tinggi dinamis
            // Performance optimization: Cache extent for smoother scrolling
            cacheExtent: PerformanceUtils.listCacheExtent,
            itemBuilder: (context, index) {
              final task = controller.filteredTasks[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(
                  milliseconds: 450,
                ), // Sedikit lebih lambat
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  curve: Curves.easeOutExpo, // Efek "cepat-lambat" yang halus
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
    // Bungkus dengan AnimatedBuilder untuk gradien bergerak
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: _bottomAlignmentAnimation.value, // Gunakan animasi
            colors: [
              primaryColor.withOpacity(0.1), // Gunakan warna baru
              primaryColorLight.withOpacity(0.1),
            ],
          ),
          color: cardColor, // Fallback
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: child, // Child-nya adalah Obx
      ),
      child: Obx(
        () => Column(
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColorSecondary,
                        ),
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
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Selesai',
                    controller.completedTasks.toString(),
                    Icons.check_circle,
                    completedColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Pending',
                    controller.pendingTasks.toString(),
                    Icons.pending_actions,
                    pendingColor,
                  ),
                ),
                const SizedBox(width: 8),
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
      ),
    );
  }

  /// Build card statistik kecil
  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    // Desain ulang agar lebih minimalis
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        // Hapus border untuk tampilan lebih bersih
        // border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20, // Perbesar angka
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 12), // Icon lebih kecil
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label, // <-- "Terlambat"
                  textAlign: TextAlign.center, // Pusatkan jika wrap
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w600, // Pertegas label
                  ),
                  maxLines: 1,
                ),
              ),
            ],
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
    // Animasikan FAB saat scroll
    return AnimatedScale(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      scale: _isFabVisible ? 1.0 : 0.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4), // Shadow lebih kuat
              blurRadius: 16,
              offset: const Offset(0, 8),
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
      ),
    );
  }

  /// Toggle search mode
  void _toggleSearch(bool activate, TaskController controller) {
    setState(() {
      _isSearchActive = activate;
      if (_isSearchActive) {
        _searchBarWidthFraction = 1.0;
        _searchBarMargin = const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 0,
        );
        _searchBarController.forward();
        AccessibilityUtils.announceMessage('Mode pencarian dibuka');
        _searchFocusNode.requestFocus();
        _stopHintAnimation();
      } else {
        _searchBarWidthFraction = 0.75;
        _searchBarMargin = const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12,
        );
        _searchBarController.reverse();
        _searchController.clear();
        controller.clearSearch();
        AccessibilityUtils.announceMessage('Pencarian ditutup');
        _searchFocusNode.unfocus();
        _startHintAnimation();
      }
    });
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
    TaskController controller,
    String taskId,
  ) async {
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
