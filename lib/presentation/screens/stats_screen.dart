import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:say_task/core/theme/app_theme.dart';
import 'package:say_task/presentation/providers/task_provider.dart';
import 'package:say_task/domain/entities/task_category.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Progress',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined,
                      size: 64, color: Colors.grey[400]),
                  const Gap(16),
                  Text(
                    'No tasks yet. Start working!',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          // 1. Tasks Completed Today
          final completedToday = tasks.where((t) {
            if (!t.isCompleted || t.completedAt == null) return false;
            final cDate = t.completedAt!;
            return cDate.year == today.year &&
                cDate.month == today.month &&
                cDate.day == today.day;
          }).length;

          // 2. Weekly Focus (Last 7 Days)
          final weeklyData = List.generate(7, (index) {
            final day = today.subtract(Duration(days: 6 - index));
            final count = tasks.where((t) {
              if (!t.isCompleted || t.completedAt == null) return false;
              final cDate = t.completedAt!;
              return cDate.year == day.year &&
                  cDate.month == day.month &&
                  cDate.day == day.day;
            }).length;
            return {'day': DateFormat('E').format(day), 'count': count};
          });

          // 3. Most Productive Hour
          final hourCounts = <int, int>{};
          for (final t in tasks) {
            if (t.isCompleted && t.completedAt != null) {
              final hour = t.completedAt!.hour;
              hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
            }
          }
          int? bestHour;
          int maxCount = -1;
          hourCounts.forEach((hour, count) {
            if (count > maxCount) {
              maxCount = count;
              bestHour = hour;
            }
          });

          String productiveHourText = "N/A";
          if (bestHour != null) {
            final time = DateTime(2000, 1, 1, bestHour!);
            productiveHourText = DateFormat('h a').format(time);
          }

          // 4. Completion Rate
          final totalTasks = tasks.length;
          final totalCompleted = tasks.where((t) => t.isCompleted).length;
          final completionRate =
              totalTasks == 0 ? 0.0 : totalCompleted / totalTasks;

          // 5. Category Breakdown (Top 3)
          final categoryStats = <TaskCategory, int>{};
          for (final t in tasks) {
            if (t.isCompleted) {
              categoryStats[t.category] = (categoryStats[t.category] ?? 0) + 1;
            }
          }
          final sortedCategories = categoryStats.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final topCategories = sortedCategories.take(3).toList();

          return LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Stats Row/Column
                  // Top Stats Row
                  // Using IntrinsicHeight to ensure both cards match height
                  if (constraints.maxWidth > 340) // Slightly lower breakpoint
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 1, // Equal width
                            child: _buildTodayCard(completedToday),
                          ),
                          const Gap(16),
                          Expanded(
                            flex: 1, // Equal width
                            child: _buildCompletionRateCard(
                                context, completionRate, isDark),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        _buildTodayCard(completedToday),
                        const Gap(16),
                        _buildCompletionRateCard(
                            context, completionRate, isDark),
                      ],
                    ),

                  const Gap(24),

                  // Weekly Chart
                  Text("Weekly Activity",
                      style: GoogleFonts.outfit(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const Gap(16),
                  Container(
                    height: 220,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (weeklyData
                                    .map((e) => e['count'] as int)
                                    .reduce((a, b) => a > b ? a : b) +
                                2)
                            .toDouble(),
                        barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => Colors.blueGrey,
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  rod.toY.toInt().toString(),
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            )),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    weeklyData[value.toInt()]['day'] as String,
                                    style: GoogleFonts.outfit(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: weeklyData.asMap().entries.map((e) {
                          final count = e.value['count'] as int;
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: count.toDouble(),
                                color: count > 0
                                    ? AppTheme.primaryIndigo
                                    : Colors.grey.shade300,
                                width: 16,
                                borderRadius: BorderRadius.circular(4),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: false,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const Gap(24),

                  // Category Breakdown
                  if (topCategories.isNotEmpty) ...[
                    Text("Top Categories",
                        style: GoogleFonts.outfit(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Gap(16),
                    ...topCategories.map((entry) {
                      final category = entry.key;
                      final count = entry.value;
                      final percentage =
                          totalCompleted == 0 ? 0.0 : (count / totalCompleted);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildCategoryCard(
                            context, category, count, percentage),
                      );
                    }),
                  ],

                  const Gap(24),

                  // Best Hour - Enhanced
                  _buildProductiveHourCard(context, productiveHourText, isDark),

                  // Bottom padding for floating nav
                  const Gap(100),
                ],
              ),
            );
          });
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildTodayCard(int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryIndigo, const Color(0xFF818CF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryIndigo.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Today",
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(4),
          Text(
            "$count",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Tasks done",
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionRateCard(
      BuildContext context, double rate, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      // Same decoration as Today card
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryIndigo, const Color(0xFF818CF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryIndigo.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 60,
            width: 60,
            child: Stack(
              children: [
                Center(
                  child: CircularProgressIndicator(
                    value: rate,
                    strokeWidth: 8,
                    // White track with transparency
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    color: Colors.white,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "${(rate * 100).toInt()}%",
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white, // White text
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Rate",
                  style: GoogleFonts.outfit(
                    color: Colors.white70, // White70 text
                    fontSize: 12,
                  ),
                ),
                Text(
                  "Done",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, TaskCategory category,
      int count, double percentage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(category.colorValue).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              category.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category.displayName,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "$count tasks",
                      style: GoogleFonts.outfit(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 6,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey.shade100,
                    color: Color(category.colorValue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductiveHourCard(
      BuildContext context, String timeText, bool isDark) {
    // Determine Icon based on time
    IconData timeIcon = Icons.access_time_rounded;
    List<Color> gradientColors = [
      Colors.orange.shade400,
      Colors.deepOrange.shade400
    ];

    if (timeText != "N/A" && timeText.contains("M")) {
      // Simple parsing logic assuming format "5 PM" or "10 AM"
      final isPM = timeText.contains("PM");
      final hourStr = timeText.split(" ")[0];
      int hour = int.tryParse(hourStr) ?? 12;

      if (hour == 12) hour = 0; // handle 12 AM/PM as 0 offset initially

      // Normalize to 24h for comparison roughly
      // We want to show Moon/Night for 6 PM to 5 AM?
      // 6 PM = 18, 5 AM = 5.

      // Let's keep it simple:
      // PM -> Night (Moon) unless it's 12 PM (Noon) - 5 PM
      // AM -> Day (Sun) unless it's very early like 12 AM - 5 AM

      // Better logic:
      // Day: 6 AM to 6 PM
      // Night: 6 PM to 6 AM

      int hour24 = hour + (isPM ? 12 : 0);
      if (hour == 12 && isPM) hour24 = 12; // 12 PM is 12
      if (hour == 12 && !isPM) hour24 = 0; // 12 AM is 0

      if (hour24 >= 6 && hour24 < 18) {
        // Day time
        timeIcon = Icons.wb_sunny_rounded;
        gradientColors = [Colors.orange.shade400, Colors.deepOrange.shade400];
      } else {
        // Night time
        timeIcon = Icons.nights_stay_rounded;
        // Darker blue/purple gradient for night
        gradientColors = [const Color(0xFF6366F1), const Color(0xFF4338CA)];
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]),
            child: Icon(timeIcon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Most Productive Hour",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeText,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
