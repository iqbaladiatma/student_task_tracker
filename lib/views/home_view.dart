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

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  Timer? _searchDebounceTimer;
  late final AnimationController _gradientController;
  late final Animation<Alignment> _topAlignmentAnimation;
  late final Animation<Alignment> _bottomAlignmentAnimation;
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
  late final ScrollController _scrollController;
  bool _isFabVisible = true;
  late final AnimationController _searchBarController;
  late final Animation<double> _searchBarWidthAnimation;
  double _searchBarWidthFraction = 0.75;
  EdgeInsets _searchBarMargin = const EdgeInsets.symmetric(
    vertical: 8,
    horizontal: 12,
  );

  // --- PERUBAHAN UNTUK PAGINASI ---
  static const int _itemsPerPage = 3; // Menampilkan 3 kartu per halaman
  late final PageController _pageController;
  final RxInt _currentPageIndex = 0.obs; // Melacak halaman saat ini
  // --- AKHIR PERUBAHAN ---

  @override
  void initState() {
    super.initState();

    // --- PERUBAHAN UNTUK PAGINASI ---
    // Pindahkan inisialisasi PageController ke atas
    // untuk memastikan _pageController diinisialisasi sebelum
    // listener lain atau method build dipanggil.
    _pageController = PageController();
    _pageController.addListener(() {
      // Perbarui halaman saat ini ketika PageView di-scroll/swipe
      _currentPageIndex.value = _pageController.page?.round() ?? 0;
    });
    // --- AKHIR PERUBAHAN ---

    _searchFocusNode = AccessibilityUtils.createFocusNode(
      debugLabel: 'Search Field',
    );
    _searchFocusNode.addListener(_onSearchFocusChange);

    _startHintAnimation();

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

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;
      if (direction == ScrollDirection.reverse && _isFabVisible) {
        setState(() => _isFabVisible = false);
      } else if (direction == ScrollDirection.forward && !_isFabVisible) {
        setState(() => _isFabVisible = true);
      }
    });

    _searchBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _searchBarWidthAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _searchBarController, curve: Curves.easeOutExpo),
    );

    _searchBarWidthFraction = 0.75;
    _searchBarMargin = const EdgeInsets.symmetric(
      vertical: 8,
      horizontal: 40,
    ).copyWith(left: 64);
    _searchBarWidthFraction = 0.75;
    _searchBarMargin = const EdgeInsets.symmetric(vertical: 8, horizontal: 12);

    // --- PERUBAHAN UNTUK PAGINASI ---
    // _pageController = PageController(); // <-- Sudah dipindahkan ke atas
    // _pageController.addListener(() {
    //   // Perbarui halaman saat ini ketika PageView di-scroll/swipe
    //   _currentPageIndex.value = _pageController.page?.round() ?? 0;
    // });
    // --- AKHIR PERUBAHAN ---

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AccessibilityUtils.announceMessage('Halaman daftar tugas dimuat');
    });
  }

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
    if (_isSearchActive) return;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<TaskController>()) {
        final taskController = Get.find<TaskController>();
        taskController.refresh();
      }
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _gradientController.dispose();
    _scrollController.dispose();
    _refreshButtonFocusNode.dispose();
    _fabFocusNode.dispose();
    _searchBarController.dispose();
    _pageController.dispose(); // --- PERUBAHAN: Dispose PageController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    return Scaffold(
      // Hapus backgroundColor dari Scaffold, biarkan Stack yang mengaturnya
      // backgroundColor: Colors.white,
      appBar: _buildAppBar(taskController),
      body: Stack(
        children: [
          // Latar belakang gradien
          Positioned.fill(
            // <-- PENTING: Membuat gradien mengisi seluruh Stack
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor, // Atas (Biru Tua)
                    Colors.white, // Bawah (Putih)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [
                    0.0,
                    0.9,
                  ], // Atur gradasi agar putih mulai lebih cepat
                ),
              ),
            ),
          ),
          // Konten utama aplikasi (di atas gradien)
          AccessibilityUtils.createSemanticWidget(
            label: 'Daftar tugas utama',
            child: Column(
              children: [
                _buildModernHeader(taskController),
                AccessibilityUtils.createSemanticWidget(
                  label: 'Filter tugas',
                  hint:
                      'Pilih filter untuk menampilkan tugas berdasarkan status',
                  child: const FilterChips(),
                ),
                Expanded(
                  child: AccessibilityUtils.createSemanticWidget(
                    label: 'Daftar tugas',
                    child: Obx(() {
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

    EdgeInsets searchMargin = _isSearchActive
        ? const EdgeInsets.symmetric(vertical: 8, horizontal: 16)
        : const EdgeInsets.only(top: 8, bottom: 8, left: 60, right: 16);

    double screenWidth = MediaQuery.of(context).size.width;
    double searchBarWidth = _isSearchActive
        ? screenWidth - 32
        : screenWidth * 0.75;

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
              logoWidget,
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
                          height: 1.2,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
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

  void _onSearchChanged(String query, TaskController controller) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(PerformanceUtils.searchDebounceDelay, () {
      controller.searchTasks(query);
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

  void _performImmediateSearch(String query) {
    _searchDebounceTimer?.cancel();
    final taskController = Get.find<TaskController>();
    taskController.searchTasks(query);
    final resultCount = taskController.filteredTasks.length;
    AccessibilityUtils.announceMessage(
      'Pencarian selesai. Ditemukan $resultCount tugas',
    );
  }

  Widget _buildTaskList(TaskController controller) {
    if (controller.isLoading) {
      return _buildLoadingState();
    }
    if (controller.errorMessage.isNotEmpty) {
      return _buildErrorState(controller);
    }
    if (controller.filteredTasks.isEmpty) {
      return _buildEmptyState(controller);
    }

    // --- PERUBAHAN UNTUK PAGINASI ---
    final tasks = controller.filteredTasks;
    final int pageCount = (tasks.length / _itemsPerPage).ceil();
    final bool showNavigator = pageCount > 1;

   // Di dalam _buildTaskList, ganti return statement menjadi:
return Semantics(
  key: const ValueKey('list'),
  label: 'Daftar ${tasks.length} tugas, ditampilkan dalam $pageCount halaman',
  hint: 'Geser ke bawah untuk muat ulang, geser ke kiri atau kanan untuk berpindah halaman',
  child: Stack( // <-- GUNAKAN STACK
    children: [
      // Konten PageView
      Expanded(
        child: RefreshIndicator(
          onRefresh: () async {
            AccessibilityUtils.announceMessage('Memuat ulang daftar tugas');
            await controller.refresh();
            AccessibilityUtils.announceMessage(
              'Daftar tugas berhasil dimuat ulang',
            );
          },
          color: primaryColor,
          child: PageView.builder(
            controller: _pageController,
            itemCount: pageCount,
            itemBuilder: (context, pageIndex) {
              final int startIndex = pageIndex * _itemsPerPage;
              final int endIndex = (startIndex + _itemsPerPage).clamp(
                0,
                tasks.length,
              );
              final List<dynamic> pageTasks = tasks.sublist(
                startIndex,
                endIndex,
              );

              return Container(
                color: Colors.transparent,
                child: AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: 8,
                      top: 8,
                    ),
                    controller: _scrollController,
                    itemCount: pageTasks.length,
                    cacheExtent: PerformanceUtils.listCacheExtent,
                    itemBuilder: (context, index) {
                      final task = pageTasks[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 450),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          curve: Curves.easeOutExpo,
                          child: FadeInAnimation(
                            child: Semantics(
                              sortKey: OrdinalSortKey(index.toDouble()),
                              child: TaskCard(
                                task: task,
                                onTap: () => _navigateToEditTask(task.id),
                                onEdit: () => _navigateToEditTask(task.id),
                                onDelete: () =>
                                    _handleDeleteTask(controller, task.id),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    semanticChildCount: pageTasks.length,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      
      // Pagination di bagian bawah overlay
      if (showNavigator) 
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildPageNavigator(pageCount),
        ),
    ],
  ),
);
    // --- AKHIR PERUBAHAN ---
  }

Widget _buildPageNavigator(int pageCount) {
  return Obx(() {
    final bool canGoBack = _currentPageIndex.value > 0;
    final bool canGoForward = _currentPageIndex.value < pageCount - 1;

    return Container(
      height: 50, // Fixed height
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: canGoBack ? primaryColor : Colors.grey[400],
              size: 20,
            ),
            onPressed: canGoBack
                ? () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                : null,
          ),
          const SizedBox(width: 16),
          Text(
            'Halaman ${_currentPageIndex.value + 1} dari $pageCount',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColorSecondary,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: canGoForward ? primaryColor : Colors.grey[400],
              size: 20,
            ),
            onPressed: canGoForward
                ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  });
}
  // --- AKHIR WIDGET BARU ---

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      key: const ValueKey('loading'),
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 3, // Ubah ke 3 agar konsisten dengan _itemsPerPage
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(TaskController controller) {
    return Center(
      key: const ValueKey('error'),
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

  Widget _buildEmptyState(TaskController controller) {
    final isSearching = controller.searchQuery.isNotEmpty;
    final hasFilter = controller.currentFilter != TaskFilter.all;
    final title = _getEmptyStateTitle(isSearching, hasFilter);
    final subtitle = _getEmptyStateSubtitle(isSearching, hasFilter);

    return Center(
      key: const ValueKey('empty'),
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

  // --- KODE LAMA _buildTaskListView ---
  // Widget _buildTaskListView(TaskController controller) {
  //   return Semantics(
  //     key: const ValueKey('list'),
  //     label: 'Daftar ${controller.filteredTasks.length} tugas',
  //     hint: 'Geser ke bawah untuk muat ulang, ketuk tugas untuk edit',
  //     child: RefreshIndicator(
  //       onRefresh: () async {
  //         AccessibilityUtils.announceMessage('Memuat ulang daftar tugas');
  //         await controller.refresh();
  //         AccessibilityUtils.announceMessage(
  //           'Daftar tugas berhasil dimuat ulang',
  //         );
  //       },
  //       color: primaryColor,
  //       child: AnimationLimiter(
  //         child: ListView.builder(
  //           padding: const EdgeInsets.only(bottom: 90, top: 8),
  //           controller: _scrollController,
  //           itemCount: controller.filteredTasks.length,
  //           cacheExtent: PerformanceUtils.listCacheExtent,
  //           itemBuilder: (context, index) {
  //             final task = controller.filteredTasks[index];
  //             return AnimationConfiguration.staggeredList(
  //               position: index,
  //               duration: const Duration(
  //                 milliseconds: 450,
  //               ),
  //               child: SlideAnimation(
  //                 verticalOffset: 50.0,
  //                 curve: Curves.easeOutExpo,
  //                 child: FadeInAnimation(
  //                   child: Semantics(
  //                     sortKey: OrdinalSortKey(index.toDouble()),
  //                     child: TaskCard(
  //                       task: task,
  //                       onTap: () => _navigateToEditTask(task.id),
  //                       onEdit: () => _navigateToEditTask(task.id),
  //                       onDelete: () => _handleDeleteTask(controller, task.id),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //           semanticChildCount: controller.filteredTasks.length,
  //           physics: const BouncingScrollPhysics(
  //             parent: AlwaysScrollableScrollPhysics(),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  // --- AKHIR KODE LAMA ---

  Widget _buildModernHeader(TaskController controller) {
    // Bungkus dengan AnimatedBuilder untuk gradien bergerak
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // HAPUS: Gradasi biru transparan
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: _bottomAlignmentAnimation.value, // Gunakan animasi
          //   colors: [
          //     primaryColor.withOpacity(0.1), // Gunakan warna baru
          //     primaryColorLight.withOpacity(0.1),
          //   ],
          // ),

          // GANTI: Gunakan warna putih semi-transparan (efek "frosted glass")
          color: Colors.white.withOpacity(0.7), // 40% Putih Transparan

          borderRadius: BorderRadius.circular(20),

          // HAPUS: Border biru
          // border: Border.all(color: primaryColor.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                0.1,
              ), // Tetap gunakan shadow hitam tipis
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

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 12),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
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

  Widget _buildFloatingActionButton() {
    return AnimatedScale(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      scale: _isFabVisible ? 1.0 : 0.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
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
            backgroundColor: Colors.transparent,
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

  void _clearSearch(TaskController controller) {
    _searchDebounceTimer?.cancel();
    _searchController.clear();
    controller.clearSearch();
    AccessibilityUtils.announceMessage(
      'Pencarian dihapus, menampilkan semua tugas',
    );
  }

  void _navigateToAddTask() {
    AccessibilityUtils.announceMessage('Membuka form tambah tugas');
    Get.toNamed(AppRoutes.addTask);
  }

  void _navigateToEditTask(String taskId) {
    final taskController = Get.find<TaskController>();
    final task = taskController.getTaskById(taskId);

    if (task != null) {
      AccessibilityUtils.announceMessage(
        'Membuka form edit tugas ${task.title}',
      );
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

  String _getEmptyStateTitle(bool isSearching, bool hasFilter) {
    if (isSearching) {
      return 'Tidak Ada Hasil';
    } else if (hasFilter) {
      return 'Tidak Ada Tugas';
    } else {
      return 'Belum Ada Tugas';
    }
  }

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
