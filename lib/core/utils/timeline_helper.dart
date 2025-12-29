import 'package:say_task/data/models/task_model.dart';

enum TimelineSection {
  overdue,
  today,
  tomorrow,
  thisWeek,
  later,
}

class TimelineGroup {
  final TimelineSection section;
  final String title;
  final List<TaskModel> tasks;

  TimelineGroup({
    required this.section,
    required this.title,
    required this.tasks,
  });
}

class TimelineHelper {
  static List<TimelineGroup> groupTasks(List<TaskModel> allTasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final endOfWeek = today.add(Duration(days: 7 - now.weekday));

    // Filter only pending tasks
    final pendingTasks = allTasks.where((t) => !t.isCompleted).toList();

    // Group tasks
    final overdue = <TaskModel>[];
    final todayTasks = <TaskModel>[];
    final tomorrowTasks = <TaskModel>[];
    final thisWeekTasks = <TaskModel>[];
    final laterTasks = <TaskModel>[];

    for (final task in pendingTasks) {
      final taskDate = DateTime(
        task.scheduledDate.year,
        task.scheduledDate.month,
        task.scheduledDate.day,
      );

      if (taskDate.isBefore(today)) {
        overdue.add(task);
      } else if (taskDate.isAtSameMomentAs(today)) {
        todayTasks.add(task);
      } else if (taskDate.isAtSameMomentAs(tomorrow)) {
        tomorrowTasks.add(task);
      } else if (taskDate.isAfter(tomorrow) &&
          taskDate.isBefore(endOfWeek.add(const Duration(days: 1)))) {
        thisWeekTasks.add(task);
      } else {
        laterTasks.add(task);
      }
    }

    // Sort each group by time
    for (final list in [
      overdue,
      todayTasks,
      tomorrowTasks,
      thisWeekTasks,
      laterTasks
    ]) {
      list.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    }

    // Build groups (only non-empty)
    final groups = <TimelineGroup>[];

    if (overdue.isNotEmpty) {
      groups.add(TimelineGroup(
        section: TimelineSection.overdue,
        title: 'Overdue',
        tasks: overdue,
      ));
    }
    if (todayTasks.isNotEmpty) {
      groups.add(TimelineGroup(
        section: TimelineSection.today,
        title: 'Today',
        tasks: todayTasks,
      ));
    }
    if (tomorrowTasks.isNotEmpty) {
      groups.add(TimelineGroup(
        section: TimelineSection.tomorrow,
        title: 'Tomorrow',
        tasks: tomorrowTasks,
      ));
    }
    if (thisWeekTasks.isNotEmpty) {
      groups.add(TimelineGroup(
        section: TimelineSection.thisWeek,
        title: 'This Week',
        tasks: thisWeekTasks,
      ));
    }
    if (laterTasks.isNotEmpty) {
      groups.add(TimelineGroup(
        section: TimelineSection.later,
        title: 'Later',
        tasks: laterTasks,
      ));
    }

    return groups;
  }
}
