import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class TaskModel extends HiveObject {
  final String id;
  final String title;
  final DateTime scheduledDate;
  final bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.scheduledDate,
    this.isCompleted = false,
  });

  factory TaskModel.create({
    required String title,
    required DateTime scheduledDate,
  }) {
    return TaskModel(
      id: const Uuid().v4(),
      title: title,
      scheduledDate: scheduledDate,
      isCompleted: false,
    );
  }

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
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.scheduledDate)
      ..writeByte(3)
      ..write(obj.isCompleted);
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
