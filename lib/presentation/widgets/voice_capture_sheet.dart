import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:just_say_it/core/theme/app_theme.dart';
import 'package:just_say_it/presentation/providers/speech_provider.dart';

class VoiceCaptureSheet extends ConsumerWidget {
  const VoiceCaptureSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveText = ref.watch(speechStateProvider);
    final isListening = ref.watch(listeningStateProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Listening...",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
          const Gap(24),
          Text(
            liveText.isEmpty
                ? "Say something like 'Buy milk tomorrow at 5pm'"
                : liveText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: liveText.isEmpty ? Colors.grey : Colors.black87,
            ),
          ),
          const Gap(48),
          if (!isListening)
            const Text("Processing...", style: TextStyle(color: Colors.grey)),
          const Gap(24),
        ],
      ),
    );
  }
}
