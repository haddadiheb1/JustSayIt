import 'package:hive_flutter/hive_flutter.dart';
import 'package:say_task/data/models/task_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the datasource
final localTaskDataSourceProvider = Provider<LocalTaskDataSource>((ref) {
  return LocalTaskDataSourceImpl();
});

abstract class LocalTaskDataSource {
  Future<void> init();
  List<TaskModel> getTasks();
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Stream<List<TaskModel>> watchTasks();
}

class LocalTaskDataSourceImpl implements LocalTaskDataSource {
  static const String boxName = 'tasks';

  @override
  Future<void> init() async {
    // Hive is already initialized in main.dart
    // Just verify the box is open
    if (!Hive.isBoxOpen(boxName)) {
      throw StateError('Hive box "$boxName" should be opened in main.dart');
    }
  }

  Box<TaskModel> get _box => Hive.box<TaskModel>(boxName);

  @override
  List<TaskModel> getTasks() {
    return _box.values.toList();
  }

  @override
  Future<void> addTask(TaskModel task) async {
    await _box.put(task.id, task);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await _box.put(task.id, task);
  }

  @override
  Stream<List<TaskModel>> watchTasks() {
    // Return a stream that emits the current list immediately,
    // then emits whenever the box changes
    return Stream.multi((controller) {
      // Emit current list immediately
      controller.add(_box.values.toList());

      // Listen to box changes and emit updated list
      final subscription = _box.watch().listen((event) {
        controller.add(_box.values.toList());
      });

      // Clean up when stream is cancelled
      controller.onCancel = () {
        subscription.cancel();
      };
    });
  }
}
