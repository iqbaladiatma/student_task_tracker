import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../model/task.dart';
import '../controllers/task_controller.dart';
import '../utils/accessibility_utils.dart';
import '../utils/colors.dart'; // Import file colors.dart

// Palet warna sekarang diimpor dari utils/colors.dart

/// Widget kartu untuk menampilkan informasi tugas
/// Menyediakan checkbox untuk toggle status, visual indicators,
/// dan swipe actions untuk edit/delete
/// Performance optimized with const constructors and efficient rebuilds
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    required this.task,
    super.key,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    // Performance optimization: Create DateFormat once and reuse
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    // Create comprehensive semantic label for the task card
    final semanticLabel = AccessibilityUtils.getTaskCardSemantics(
      title: task.title,
      subject: task.subject,
      deadline: dateFormat.format(task.deadline),
      isCompleted: task.isCompleted,
      isOverdue: task.isOverdue,
      isDueSoon: task.isDueSoon,
      description: task.description.isNotEmpty ? task.description : null,
    );

    return Semantics(
      label: semanticLabel,
      button: true,
      onTap: onTap,
      onLongPress: onEdit,
      child: Dismissible(
        key: Key(task.id),
        background: _buildSwipeBackground(
          color: primaryColor, // Use consistent blue for edit
          icon: Icons.edit,
          alignment: Alignment.centerLeft,
          label: 'Edit tugas',
        ),
        secondaryBackground: _buildSwipeBackground(
          color: accentColorRed, // Use consistent red for delete
          icon: Icons.delete,
          alignment: Alignment.centerRight,
          label: 'Hapus tugas',
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            // Swipe right - Edit
            AccessibilityUtils.announceMessage(
              'Membuka edit tugas ${task.title}',
            );
            onEdit?.call();
            return false; // Don't dismiss
          } else if (direction == DismissDirection.endToStart) {
            // Swipe left - Delete
            return await _showDeleteConfirmation(context);
          }
          return false;
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            onDelete?.call();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                // Subtle gradient based on status or just white/light grey
                colors: [
                  Colors.white,
                  _getStatusColor().withOpacity(0.05), // Softer gradient
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08), // Softer shadow
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  spreadRadius: -2, // Make shadow tighter
                ),
              ],
              border: Border.all(
                  color: _getBorderColor().withOpacity(0.5),
                  width: 1.5), // Softer border
            ),
            child: AccessibilityUtils.ensureMinTouchTarget(
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: onTap,
                  onLongPress: onEdit,
                  borderRadius: BorderRadius.circular(16),
                  splashColor: _getStatusColor().withOpacity(0.1),
                  highlightColor: _getStatusColor().withOpacity(0.05),
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16), // Slightly reduced padding
                    child: AccessibilityUtils.mergeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row dengan checkbox dan status
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildModernCheckbox(taskController),
                              const SizedBox(width: 12), // Adjusted spacing
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTitle(),
                                    const SizedBox(height: 4),
                                    _buildSubject(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8), // Spacing before indicator
                              _buildPriorityIndicator(),
                            ],
                          ),

                          // Deskripsi (jika ada)
                          if (task.description.isNotEmpty) ...[
                            const SizedBox(height: 10), // Adjusted spacing
                            _buildDescription(),
                          ],

                          const SizedBox(height: 12), // Adjusted spacing

                          // Footer dengan deadline dan actions
                          Row(
                            children: [
                              Expanded(child: _buildModernDeadlineRow()),
                              const SizedBox(width: 12),
                              // Optionally hide buttons until long press or hover?
                              // _buildActionButtons(),
                            ],
                          ),
                        ],
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
  }

  /// Build modern checkbox dengan animasi dan styling yang lebih menarik
  Widget _buildModernCheckbox(TaskController controller) {
    return AccessibilityUtils.ensureMinTouchTarget(
      child: Semantics(
        button: true,
        label: task.isCompleted
            ? AccessibilityUtils.taskCompletedLabel
            : AccessibilityUtils.taskPendingLabel,
        hint: task.isCompleted
            ? 'Ketuk untuk menandai tugas belum selesai'
            : 'Ketuk untuk menandai tugas selesai',
        onTap: () {
          final newStatus = !task.isCompleted;
          controller.toggleTaskStatus(task.id);
          AccessibilityUtils.announceMessage(
            newStatus
                ? 'Tugas ${task.title} ditandai selesai'
                : 'Tugas ${task.title} ditandai belum selesai',
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: 24, // Slightly smaller checkbox
          height: 24,
          decoration: BoxDecoration(
            color: task.isCompleted ? _getStatusColor() : Colors.transparent,
            borderRadius: BorderRadius.circular(6), // Less rounded
            border: Border.all(
                color: task.isCompleted
                    ? _getStatusColor()
                    : textColorSecondary.withOpacity(0.5), // Softer border when unchecked
                width: 2.0), // Slightly thinner border
            boxShadow: task.isCompleted
                ? [
                    BoxShadow(
                      color: _getStatusColor().withOpacity(0.3),
                      blurRadius: 6, // Softer shadow
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: () {
                final newStatus = !task.isCompleted;
                controller.toggleTaskStatus(task.id);
                AccessibilityUtils.announceMessage(
                  newStatus
                      ? 'Tugas ${task.title} ditandai selesai'
                      : 'Tugas ${task.title} ditandai belum selesai',
                );
              },
              borderRadius: BorderRadius.circular(6),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: task.isCompleted
                    ? const Icon(
                        Icons.check,
                        key: ValueKey('checked'),
                        color: Colors.white,
                        size: 16, // Smaller check icon
                      )
                    : const SizedBox(key: ValueKey('unchecked')),
              ),
            ),
          ),
        ),
      ),
    );
  }


  /// Build judul tugas dengan styling berdasarkan status
  Widget _buildTitle() {
    return AccessibilityUtils.excludeSemantics(
      child: Text(
        task.title,
        style: TextStyle(
          fontSize: 17, // Slightly adjusted size
          fontWeight: FontWeight.w600,
          color: task.isCompleted ? textColorSecondary : textColorPrimary, // Use palette colors
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          decorationColor: textColorSecondary,
          height: 1.3,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Build mata pelajaran dengan chip styling modern
  Widget _buildSubject() {
    return AccessibilityUtils.excludeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Adjusted padding
        decoration: BoxDecoration(
          color: _getSubjectColor().withOpacity(0.1), // Solid lighter color
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getSubjectColor().withOpacity(0.3), // Slightly stronger border
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_outlined, size: 14, color: _getSubjectColor()),
            const SizedBox(width: 4),
            Text(
              task.subject,
              style: TextStyle(
                fontSize: 12, // Slightly smaller
                fontWeight: FontWeight.w600,
                color: _getSubjectColor(),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build deskripsi tugas
  Widget _buildDescription() {
    return AccessibilityUtils.excludeSemantics(
      child: Text(
        task.description,
        style: TextStyle(
          fontSize: 14, // Adjusted size
          color: task.isCompleted ? textColorSecondary.withOpacity(0.7) : textColorSecondary,
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          decorationColor: textColorSecondary.withOpacity(0.7),
          height: 1.4, // Better line height
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Build modern deadline row dengan styling yang lebih menarik
  Widget _buildModernDeadlineRow() {
    final dateFormat = DateFormat('dd MMM, HH:mm', 'id_ID'); // Shorter format

    return AccessibilityUtils.excludeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Adjusted padding
        decoration: BoxDecoration(
          color: _getDeadlineColor().withOpacity(0.1), // More subtle background
          borderRadius: BorderRadius.circular(12),
          // Removed border for a cleaner look
          // border: Border.all(
          //   color: _getDeadlineColor().withOpacity(0.2),
          //   width: 1,
          // ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 14, // Slightly smaller icon
              color: _getDeadlineColor(),
              semanticLabel: 'Deadline',
            ),
            const SizedBox(width: 4), // Reduced spacing
            Flexible(
              child: Text(
                dateFormat.format(task.deadline),
                style: TextStyle(
                  fontSize: 12,
                  color: _getDeadlineColor(),
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// Build priority indicator modern
  Widget _buildPriorityIndicator() {
    // Only show indicator if pending and overdue/due soon
    if (task.isCompleted || (!task.isOverdue && !task.isDueSoon)) {
      return const SizedBox(width: 24); // Placeholder for alignment
    }

    String text;
    Color bgColor;
    IconData iconData;

    if (task.isOverdue) {
      text = 'LATE';
      bgColor = accentColorRed;
      iconData = Icons.warning_amber_rounded;
    } else { // isDueSoon
      text = 'SOON';
      bgColor = pendingColor; // Use Oranye from palette
      iconData = Icons.schedule_rounded;
    }

    return AccessibilityUtils.excludeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, size: 12, color: bgColor),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: bgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// Build background untuk swipe actions
  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Match card margin
      decoration: BoxDecoration(
        color: color.withOpacity(0.9), // Slightly transparent
        borderRadius: BorderRadius.circular(16), // Match card border radius
      ),
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28), // Slightly smaller icon
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600, // Adjusted weight
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show confirmation dialog untuk delete
  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    AccessibilityUtils.announceMessage('Dialog konfirmasi hapus tugas');

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Rounded corners
            title: AccessibilityUtils.createSemanticWidget(
              header: true,
              label: 'Konfirmasi Hapus Tugas',
              child: const Row( // Add icon to title
                children: [
                  Icon(Icons.delete_forever_outlined, color: accentColorRed),
                  SizedBox(width: 8),
                  Text('Hapus Tugas'),
                ],
              ),
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus tugas "${task.title}"?\nTindakan ini tidak dapat dibatalkan.',
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            actions: [
              TextButton(
                onPressed: () {
                  AccessibilityUtils.announceMessage('Batal hapus tugas');
                  Navigator.of(context).pop(false);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(fontSize: 15, color: textColorSecondary),
                ),
              ).asSemanticButton(
                label: 'Batal',
                hint: 'Batalkan penghapusan tugas',
              ),
              ElevatedButton( // Use ElevatedButton for delete action
                onPressed: () {
                  AccessibilityUtils.announceMessage(
                    'Konfirmasi hapus tugas ${task.title}',
                  );
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColorRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Hapus',
                  style: TextStyle(fontSize: 15),
                ),
              ).asSemanticButton(
                label: 'Hapus Tugas',
                hint: 'Konfirmasi penghapusan tugas ini',
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Get warna berdasarkan status tugas
  Color _getStatusColor() {
    if (task.isCompleted) {
      return completedColor;
    } else if (task.isOverdue) {
      return accentColorRed;
    } else if (task.isDueSoon) {
      return pendingColor;
    } else {
      return primaryColor;
    }
  }

  /// Get warna border berdasarkan status
  Color _getBorderColor() {
    return _getStatusColor();
  }

  /// Get warna untuk deadline text
  Color _getDeadlineColor() {
    if (task.isCompleted) {
      return textColorSecondary.withOpacity(0.7);
    } else if (task.isOverdue) {
      return accentColorRed;
    } else if (task.isDueSoon) {
      return pendingColor;
    } else {
      return textColorSecondary; // Default subtle grey
    }
  }

  /// Get warna untuk mata pelajaran berdasarkan hash
  Color _getSubjectColor() {
    // Generate warna berdasarkan hash dari nama mata pelajaran
    final hash = task.subject.hashCode;
    final colors = [
      Colors.blue.shade700,
      Colors.green.shade700,
      Colors.purple.shade700,
      Colors.orange.shade800,
      Colors.teal.shade700,
      Colors.indigo.shade700,
      Colors.pink.shade700,
      Colors.brown.shade700,
    ];
    return colors[hash.abs() % colors.length];
  }

}

