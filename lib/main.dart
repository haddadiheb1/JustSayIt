import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_say_it/core/theme/app_theme.dart';
import 'package:just_say_it/presentation/screens/main_navigation_screen.dart';
import 'package:just_say_it/data/models/task_model.dart';
import 'package:just_say_it/data/models/note_model.dart';

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

  runApp(const ProviderScope(child: VoiceTaskApp()));
}

class VoiceTaskApp extends StatelessWidget {
  const VoiceTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice To Task',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainNavigationScreen(),
    );
  }
}
