import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../models/hunter_stat.dart';
import '../models/task_activity_day.dart';
import '../models/task_report.dart';
import '../theme/hunter_theme.dart';
import '../widgets/activity_grid.dart';
import '../widgets/profile_metric.dart';
import '../widgets/stat_card.dart';
import '../widgets/status_chip.dart';
import '../widgets/system_icon.dart';
import '../widgets/system_panel.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.completedQuests,
    required this.totalQuests,
    required this.activityDays,
    this.report,
    this.currentUser,
    this.onLogout,
  });

  final int completedQuests;
  final int totalQuests;
  final List<TaskActivityDay> activityDays;
  final TaskReport? report;
  final AuthUser? currentUser;
  final VoidCallback? onLogout;

  int get _level => report?.level ?? (1 + completedQuests ~/ 3);

  int get _xp => report?.xp ?? (completedQuests * 20);

  double get _dailyProgress {
    if (totalQuests == 0) {
      return 0;
    }

    return completedQuests / totalQuests;
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      HunterStat('STR', 42 + completedQuests * 5, Icons.fitness_center),
      HunterStat('AGI', 35 + completedQuests * 3, Icons.speed),
      HunterStat('INT', 38 + completedQuests * 4, Icons.psychology),
      HunterStat('VIT', 31 + completedQuests * 2, Icons.favorite),
    ];

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SystemIcon(icon: Icons.shield),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HUNTER PROFILE',
                            style: TextStyle(
                              color: manaBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            currentUser?.name.isNotEmpty == true
                                ? currentUser!.name
                                : 'Sung Drip-Woo',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                    StatusChip(label: 'LEVEL $_level'),
                    if (onLogout != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Logout',
                        onPressed: onLogout,
                        icon: const Icon(Icons.logout),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 22),
                SystemPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ProfileMetric(
                              label: 'Experience',
                              value: '$_xp XP',
                            ),
                          ),
                          Expanded(
                            child: ProfileMetric(
                              label: report?.streakTitle ?? 'Completed',
                              value: '$completedQuests / $totalQuests',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: _dailyProgress,
                          minHeight: 9,
                          backgroundColor: const Color(
                            0xFF1A2441,
                          ).withValues(alpha: 0.9),
                          valueColor: const AlwaysStoppedAnimation(manaBlue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          sliver: SliverGrid.builder(
            itemCount: stats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.75,
            ),
            itemBuilder: (context, index) {
              return StatCard(stat: stats[index]);
            },
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          sliver: SliverToBoxAdapter(child: ActivityGrid(days: activityDays)),
        ),
      ],
    );
  }
}
