import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_say_it/data/models/task_model.dart';
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
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskModelAdapter());
    }
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<TaskModel>(boxName);
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
    // A simple way to stream changes from Hive
    // We listen to the box events and map them to the full list
    return _box.watch().map((event) => _box.values.toList());
  }
}
