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
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  _getStatusColor().withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor().withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
              border: Border.all(color: _getBorderColor(), width: 2),
            ),
            child: AccessibilityUtils.ensureMinTouchTarget(
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: onTap,
                  onLongPress: onEdit,
                  borderRadius: BorderRadius.circular(16),
                  splashColor: _getStatusColor().withValues(alpha: 0.1),
                  highlightColor: _getStatusColor().withValues(alpha: 0.05),
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(20),
                    child: AccessibilityUtils.mergeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row dengan checkbox dan status
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildModernCheckbox(taskController),
                              const SizedBox(width: 16),
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
                              _buildPriorityIndicator(),
                            ],
                          ),

                          // Deskripsi (jika ada)
                          if (task.description.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildDescription(),
                          ],

                          const SizedBox(height: 16),

                          // Footer dengan deadline dan actions
                          Row(
                            children: [
                              Expanded(child: _buildModernDeadlineRow()),
                              const SizedBox(width: 12),
                              _buildActionButtons(),
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
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: task.isCompleted ? _getStatusColor() : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _getStatusColor(), width: 2.5),
            boxShadow: task.isCompleted
                ? [
                    BoxShadow(
                      color: _getStatusColor().withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
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
              borderRadius: BorderRadius.circular(8),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: task.isCompleted
                    ? Icon(
                        Icons.check,
                        key: const ValueKey('checked'),
                        color: Colors.white,
                        size: 18,
                      )
                    : const SizedBox(key: ValueKey('unchecked')),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build checkbox untuk toggle completion status (fallback)
  Widget _buildCheckbox(TaskController controller) {
    return _buildModernCheckbox(controller);
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

  /// Build mata pelajaran dengan chip styling modern
  Widget _buildSubject() {
    return AccessibilityUtils.excludeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getSubjectColor().withValues(alpha: 0.15),
              _getSubjectColor().withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getSubjectColor().withValues(alpha: 0.4),
            width: 1.5,
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
                fontSize: 13,
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

  /// Build modern deadline row dengan styling yang lebih menarik
  Widget _buildModernDeadlineRow() {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return AccessibilityUtils.excludeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _getDeadlineColor().withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getDeadlineColor().withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 16,
              color: _getDeadlineColor(),
              semanticLabel: 'Deadline',
            ),
            const SizedBox(width: 6),
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

  /// Build baris deadline dengan icon dan status (fallback)
  Widget _buildDeadlineRow() {
    return _buildModernDeadlineRow();
  }

  /// Build priority indicator modern
  Widget _buildPriorityIndicator() {
    return AccessibilityUtils.excludeSemantics(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getStatusColor().withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getStatusColor().withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(_getStatusIcon(), size: 18, color: _getStatusColor()),
          ),
          if (task.isOverdue && !task.isCompleted) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'LATE',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ] else if (task.isDueSoon && !task.isCompleted) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'SOON',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build action buttons untuk edit dan delete
  Widget _buildActionButtons() {
    return AccessibilityUtils.excludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(18),
                child: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: () async {
                  final confirmed = await _showDeleteConfirmation(Get.context!);
                  if (confirmed) {
                    onDelete?.call();
                  }
                },
                borderRadius: BorderRadius.circular(18),
                child: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build status indicator di sisi kanan (fallback)
  Widget _buildStatusIndicator() {
    return _buildPriorityIndicator();
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

  /// Get icon berdasarkan status tugas
  IconData _getStatusIcon() {
    if (task.isCompleted) {
      return Icons.check_circle;
    } else if (task.isOverdue) {
      return Icons.warning;
    } else if (task.isDueSoon) {
      return Icons.schedule;
    } else {
      return Icons.pending_actions;
    }
  }
}
