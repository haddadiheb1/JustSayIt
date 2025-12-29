import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:just_say_it/domain/entities/task_category.dart';

class TaskModel extends HiveObject {
  final String id;
  final String title;
  final DateTime scheduledDate;
  final bool isCompleted;
  final int categoryIndex; // Store as int for Hive

  TaskModel({
    required this.id,
    required this.title,
    required this.scheduledDate,
    this.isCompleted = false,
    this.categoryIndex = 0, // Default category
  });

  factory TaskModel.create({
    required String title,
    required DateTime scheduledDate,
    TaskCategory category = TaskCategory.defaultCategory,
  }) {
    return TaskModel(
      id: const Uuid().v4(),
      title: title,
      scheduledDate: scheduledDate,
      isCompleted: false,
      categoryIndex: category.index,
    );
  }

  TaskCategory get category => TaskCategory.values[categoryIndex];

  TaskModel copyWith({
    String? title,
    DateTime? scheduledDate,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isCompleted: isCompleted ?? this.isCompleted,
      categoryIndex: this.categoryIndex,
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
      categoryIndex: fields[4] as int? ?? 0, // Default to 0 if not present
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(5) // Updated field count
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.scheduledDate)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.categoryIndex);
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
