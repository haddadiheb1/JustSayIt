import 'package:say_task/domain/entities/task.dart';
import 'package:say_task/domain/entities/task_category.dart';

abstract class TaskRepository {
  Future<void> init();
  Future<List<Task>> getTasks();
  Stream<List<Task>> watchTasks();
  Future<void> addTask(String title, DateTime dateTime,
      {TaskCategory? category});
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<void> toggleTaskCompletion(Task task);
}
