import 'package:just_say_it/domain/entities/task.dart';

abstract class TaskRepository {
  Future<void> init();
  Future<List<Task>> getTasks();
  Stream<List<Task>> watchTasks();
  Future<void> addTask(String title, DateTime dateTime);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<void> toggleTaskCompletion(Task task);
}
