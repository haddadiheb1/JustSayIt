import 'package:just_say_it/data/datasources/local_task_datasource.dart';
import 'package:just_say_it/data/models/task_model.dart';
import 'package:just_say_it/domain/entities/task.dart';
import 'package:just_say_it/domain/repositories/task_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final dataSource = ref.watch(localTaskDataSourceProvider);
  return TaskRepositoryImpl(dataSource);
});

class TaskRepositoryImpl implements TaskRepository {
  final LocalTaskDataSource _dataSource;

  TaskRepositoryImpl(this._dataSource);

  @override
  Future<void> init() => _dataSource.init();

  @override
  Future<List<Task>> getTasks() async {
    final models = _dataSource.getTasks();
    return models.map(_mapToEntity).toList();
  }

  @override
  Stream<List<Task>> watchTasks() {
    return _dataSource.watchTasks().map(
      (models) => models.map(_mapToEntity).toList(),
    );
  }

  @override
  Future<void> addTask(String title, DateTime dateTime) async {
    final model = TaskModel.create(title: title, scheduledDate: dateTime);
    await _dataSource.addTask(model);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _dataSource.deleteTask(id);
  }

  @override
  Future<void> updateTask(Task task) async {
    final model = _mapToModel(task);
    await _dataSource.updateTask(model);
  }

  @override
  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updatedTask);
  }

  Task _mapToEntity(TaskModel model) {
    return Task(
      id: model.id,
      title: model.title,
      scheduledDate: model.scheduledDate,
      isCompleted: model.isCompleted,
    );
  }

  TaskModel _mapToModel(Task entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      scheduledDate: entity.scheduledDate,
      isCompleted: entity.isCompleted,
    );
  }
}
