import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:say_task/core/theme/app_theme.dart';
import 'package:say_task/presentation/screens/main_navigation_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _completeOnboarding() async {
    final box = await Hive.openBox('settings');
    await box.put('onboarding_complete', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Warm/Cozy background color (Light Gray/Off-white as requested)
    // Using a slightly warmer tint than pure grey
    final backgroundColor = const Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                physics:
                    const ClampingScrollPhysics(), // Prevent overscroll bounce for calmer feel
                children: [
                  _buildWelcomePage(),
                  _buildHowItWorksPage(),
                ],
              ),
            ),
            // Pagination Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppTheme.primaryIndigo
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const Gap(32),
            // Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      _currentPage == 0 ? _nextPage : _completeOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryIndigo,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shadowColor: AppTheme.primaryIndigo.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Softer corners
                    ),
                  ),
                  child: Text(
                    _currentPage == 0 ? "Next" : "Start speaking",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Soft Illustration / Animated Mic
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.primaryIndigo.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inner glow
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryIndigo.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
                Icon(
                  Icons.mic_rounded,
                  size: 80,
                  color: AppTheme.primaryIndigo,
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 2000.ms),
              ],
            ),
          ).animate().fadeIn(duration: 800.ms).scale(),

          const Gap(48),

          Text(
            "Turn your thoughts\ninto tasks",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748), // Dark Gray for text
              height: 1.2,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

          const Gap(16),

          Text(
            "Just speak. We'll help you organize everything.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF718096), // Medium Gray
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }

  Widget _buildHowItWorksPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "How it works",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ).animate().fadeIn().slideY(begin: -0.2),
          const Gap(48),
          _buildStepItem(
            icon: Icons.mic_none_rounded,
            title: "Speak",
            subtitle: "Say your task naturally",
            delay: 200,
            color: Colors.blueAccent,
          ),
          const Gap(24),
          _buildStepItem(
            icon: Icons.category_outlined,
            title: "Organize",
            subtitle: "Choose category & notes",
            delay: 400,
            color: Colors.orangeAccent,
          ),
          const Gap(24),
          _buildStepItem(
            icon: Icons.access_time_rounded,
            title: "Schedule",
            subtitle: "Set date and time",
            delay: 600,
            color: Colors.purpleAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required int delay,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const Gap(20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const Gap(4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF718096),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.2);
  }
}
