import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../model/task.dart';
import '../controllers/task_controller.dart';
import '../utils/accessibility_utils.dart';

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
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

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
          color: Colors.blue,
          icon: Icons.edit,
          alignment: Alignment.centerLeft,
          label: 'Edit tugas',
        ),
        secondaryBackground: _buildSwipeBackground(
          color: Colors.red,
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
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: _getBorderColor(), width: 1.5),
            ),
            child: AccessibilityUtils.ensureMinTouchTarget(
              child: InkWell(
                onTap: onTap,
                onLongPress: onEdit,
                borderRadius: BorderRadius.circular(12),
                // Performance optimization: Add splash and highlight colors
                splashColor: _getStatusColor().withValues(alpha: 0.1),
                highlightColor: _getStatusColor().withValues(alpha: 0.05),
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(16),
                  child: AccessibilityUtils.mergeSemantics(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Checkbox untuk toggle status
                        _buildCheckbox(taskController),
                        const SizedBox(width: 12),

                        // Konten utama tugas
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Judul tugas
                              _buildTitle(),
                              AccessibilityUtils.createAccessibleSpacer(
                                height: 4,
                              ),

                              // Mata pelajaran
                              _buildSubject(),
                              AccessibilityUtils.createAccessibleSpacer(
                                height: 8,
                              ),

                              // Deskripsi (jika ada)
                              if (task.description.isNotEmpty) ...[
                                _buildDescription(),
                                AccessibilityUtils.createAccessibleSpacer(
                                  height: 8,
                                ),
                              ],

                              // Deadline dan status indicators
                              _buildDeadlineRow(),
                            ],
                          ),
                        ),

                        // Status indicator
                        _buildStatusIndicator(),
                      ],
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

  /// Build checkbox untuk toggle completion status
  Widget _buildCheckbox(TaskController controller) {
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
        child: Transform.scale(
          scale: 1.3, // Slightly larger for better accessibility
          child: Checkbox(
            value: task.isCompleted,
            onChanged: (value) {
              controller.toggleTaskStatus(task.id);
              AccessibilityUtils.announceMessage(
                value == true
                    ? 'Tugas ${task.title} ditandai selesai'
                    : 'Tugas ${task.title} ditandai belum selesai',
              );
            },
            activeColor: _getStatusColor(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            materialTapTargetSize: MaterialTapTargetSize.padded,
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
          fontSize: 18, // Slightly larger for better readability
          fontWeight: FontWeight.w600,
          color: task.isCompleted ? Colors.grey[600] : Colors.black87,
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          decorationColor: Colors.grey[600],
          height: 1.3, // Better line height for accessibility
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Build mata pelajaran dengan chip styling
  Widget _buildSubject() {
    return AccessibilityUtils.excludeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _getSubjectColor().withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getSubjectColor().withValues(alpha: 0.3),
            width: 1.5, // Slightly thicker border for better visibility
          ),
        ),
        child: Text(
          task.subject,
          style: TextStyle(
            fontSize: 13, // Slightly larger for better readability
            fontWeight: FontWeight.w600,
            color: _getSubjectColor(),
            height: 1.2,
          ),
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
          fontSize: 15, // Slightly larger for better readability
          color: task.isCompleted ? Colors.grey[500] : Colors.grey[700],
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          decorationColor: Colors.grey[500],
          height: 1.4, // Better line height
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Build baris deadline dengan icon dan status
  Widget _buildDeadlineRow() {
    // Performance optimization: Reuse DateFormat
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return AccessibilityUtils.excludeSemantics(
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            size: 18, // Slightly larger icon
            color: _getDeadlineColor(),
            semanticLabel: 'Deadline',
          ),
          const SizedBox(width: 6),
          Text(
            dateFormat.format(task.deadline),
            style: TextStyle(
              fontSize: 13, // Slightly larger for better readability
              color: _getDeadlineColor(),
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          if (task.isOverdue && !task.isCompleted) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red, width: 1),
              ),
              child: const Text(
                'TERLAMBAT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ] else if (task.isDueSoon && !task.isCompleted) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: const Text(
                'SEGERA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build status indicator di sisi kanan
  Widget _buildStatusIndicator() {
    return AccessibilityUtils.excludeSemantics(
      child: Container(
        width: 6, // Slightly wider for better visibility
        height: 60,
        decoration: BoxDecoration(
          color: _getStatusColor(),
          borderRadius: BorderRadius.circular(3),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32, semanticLabel: label),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
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
            title: AccessibilityUtils.createSemanticWidget(
              header: true,
              label: 'Konfirmasi Hapus Tugas',
              child: const Text('Hapus Tugas'),
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus tugas "${task.title}"?',
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              AccessibilityUtils.ensureMinTouchTarget(
                child:
                    TextButton(
                      onPressed: () {
                        AccessibilityUtils.announceMessage('Batal hapus tugas');
                        Navigator.of(context).pop(false);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(fontSize: 16),
                      ),
                    ).asSemanticButton(
                      label: 'Batal',
                      hint: 'Batalkan penghapusan tugas',
                    ),
              ),
              AccessibilityUtils.ensureMinTouchTarget(
                child:
                    TextButton(
                      onPressed: () {
                        AccessibilityUtils.announceMessage(
                          'Konfirmasi hapus tugas ${task.title}',
                        );
                        Navigator.of(context).pop(true);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(fontSize: 16),
                      ),
                    ).asSemanticButton(
                      label: 'Hapus Tugas',
                      hint: 'Konfirmasi penghapusan tugas ini',
                    ),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Get warna berdasarkan status tugas
  Color _getStatusColor() {
    if (task.isCompleted) {
      return Colors.green;
    } else if (task.isOverdue) {
      return Colors.red;
    } else if (task.isDueSoon) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  /// Get warna border berdasarkan status
  Color _getBorderColor() {
    return _getStatusColor().withValues(alpha: 0.3);
  }

  /// Get warna untuk deadline text
  Color _getDeadlineColor() {
    if (task.isCompleted) {
      return Colors.grey[500]!;
    } else if (task.isOverdue) {
      return Colors.red;
    } else if (task.isDueSoon) {
      return Colors.orange;
    } else {
      return Colors.grey[600]!;
    }
  }

  /// Get warna untuk mata pelajaran berdasarkan hash
  Color _getSubjectColor() {
    // Generate warna berdasarkan hash dari nama mata pelajaran
    final hash = task.subject.hashCode;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.brown,
    ];
    return colors[hash.abs() % colors.length];
  }
}
