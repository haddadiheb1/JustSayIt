import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:say_task/data/models/task_model.dart';
import 'package:say_task/domain/entities/task_priority.dart';

void main() {
  group('TaskModelAdapter', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_test');
      Hive.init(tempDir.path);
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TaskModelAdapter());
      }
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      await tempDir.delete(recursive: true);
    });

    test('should save and restore task priority correctly', () async {
      final box = await Hive.openBox<TaskModel>('test_tasks');

      final task = TaskModel.create(
        title: 'Test Task',
        scheduledDate: DateTime.now(),
        priority:
            TaskPriority.high, // Use High (index 2) to verify it's persisted
      );

      await box.put('task_1', task);
      await box.close(); // Close to ensure write is committed

      final box2 = await Hive.openBox<TaskModel>('test_tasks');
      final retrievedTask = box2.get('task_1');

      expect(retrievedTask, isNotNull);
      expect(retrievedTask!.priority, equals(TaskPriority.high));
      expect(retrievedTask.priorityIndex, equals(2));

      await box2.close();
    });

    test('should save and restore low priority correctly', () async {
      final box = await Hive.openBox<TaskModel>('test_tasks_low');

      final task = TaskModel.create(
        title: 'Test Task Low',
        scheduledDate: DateTime.now(),
        priority: TaskPriority.low, // Use Low (index 0)
      );

      await box.put('task_low', task);
      await box.close();

      final box2 = await Hive.openBox<TaskModel>('test_tasks_low');
      final retrievedTask = box2.get('task_low');

      expect(retrievedTask, isNotNull);
      expect(retrievedTask!.priority, equals(TaskPriority.low));
      expect(retrievedTask.priorityIndex, equals(0));

      await box2.close();
    });
  });
}
