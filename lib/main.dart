import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:say_task/core/theme/app_theme.dart';
import 'package:say_task/presentation/screens/main_navigation_screen.dart';
import 'package:say_task/presentation/screens/onboarding_screen.dart';
import 'package:say_task/presentation/providers/settings_provider.dart';
import 'package:say_task/data/models/task_model.dart';
import 'package:say_task/data/models/note_model.dart';
import 'package:say_task/core/utils/notification_service.dart';
import 'package:say_task/core/services/background_service.dart';

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
  final settingsBox = await Hive.openBox('settings');

  // Initialize Background Service (Alarms)
  await BackgroundService.init();

  // Initialize Notifications
  final container = ProviderContainer();
  final notificationService = container.read(notificationServiceProvider);
  await notificationService.init();

  // Check onboarding status
  final onboardingComplete =
      settingsBox.get('onboarding_complete', defaultValue: false);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: VoiceTaskApp(showOnboarding: !onboardingComplete),
    ),
  );
}

class VoiceTaskApp extends ConsumerWidget {
  final bool showOnboarding;

  const VoiceTaskApp({
    super.key,
    required this.showOnboarding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Just Say It',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: showOnboarding
          ? const OnboardingScreen()
          : const MainNavigationScreen(),
    );
  }
}
