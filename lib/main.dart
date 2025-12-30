import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:say_task/core/theme/app_theme.dart';
import 'package:say_task/presentation/screens/main_navigation_screen.dart';
import 'package:say_task/presentation/providers/settings_provider.dart';
import 'package:say_task/data/models/task_model.dart';
import 'package:say_task/data/models/note_model.dart';
import 'package:say_task/core/utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TaskModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(NoteModelAdapter());
  }

  // Open boxes
  await Hive.openBox<TaskModel>('tasks');
  await Hive.openBox<NoteModel>('notes');

  // Initialize Notifications
  final container = ProviderContainer();
  final notificationService = container.read(notificationServiceProvider);
  await notificationService.init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const VoiceTaskApp(),
    ),
  );
}

class VoiceTaskApp extends ConsumerWidget {
  const VoiceTaskApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Just Say It',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainNavigationScreen(),
    );
  }
}
