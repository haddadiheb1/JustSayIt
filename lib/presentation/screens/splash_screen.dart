import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:say_task/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => widget.nextScreen,
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryIndigo,
              const Color(0xFF818CF8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Logo Container - Modern Squircle shape
                Container(
                  padding: const EdgeInsets.all(4), // Thin border effect
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2), // Glassy border
                    borderRadius: BorderRadius.circular(42),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(38), // Inner squircle
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(38),
                      child: Image.asset(
                        'assets/icon/icon.png',
                        width: 120, // Larger size
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      duration: 800.ms,
                      curve: Curves.elasticOut,
                      begin: const Offset(0.5, 0.5),
                    )
                    .then(delay: 500.ms)
                    .shimmer(
                      duration: 1500.ms,
                      color: Colors.white.withValues(alpha: 0.5),
                      angle: 0.8,
                    ),

                const Gap(40),

                // Title - Modern Font
                Text(
                  'Voice Tasks',
                  style: GoogleFonts.outfit(
                    // Using Outfit for modern look
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 300.ms).moveY(
                    begin: 30,
                    end: 0,
                    duration: 600.ms,
                    curve: Curves.easeOutCubic),

                const Gap(8),

                // Tagline
                Text(
                  'Turn your thoughts into actions',
                  style: GoogleFonts.inter(
                    // Clean Inter font
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 600.ms).moveY(
                    begin: 20,
                    end: 0,
                    duration: 600.ms,
                    curve: Curves.easeOutCubic),

                const Spacer(),

                // Loading / Version indicator
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white.withValues(alpha: 0.5),
                      strokeWidth: 2.5,
                    ),
                  ).animate().fadeIn(delay: 1000.ms),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
