import 'package:flutter/material.dart';

import '../models/task_report.dart';
import '../theme/hunter_theme.dart';
import '../widgets/profile_metric.dart';
import '../widgets/system_icon.dart';
import '../widgets/system_panel.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({
    super.key,
    required this.period,
    required this.report,
    required this.isLoading,
    required this.onPeriodChanged,
    required this.onRefresh,
  });

  final String period;
  final TaskReport? report;
  final bool isLoading;
  final ValueChanged<String> onPeriodChanged;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              child: Row(
                children: [
                  const SystemIcon(icon: Icons.analytics),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'REPORTS',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'week', label: Text('Week')),
                      ButtonSegment(value: 'month', label: Text('Month')),
                    ],
                    selected: {period},
                    onSelectionChanged: (values) =>
                        onPeriodChanged(values.first),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (report == null)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No report data yet.',
                  style: TextStyle(color: Color(0xFF98A7C7)),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _Summary(report: report!),
                  const SizedBox(height: 14),
                  _Breakdown(title: 'Ranks', values: report!.rankBreakdown),
                  const SizedBox(height: 14),
                  _Breakdown(
                    title: 'Categories',
                    values: report!.categoryBreakdown,
                  ),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.report});

  final TaskReport report;

  @override
  Widget build(BuildContext context) {
    return SystemPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_date(report.start)} - ${_date(report.end)}',
            style: const TextStyle(color: Color(0xFF98A7C7), fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ProfileMetric(
                  label: 'Completion',
                  value: '${(report.completionRate * 100).round()}%',
                ),
              ),
              Expanded(
                child: ProfileMetric(label: 'XP', value: '${report.xp}'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ProfileMetric(
                  label: 'Done',
                  value: '${report.completedTasks}/${report.totalTasks}',
                ),
              ),
              Expanded(
                child: ProfileMetric(
                  label: 'Missed',
                  value: '${report.missedTasks}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${report.streakTitle} - ${report.currentStreak} day streak',
            style: const TextStyle(
              color: manaBlue,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String _date(DateTime date) => '${date.month}/${date.day}/${date.year}';
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.title, required this.values});

  final String title;
  final Map<String, int> values;

  @override
  Widget build(BuildContext context) {
    return SystemPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (values.isEmpty)
            const Text('No entries', style: TextStyle(color: Color(0xFF98A7C7)))
          else
            for (final entry in values.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(entry.key)),
                    Text(
                      '${entry.value}',
                      style: const TextStyle(
                        color: manaBlue,
                        fontWeight: FontWeight.w800,
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
