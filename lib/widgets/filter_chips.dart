import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../model/task.dart';
import '../utils/accessibility_utils.dart';
import '../utils/colors.dart'; // Import file colors.dart

/// Widget untuk menampilkan filter chips untuk memfilter tugas
/// Menyediakan filter berdasarkan status (All, Pending, Completed, Overdue)
/// dengan animasi smooth dan active state indication
/// Tampilan datar (horizontal scroll) dan warna dinamis sesuai status.
class FilterChips extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final double? spacing;

  const FilterChips({super.key, this.padding, this.spacing});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    return Obx(() {
      final currentFilter = taskController.currentFilter;

      return Container(
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Semantics(
          label: 'Filter tugas',
          hint: 'Pilih filter untuk menampilkan tugas berdasarkan status',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: TaskFilter.values.asMap().entries.map((entry) {
                final index = entry.key;
                final filter = entry.value;
                final isSelected = currentFilter == filter;
                final count = _getFilterCount(taskController, filter);
                final semanticLabel =
                    AccessibilityUtils.getFilterChipSemantics(
                  filterName: _getFilterName(filter),
                  count: count,
                  isSelected: isSelected,
                );

                // Ambil warna dasar untuk filter ini
                final Color filterColor = _getFilterBaseColor(filter);

                // Widget chip yang sebenarnya
                Widget chipWidget = AccessibilityUtils.ensureMinTouchTarget(
                  child: Semantics(
                    button: true,
                    label: semanticLabel,
                    selected: isSelected,
                    onTap: () {
                      taskController.setFilter(filter);
                      AccessibilityUtils.announceMessage(
                        'Filter ${_getFilterName(filter)} dipilih, menampilkan $count tugas',
                      );
                    },
                    child: FilterChip(
                      label: _buildChipLabelContent(filter, count, isSelected),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          taskController.setFilter(filter);
                          AccessibilityUtils.announceMessage(
                            'Filter ${_getFilterName(filter)} dipilih, menampilkan $count tugas',
                          );
                        }
                      },
                      // INI PERBAIKANNYA (Solid saat Selected, Muda saat Unselected):
                      backgroundColor: filterColor
                          .withOpacity(0.15), // Warna MUDA saat tidak dipilih
                      selectedColor:
                          filterColor, // Warna SOLID/GELAP saat dipilih
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? filterColor // Border solid (sesuai warna) saat dipilih
                              : filterColor.withOpacity(
                                  0.90), // Border muda saat tidak dipilih
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      labelPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      elevation: isSelected
                          ? 1
                          : 0, // Sedikit shadow saat dipilih
                      shadowColor: isSelected
                          ? filterColor.withOpacity(0.2)
                          : null,
                    ),
                  ),
                );

                // Beri animasi staggered
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(
                      milliseconds: 300), // Animasi sedikit lebih cepat
                  child: SlideAnimation(
                    horizontalOffset: 30.0,
                    child: FadeInAnimation(
                      child: Padding(
                        padding: EdgeInsets.only(right: spacing ?? 10),
                        child: chipWidget,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
    });
  }

  /// Build content label untuk chip dengan icon, nama filter, dan count
  Widget _buildChipLabelContent(TaskFilter filter, int count, bool isSelected) {
    // WARNA KONTEN JUGA DIPERBAIKI:
    final Color baseColor = _getFilterBaseColor(filter);
    // Jika terpilih (background solid), teks jadi PUTIH.
    // Jika tidak terpilih (background muda), teks jadi WARNA DASAR (solid).
    final Color contentColor = isSelected ? Colors.white : baseColor;

    // Atur warna bubble count
    final Color countBgColor = isSelected ? Colors.white : baseColor;
    final Color countTextColor = isSelected ? baseColor : Colors.white;

    return AccessibilityUtils.excludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getFilterIcon(filter),
            size: 18,
            color: contentColor, // Terapkan warna dinamis
            semanticLabel: _getFilterName(filter),
          ),
          const SizedBox(width: 6),
          Text(
            _getFilterName(filter),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: contentColor, // Terapkan warna dinamis
              height: 1.2,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: countBgColor, // Terapkan warna dinamis
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: countTextColor, // Terapkan warna dinamis
                  height: 1.0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Get nama filter dalam bahasa Indonesia
  String _getFilterName(TaskFilter filter) {
    return filter.displayName; // Use extension method
  }

  /// Get icon untuk setiap filter
  IconData _getFilterIcon(TaskFilter filter) {
    return filter.icon; // Use extension method
  }

  /// Get jumlah tugas untuk setiap filter
  int _getFilterCount(TaskController controller, TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return controller.totalTasks;
      case TaskFilter.pending:
        return controller.pendingTasks;
      case TaskFilter.completed:
        return controller.completedTasks;
      case TaskFilter.overdue:
        return controller.overdueTasks;
    }
  }

  /// Get base color untuk setiap filter (menggunakan palet warna)
  Color _getFilterBaseColor(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return primaryColor; // Biru
      case TaskFilter.pending:
        return pendingColor; // Oranye
      case TaskFilter.completed:
        return completedColor; // Hijau
      case TaskFilter.overdue:
        return accentColorRed; // Merah
    }
  }
}

// ... (Sisa file tidak berubah) ...
extension TaskFilterExtension on TaskFilter {
  /// Get display name dalam bahasa Indonesia
  String get displayName {
    switch (this) {
      case TaskFilter.all:
        return 'Semua';
      case TaskFilter.pending:
        return 'Belum Selesai';
      case TaskFilter.completed:
        return 'Selesai';
      case TaskFilter.overdue:
        return 'Terlambat';
    }
  }

  /// Get icon untuk filter
  IconData get icon {
    switch (this) {
      case TaskFilter.all:
        return Icons.list_alt_rounded;
      case TaskFilter.pending:
        return Icons.pending_actions_rounded;
      case TaskFilter.completed:
        return Icons.check_circle_outline_rounded;
      case TaskFilter.overdue:
        return Icons.warning_amber_rounded;
    }
  }

  /// Get color untuk filter (menggunakan palet warna)
  Color get color {
    switch (this) {
      case TaskFilter.all:
        return primaryColor;
      case TaskFilter.pending:
        return pendingColor;
      case TaskFilter.completed:
        return completedColor;
      case TaskFilter.overdue:
        return accentColorRed;
    }
  }

  /// Check apakah filter menampilkan tugas dengan status tertentu
  bool matchesTask(Task task) {
    switch (this) {
      case TaskFilter.all:
        return true;
      case TaskFilter.pending:
        return !task.isCompleted;
      case TaskFilter.completed:
        return task.isCompleted;
      case TaskFilter.overdue:
        return task.isOverdue && !task.isCompleted;
    }
  }
}

