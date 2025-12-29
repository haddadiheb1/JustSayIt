import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:just_say_it/domain/entities/task.dart';

class WidgetSyncService {
  // Provider name references the class name in AndroidManifest
  static const String _androidWidgetName = 'TaskWidgetProvider';

  Future<void> updateWidget(List<Task> tasks) async {
    try {
      debugPrint('🔄 Syncing tasks to widget...');
      // Filter uncompleted tasks
      final uncompleted = tasks.where((t) => !t.isCompleted).toList();

      // Sort by Priority (High > Low) then Date
      uncompleted.sort((a, b) {
        int priorityComp = b.priority.value.compareTo(a.priority.value);
        if (priorityComp != 0) return priorityComp;
        return a.scheduledDate.compareTo(b.scheduledDate);
      });

      // Take top 10 to avoid overcrowding
      final displayTasks = uncompleted.take(10).toList();

      final jsonList = displayTasks.map((t) {
        // Convert color to hex string #AARRGGBB
        final colorValue =
            t.priority.color.value.toRadixString(16).padLeft(8, '0');
        // If today, show time. If future, show date?
        final isToday = DateUtils.isSameDay(t.scheduledDate, DateTime.now());
        final timeStr = isToday
            ? DateFormat('HH:mm').format(t.scheduledDate)
            : DateFormat('MMM d').format(t.scheduledDate);

        return {
          'title': t.title,
          'time': timeStr,
          'color': '#$colorValue',
        };
      }).toList();

      final jsonString = jsonEncode(jsonList);

      await HomeWidget.saveWidgetData<String>('tasks_json', jsonString);
      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        androidName: _androidWidgetName,
      );
      debugPrint('✅ Widget synced successfully');
    } catch (e) {
      debugPrint('❌ Error syncing widget: $e');
    }
  }
}
