import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:just_say_it/domain/entities/task_category.dart';
import 'package:just_say_it/domain/entities/task_priority.dart';

part 'task.freezed.dart';

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    required DateTime scheduledDate,
    @Default(false) bool isCompleted,
    @Default(TaskCategory.defaultCategory) TaskCategory category,
    @Default(TaskPriority.medium) TaskPriority priority,
  }) = _Task;
}
