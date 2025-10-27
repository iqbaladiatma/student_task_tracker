import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late String subject;

  @HiveField(4)
  late DateTime deadline;

  @HiveField(5)
  late bool isCompleted;

  @HiveField(6)
  late DateTime createdAt;

  @HiveField(7)
  late DateTime updatedAt;

  Task({
    String? id,
    required this.title,
    required this.subject,
    required this.deadline,
    this.description = '',
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    this.id = id ?? const Uuid().v4();
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  // Default constructor for Hive
  Task.empty();

  /// Computed property to check if task is overdue
  /// Returns true if task is not completed and current time is after deadline
  bool get isOverdue {
    return !isCompleted && DateTime.now().isAfter(deadline);
  }

  /// Computed property to check if task is due soon (within 24 hours)
  /// Returns true if task is not completed and deadline is within 1 day
  bool get isDueSoon {
    if (isCompleted) return false;
    final now = DateTime.now();
    final difference = deadline.difference(now);
    return difference.inHours <= 24 && difference.inHours > 0;
  }

  /// Update the task's updatedAt timestamp
  void touch() {
    updatedAt = DateTime.now();
  }

  /// Toggle the completion status of the task
  void toggleCompletion() {
    isCompleted = !isCompleted;
    touch();
  }

  /// Create a copy of the task with updated fields
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? subject,
    DateTime? deadline,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Task{id: $id, title: $title, subject: $subject, deadline: $deadline, isCompleted: $isCompleted}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
