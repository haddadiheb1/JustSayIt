import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:just_say_it/core/theme/app_theme.dart';
import 'package:just_say_it/core/utils/date_parser.dart';
import 'package:just_say_it/core/utils/notification_service.dart';
import 'package:just_say_it/core/utils/speech_service.dart';
import 'package:just_say_it/domain/entities/task.dart';
import 'package:just_say_it/presentation/providers/speech_provider.dart';
import 'package:just_say_it/presentation/providers/task_provider.dart';
import 'package:just_say_it/presentation/widgets/mic_button.dart';
import 'package:just_say_it/presentation/widgets/task_card.dart';
import 'package:just_say_it/presentation/widgets/task_confirm_sheet.dart';
import 'package:just_say_it/presentation/widgets/voice_capture_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize services
    Future.microtask(() {
      ref.read(initializeAppProvider);
      ref.read(notificationServiceProvider).init();
      ref.read(speechServiceProvider).init();
    });
  }

  void _startListening() async {
    final speechService = ref.read(speechServiceProvider);
    final notifier = ref.read(speechStateProvider.notifier);
    final isListeningNotifier = ref.read(listeningStateProvider.notifier);

    // Show listening sheet
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => const VoiceCaptureSheet(),
    );

    isListeningNotifier.setListening(true);
    notifier.update("");

    await speechService.startListening(onResult: (text) {
      notifier.update(text);
    });

    // Wait for a silence/pause logic or manual stop
    // For MVP, we'll rely on SpeechToText's auto stop or we can listen to status
    // Here we'll simulate a check: if speech stops, we close the sheet and parse.
    // Ideally we listen to "not listening" status.

    // Quick polling for sake of MVP simplicity or better yet:
    // SpeechToText usually stops automatically on platform.
    _waitForSpeechEnd();
  }

  void _waitForSpeechEnd() async {
    final speechService = ref.read(speechServiceProvider);

    // Wait until it stops listening
    while (speechService.isListening) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (!mounted) return;

    // Close listening sheet
    Navigator.of(context).pop();
    ref.read(listeningStateProvider.notifier).setListening(false);

    final text = ref.read(speechStateProvider);
    if (text.isNotEmpty) {
      _processVoiceCommand(text);
    }
  }

  void _processVoiceCommand(String text) {
    final result = DateTimeParser.parse(text);
    if (result.dateTime == null) {
      // If logic failed, maybe just show it as a note or ask again?
      // For MVP, we'll default to Today End of Day if null, or just let user pick in sheet.
      // The parser handles some defaults, but let's be safe.
      // Actually parser returns DateTime? so we handle it.
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TaskConfirmSheet(
        initialTitle: result.title,
        initialDate: result.dateTime ?? DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice Tasks"),
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 64, color: Colors.grey[300]),
                  const Gap(16),
                  Text(
                    "No tasks yet.\nTap the mic to add one.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // Group tasks
          final today = <Task>[];
          final upcoming = <Task>[];
          final completed = <Task>[];

          final now = DateTime.now();
          final startOfToday = DateTime(now.year, now.month, now.day);
          final endOfToday = startOfToday.add(const Duration(days: 1));

          for (final t in tasks) {
            if (t.isCompleted) {
              completed.add(t);
            } else if (t.scheduledDate.isBefore(endOfToday)) {
              today.add(t);
            } else {
              upcoming.add(t);
            }
          }

          // Sort by time
          today.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
          upcoming.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

          return ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              if (today.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Today",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue)),
                ),
                ...today.map((t) => TaskCard(task: t)),
              ],
              if (upcoming.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Upcoming",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue)),
                ),
                ...upcoming.map((t) => TaskCard(task: t)),
              ],
              if (completed.isNotEmpty) ...[
                ExpansionTile(
                  title: const Text("Completed",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  children: completed.map((t) => TaskCard(task: t)).toList(),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: MicButton(
        isListening: ref.watch(listeningStateProvider),
        onPressed: _startListening,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
