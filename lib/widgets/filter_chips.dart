import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../model/task.dart';
import '../utils/accessibility_utils.dart';
import '../utils/colors.dart'; // Import file colors.dart

// Palet warna sekarang diimpor dari utils/colors.dart


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
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Adjusted padding
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
                final semanticLabel = AccessibilityUtils.getFilterChipSemantics(
                  filterName: _getFilterName(filter),
                  count: count,
                  isSelected: isSelected,
                );

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 300), // Slightly faster animation
                  child: SlideAnimation(
                    horizontalOffset: 30.0, // Reduced slide offset
                    child: FadeInAnimation(
                      child: Padding(
                        padding: EdgeInsets.only(right: spacing ?? 10), // Increased spacing
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
                            // Use ChoiceChip for better semantics and default styling
                            child: ChoiceChip(
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
                              backgroundColor: Colors.white, // Background putih
                              selectedColor: _getFilterBaseColor(filter).withOpacity(0.15), // Warna terpilih lebih halus
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20), // Rounded corners
                                side: BorderSide(
                                  color: isSelected
                                      ? _getFilterBaseColor(filter)
                                      : Colors.grey.shade300, // Border abu-abu halus
                                  width: isSelected ? 1.5 : 1.0, // Border lebih halus
                                ),
                              ),
                              labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Adjusted padding
                              // Visual Density can make chips more compact
                              visualDensity: VisualDensity.compact,
                              // Ensure sufficient tap target size internally
                               materialTapTargetSize: MaterialTapTargetSize.padded,
                               elevation: isSelected ? 2 : 0, // Subtle elevation when selected
                               shadowColor: isSelected ? _getFilterBaseColor(filter).withOpacity(0.2) : null,
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

  /// Build content label untuk chip dengan icon, nama filter, dan count
  Widget _buildChipLabelContent(TaskFilter filter, int count, bool isSelected) {
      final color = isSelected ? _getFilterBaseColor(filter) : textColorSecondary; // Use palette color
    return AccessibilityUtils.excludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getFilterIcon(filter),
            size: 18, // Slightly larger icon
            color: color,
            semanticLabel: _getFilterName(filter), // Add semantic label to icon
          ),
          const SizedBox(width: 6), // Adjusted spacing
          Text(
            _getFilterName(filter),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, // Adjusted weight
              color: color,
              height: 1.2,
            ),
          ),
          // Optionally show count only if > 0
          if (count > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Smaller padding
              decoration: BoxDecoration(
                color: isSelected ? _getFilterBaseColor(filter) : Colors.grey.shade400, // Grey background when not selected
                borderRadius: BorderRadius.circular(10), // More rounded count bubble
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 11, // Smaller count text
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White text always
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
        return Icons.list_alt_rounded; // Changed icon
      case TaskFilter.pending:
        return Icons.pending_actions_rounded; // Changed icon
      case TaskFilter.completed:
        return Icons.check_circle_outline_rounded; // Changed icon
      case TaskFilter.overdue:
        return Icons.warning_amber_rounded; // Changed icon
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
        // Include overdue in pending as well, if needed? Or keep separate?
        // Assuming pending means not completed AND not overdue yet.
        // return !task.isCompleted && !task.isOverdue;
        // Or simply not completed:
        return !task.isCompleted;
      case TaskFilter.completed:
        return task.isCompleted;
      case TaskFilter.overdue:
        return task.isOverdue && !task.isCompleted; // Overdue tasks must not be completed
    }
  }
}

/// Widget alternatif untuk filter chips dengan layout vertikal
/// Berguna untuk sidebar atau drawer (belum diperbarui dengan gaya baru)
// class VerticalFilterChips extends StatelessWidget {
//   final EdgeInsetsGeometry? padding;
//   final double? spacing;

//   const VerticalFilterChips({super.key, this.padding, this.spacing});

//   @override
//   Widget build(BuildContext context) {
//     final taskController = Get.find<TaskController>();

//     return Obx(() {
//       return Container(
//         padding: padding ?? const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: TaskFilter.values.map((filter) {
//             final isSelected = taskController.currentFilter == filter;
//             final count = _getFilterCount(taskController, filter);

//             return Padding(
//               padding: EdgeInsets.only(bottom: spacing ?? 8),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 curve: Curves.easeInOut,
//                 child: Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     onTap: () => taskController.setFilter(filter),
//                     borderRadius: BorderRadius.circular(12),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 12,
//                       ),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? filter.color.withOpacity(0.1)
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: isSelected ? filter.color : Colors.grey[300]!,
//                           width: isSelected ? 2 : 1,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             filter.icon,
//                             color: isSelected ? filter.color : Colors.grey[600],
//                             size: 20,
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               filter.displayName,
//                               style: TextStyle(
//                                 color: isSelected
//                                     ? filter.color
//                                     : Colors.grey[700],
//                                 fontWeight: isSelected
//                                     ? FontWeight.w600
//                                     : FontWeight.w500,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ),
//                           if (count > 0) ...[
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: isSelected
//                                     ? filter.color
//                                     : Colors.grey[400],
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 count.toString(),
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                   color: isSelected
//                                       ? Colors.white
//                                       : Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       );
//     });
//   }

//   /// Get jumlah tugas untuk setiap filter
//   int _getFilterCount(TaskController controller, TaskFilter filter) {
//     switch (filter) {
//       case TaskFilter.all:
//         return controller.totalTasks;
//       case TaskFilter.pending:
//         return controller.pendingTasks;
//       case TaskFilter.completed:
//         return controller.completedTasks;
//       case TaskFilter.overdue:
//         return controller.overdueTasks;
//     }
//   }
// }

