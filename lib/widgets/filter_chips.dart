import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../model/task.dart';
import '../utils/accessibility_utils.dart';

/// Widget untuk menampilkan filter chips untuk memfilter tugas
/// Menyediakan filter berdasarkan status (All, Pending, Completed, Overdue)
/// dengan animasi smooth dan active state indication
/// Performance optimized with efficient rebuilds and const constructors
class FilterChips extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final double? spacing;

  const FilterChips({super.key, this.padding, this.spacing});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    return Obx(() {
      // Performance optimization: Cache filter values to avoid repeated calculations
      final currentFilter = taskController.currentFilter;

      return Container(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Semantics(
          label: 'Filter tugas',
          hint: 'Pilih filter untuk menampilkan tugas berdasarkan status',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            // Performance optimization: Add physics for better scrolling
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: TaskFilter.values.asMap().entries.map((entry) {
                final index = entry.key;
                final filter = entry.value;
                final isSelected = currentFilter == filter;
                final count = _getFilterCount(taskController, filter);
                final semanticLabel = AccessibilityUtils.getFilterChipSemantics(
                  filterName: _getFilterName(filter),
                  count: count,
                  isSelected: isSelected,
                );

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Padding(
                        padding: EdgeInsets.only(right: spacing ?? 8),
                        child: AccessibilityUtils.ensureMinTouchTarget(
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
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            _getFilterBaseColor(
                                              filter,
                                            ).withValues(alpha: 0.2),
                                            _getFilterBaseColor(
                                              filter,
                                            ).withValues(alpha: 0.1),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : LinearGradient(
                                          colors: [
                                            Colors.grey[50]!,
                                            Colors.grey[100]!,
                                          ],
                                        ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected
                                        ? _getFilterBaseColor(filter)
                                        : Colors.grey[300]!,
                                    width: isSelected ? 2.5 : 1.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: _getFilterBaseColor(
                                              filter,
                                            ).withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(24),
                                  child: InkWell(
                                    onTap: () {
                                      taskController.setFilter(filter);
                                      AccessibilityUtils.announceMessage(
                                        'Filter ${_getFilterName(filter)} dipilih, menampilkan $count tugas',
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(24),
                                    splashColor: _getFilterBaseColor(
                                      filter,
                                    ).withValues(alpha: 0.1),
                                    highlightColor: _getFilterBaseColor(
                                      filter,
                                    ).withValues(alpha: 0.05),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: _buildModernChipLabel(
                                        filter,
                                        count,
                                        isSelected,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
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

  /// Build modern label untuk chip dengan nama filter dan count
  Widget _buildModernChipLabel(TaskFilter filter, int count, bool isSelected) {
    return AccessibilityUtils.excludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected
                  ? _getFilterBaseColor(filter).withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFilterIcon(filter),
              size: 16,
              color: isSelected
                  ? _getFilterBaseColor(filter)
                  : Colors.grey[600],
              semanticLabel: _getFilterName(filter),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _getFilterName(filter),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? _getFilterBaseColor(filter)
                  : Colors.grey[700],
              height: 1.2,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected
                      ? [
                          _getFilterBaseColor(filter),
                          _getFilterBaseColor(filter).withValues(alpha: 0.8),
                        ]
                      : [Colors.grey[400]!, Colors.grey[500]!],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color:
                        (isSelected
                                ? _getFilterBaseColor(filter)
                                : Colors.grey[400]!)
                            .withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build label untuk chip dengan nama filter dan count (fallback)
  Widget _buildChipLabel(TaskFilter filter, int count) {
    return _buildModernChipLabel(filter, count, false);
  }

  /// Get nama filter dalam bahasa Indonesia
  String _getFilterName(TaskFilter filter) {
    switch (filter) {
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

  /// Get icon untuk setiap filter
  IconData _getFilterIcon(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return Icons.list;
      case TaskFilter.pending:
        return Icons.pending_actions;
      case TaskFilter.completed:
        return Icons.check_circle;
      case TaskFilter.overdue:
        return Icons.warning;
    }
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

  /// Get background color berdasarkan filter dan state
  Color _getBackgroundColor(TaskFilter filter, bool isSelected) {
    final baseColor = _getFilterBaseColor(filter);

    if (isSelected) {
      return baseColor.withValues(
        alpha: 0.25,
      ); // Slightly more opaque for better contrast
    } else {
      return Colors.grey[100]!;
    }
  }

  /// Get border color berdasarkan filter dan state
  Color _getBorderColor(TaskFilter filter, bool isSelected) {
    final baseColor = _getFilterBaseColor(filter);

    if (isSelected) {
      return baseColor;
    } else {
      return Colors.grey[300]!;
    }
  }

  /// Get text color untuk selected state
  Color _getSelectedTextColor(TaskFilter filter) {
    return _getFilterBaseColor(filter);
  }

  /// Get text color untuk unselected state
  Color _getUnselectedTextColor(TaskFilter filter) {
    return Colors.grey[700]!;
  }

  /// Get checkmark color
  Color _getCheckmarkColor(TaskFilter filter) {
    return _getFilterBaseColor(filter);
  }

  /// Get base color untuk setiap filter
  Color _getFilterBaseColor(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return Colors.blue;
      case TaskFilter.pending:
        return Colors.orange;
      case TaskFilter.completed:
        return Colors.green;
      case TaskFilter.overdue:
        return Colors.red;
    }
  }
}

/// Extension untuk menambahkan utility methods ke TaskFilter enum
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
        return Icons.list;
      case TaskFilter.pending:
        return Icons.pending_actions;
      case TaskFilter.completed:
        return Icons.check_circle;
      case TaskFilter.overdue:
        return Icons.warning;
    }
  }

  /// Get color untuk filter
  Color get color {
    switch (this) {
      case TaskFilter.all:
        return Colors.blue;
      case TaskFilter.pending:
        return Colors.orange;
      case TaskFilter.completed:
        return Colors.green;
      case TaskFilter.overdue:
        return Colors.red;
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
        return task.isOverdue;
    }
  }
}

/// Widget alternatif untuk filter chips dengan layout vertikal
/// Berguna untuk sidebar atau drawer
class VerticalFilterChips extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final double? spacing;

  const VerticalFilterChips({super.key, this.padding, this.spacing});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    return Obx(() {
      return Container(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: TaskFilter.values.map((filter) {
            final isSelected = taskController.currentFilter == filter;
            final count = _getFilterCount(taskController, filter);

            return Padding(
              padding: EdgeInsets.only(bottom: spacing ?? 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => taskController.setFilter(filter),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? filter.color.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? filter.color : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            filter.icon,
                            color: isSelected ? filter.color : Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              filter.displayName,
                              style: TextStyle(
                                color: isSelected
                                    ? filter.color
                                    : Colors.grey[700],
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (count > 0) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? filter.color
                                    : Colors.grey[400],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                count.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
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
}
