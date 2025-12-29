import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:say_task/core/theme/app_theme.dart';

class MicButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isListening;

  const MicButton({
    super.key,
    required this.onPressed,
    required this.isListening,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: isListening ? 80 : 64,
        width: isListening ? 80 : 64,
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.4),
              blurRadius: isListening ? 20 : 10,
              spreadRadius: isListening ? 5 : 2,
            )
          ],
        ),
        child: Icon(
          isListening ? Icons.graphic_eq : Icons.mic,
          color: Colors.white,
          size: 32,
        ),
      )
          .animate(
            target: isListening ? 1 : 0,
          )
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 800),
          )
          .then(delay: const Duration(milliseconds: 0))
          .shimmer(duration: const Duration(seconds: 2)), // Pulse effect
    );
  }
}
