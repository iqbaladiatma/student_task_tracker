import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../model/task.dart';

/// Widget untuk menampilkan filter chips untuk memfilter tugas
/// Menyediakan filter berdasarkan status (All, Pending, Completed, Overdue)
/// dengan animasi smooth dan active state indication
class FilterChips extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final double? spacing;

  const FilterChips({super.key, this.padding, this.spacing});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    return Obx(() {
      return Container(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: TaskFilter.values.map((filter) {
              final isSelected = taskController.currentFilter == filter;
              final count = _getFilterCount(taskController, filter);

              return Padding(
                padding: EdgeInsets.only(right: spacing ?? 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: FilterChip(
                    label: _buildChipLabel(filter, count),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        taskController.setFilter(filter);
                      }
                    },
                    backgroundColor: _getBackgroundColor(filter, false),
                    selectedColor: _getBackgroundColor(filter, true),
                    checkmarkColor: _getCheckmarkColor(filter),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? _getSelectedTextColor(filter)
                          : _getUnselectedTextColor(filter),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? _getBorderColor(filter, true)
                          : _getBorderColor(filter, false),
                      width: isSelected ? 2 : 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: isSelected ? 2 : 0,
                    pressElevation: 4,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    showCheckmark: false, // Menggunakan styling custom
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  /// Build label untuk chip dengan nama filter dan count
  Widget _buildChipLabel(TaskFilter filter, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_getFilterIcon(filter), size: 16),
        const SizedBox(width: 4),
        Text(_getFilterName(filter)),
        if (count > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ],
    );
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
      return baseColor.withOpacity(0.2);
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
                            ? filter.color.withOpacity(0.1)
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
