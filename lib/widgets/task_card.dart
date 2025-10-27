import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../model/task.dart';
import '../controllers/task_controller.dart';

/// Widget kartu untuk menampilkan informasi tugas
/// Menyediakan checkbox untuk toggle status, visual indicators,
/// dan swipe actions untuk edit/delete
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    return Dismissible(
      key: Key(task.id),
      background: _buildSwipeBackground(
        color: Colors.blue,
        icon: Icons.edit,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        color: Colors.red,
        icon: Icons.delete,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right - Edit
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
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _getBorderColor(), width: 1.5),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                      const SizedBox(height: 4),

                      // Mata pelajaran
                      _buildSubject(),
                      const SizedBox(height: 8),

                      // Deskripsi (jika ada)
                      if (task.description.isNotEmpty) ...[
                        _buildDescription(),
                        const SizedBox(height: 8),
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
    );
  }

  /// Build checkbox untuk toggle completion status
  Widget _buildCheckbox(TaskController controller) {
    return Transform.scale(
      scale: 1.2,
      child: Checkbox(
        value: task.isCompleted,
        onChanged: (value) {
          controller.toggleTaskStatus(task.id);
        },
        activeColor: _getStatusColor(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  /// Build judul tugas dengan styling berdasarkan status
  Widget _buildTitle() {
    return Text(
      task.title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: task.isCompleted ? Colors.grey[600] : Colors.black87,
        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
        decorationColor: Colors.grey[600],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build mata pelajaran dengan chip styling
  Widget _buildSubject() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getSubjectColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getSubjectColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        task.subject,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _getSubjectColor(),
        ),
      ),
    );
  }

  /// Build deskripsi tugas
  Widget _buildDescription() {
    return Text(
      task.description,
      style: TextStyle(
        fontSize: 14,
        color: task.isCompleted ? Colors.grey[500] : Colors.grey[700],
        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
        decorationColor: Colors.grey[500],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build baris deadline dengan icon dan status
  Widget _buildDeadlineRow() {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Row(
      children: [
        Icon(Icons.schedule, size: 16, color: _getDeadlineColor()),
        const SizedBox(width: 4),
        Text(
          dateFormat.format(task.deadline),
          style: TextStyle(
            fontSize: 12,
            color: _getDeadlineColor(),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        if (task.isOverdue && !task.isCompleted) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'TERLAMBAT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ] else if (task.isDueSoon && !task.isCompleted) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'SEGERA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Build status indicator di sisi kanan
  Widget _buildStatusIndicator() {
    return Container(
      width: 4,
      height: 60,
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Build background untuk swipe actions
  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  /// Show confirmation dialog untuk delete
  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Tugas'),
            content: Text(
              'Apakah Anda yakin ingin menghapus tugas "${task.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Hapus'),
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
    return _getStatusColor().withOpacity(0.3);
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
