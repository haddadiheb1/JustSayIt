import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:say_task/domain/entities/task_category.dart';
import 'package:say_task/domain/entities/task_priority.dart';

class TaskModel extends HiveObject {
  final String id;
  final String title;
  final DateTime scheduledDate;
  final DateTime? completedAt;
  final bool isCompleted;
  final int categoryIndex; // Store as int for Hive
  final int priorityIndex; // Store as int for Hive

  TaskModel({
    required this.id,
    required this.title,
    required this.scheduledDate,
    this.completedAt,
    this.isCompleted = false,
    this.categoryIndex = 0, // Default category
    this.priorityIndex = 1, // Default priority (Medium)
  });

  factory TaskModel.create({
    required String title,
    required DateTime scheduledDate,
    TaskCategory category = TaskCategory.defaultCategory,
    TaskPriority priority = TaskPriority.medium,
  }) {
    return TaskModel(
      id: const Uuid().v4(),
      title: title,
      scheduledDate: scheduledDate,
      isCompleted: false,
      categoryIndex: category.index,
      priorityIndex: priority.index,
    );
  }

  TaskCategory get category => TaskCategory.values[categoryIndex];
  TaskPriority get priority => TaskPriority.values[priorityIndex];

  TaskModel copyWith({
    String? title,
    DateTime? scheduledDate,
    DateTime? completedAt,
    bool? isCompleted,
    int? categoryIndex,
    int? priorityIndex,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      categoryIndex: categoryIndex ?? this.categoryIndex,
      priorityIndex: priorityIndex ?? this.priorityIndex,
    );
  }
}

// Manual Hive TypeAdapter (replaces generated code)
class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 0;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      scheduledDate: fields[2] as DateTime,
      isCompleted: fields[3] as bool,
      categoryIndex: fields[4] as int? ?? 0,
      priorityIndex: fields[5] as int? ?? 1,
      completedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(7) // Updated field count
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.scheduledDate)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.categoryIndex)
      ..writeByte(5)
      ..write(obj.priorityIndex)
      ..writeByte(6)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
