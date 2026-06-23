import 'package:flutter/material.dart';

import '../models/task_activity_day.dart';
import '../theme/hunter_theme.dart';
import 'status_chip.dart';
import 'system_panel.dart';

class ActivityGrid extends StatefulWidget {
  const ActivityGrid({super.key, required this.days});

  final List<TaskActivityDay> days;

  @override
  State<ActivityGrid> createState() => _ActivityGridState();
}

class _ActivityGridState extends State<ActivityGrid> {
  TaskActivityDay? _selectedDay;

  Color _colorFor(int intensity) {
    if (intensity <= 0) return const Color(0xFF161B22);
    if (intensity == 1) return const Color(0xFF0E4429);
    if (intensity == 2) return const Color(0xFF006D32);
    if (intensity == 3) return const Color(0xFF26A641);
    return const Color(0xFF39D353);
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.days;
    final selected = _selectedDay ?? (days.isEmpty ? null : days.last);

    return SystemPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Activity Tracking',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              StatusChip(label: '${days.length} DAYS'),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Committed task clears over time',
            style: TextStyle(color: Color(0xFF98A7C7), fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (days.isEmpty)
            const Text(
              'No activity yet.',
              style: TextStyle(color: Color(0xFF98A7C7)),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final weeks = _weeks(days);
                final cell = ((constraints.maxWidth - 50) / weeks.length)
                    .clamp(9.0, 13.0);
                const gap = 4.0;
                final chartWidth = weeks.length * cell + (weeks.length - 1) * gap;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 32),
                            child: _MonthLabels(
                              weeks: weeks,
                              cellSize: cell,
                              gap: gap,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 28,
                                child: Column(
                                  children: [
                                    _WeekdaySpacer(),
                                    _WeekdayLabel('Mon'),
                                    _WeekdaySpacer(),
                                    _WeekdayLabel('Wed'),
                                    _WeekdaySpacer(),
                                    _WeekdayLabel('Fri'),
                                    _WeekdaySpacer(),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: chartWidth,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (var weekIndex = 0;
                                        weekIndex < weeks.length;
                                        weekIndex++) ...[
                                      Column(
                                        children: [
                                          for (final day in weeks[weekIndex])
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: gap,
                                              ),
                                              child: day == null
                                                  ? SizedBox.square(
                                                      dimension: cell,
                                                    )
                                                  : _ActivityCell(
                                                      day: day,
                                                      size: cell,
                                                      color: _colorFor(
                                                        day.intensity,
                                                      ),
                                                      isSelected:
                                                          selected?.date ==
                                                          day.date,
                                                      onTap: () => setState(() {
                                                        _selectedDay = day;
                                                      }),
                                                    ),
                                            ),
                                        ],
                                      ),
                                      if (weekIndex != weeks.length - 1)
                                        const SizedBox(width: gap),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 14),
          if (selected != null)
            Text(
              '${_date(selected.date)} - ${selected.completed}/${selected.total} complete',
              style: const TextStyle(
                color: manaBlue,
                fontWeight: FontWeight.w800,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Less',
                style: TextStyle(color: Color(0xFF98A7C7), fontSize: 12),
              ),
              const SizedBox(width: 8),
              for (var level = 0; level < 5; level++)
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: _colorFor(level),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              const SizedBox(width: 4),
              const Text(
                'More',
                style: TextStyle(color: Color(0xFF98A7C7), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<List<TaskActivityDay?>> _weeks(List<TaskActivityDay> days) {
    final sorted = [...days]..sort((a, b) => a.date.compareTo(b.date));
    final leading = sorted.first.date.weekday % 7;
    final aligned = [
      ...List<TaskActivityDay?>.filled(leading, null),
      ...sorted,
    ];

    while (aligned.length % 7 != 0) {
      aligned.add(null);
    }

    return [
      for (var index = 0; index < aligned.length; index += 7)
        aligned.sublist(index, index + 7),
    ];
  }

  String _date(DateTime date) => '${date.month}/${date.day}/${date.year}';
}

class _MonthLabels extends StatelessWidget {
  const _MonthLabels({
    required this.weeks,
    required this.cellSize,
    required this.gap,
  });

  final List<List<TaskActivityDay?>> weeks;
  final double cellSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final labels = <String?>[];
    var previousMonth = 0;

    for (final week in weeks) {
      final month = _monthForWeek(week);
      if (month != null && month != previousMonth) {
        labels.add(_month(month));
        previousMonth = month;
      } else {
        labels.add(null);
      }
    }

    return DefaultTextStyle(
      style: const TextStyle(color: Color(0xFF98A7C7), fontSize: 11),
      child: Row(
        children: [
          for (var index = 0; index < labels.length; index++) ...[
            SizedBox(
              width: cellSize,
              child: labels[index] == null
                  ? const SizedBox.shrink()
                  : Text(labels[index]!),
            ),
            if (index != labels.length - 1) SizedBox(width: gap),
          ],
        ],
      ),
    );
  }

  int? _monthForWeek(List<TaskActivityDay?> week) {
    for (final day in week) {
      if (day != null && day.date.day <= 7) {
        return day.date.month;
      }
    }

    return null;
  }

  String _month(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }
}

class _ActivityCell extends StatelessWidget {
  const _ActivityCell({
    required this.day,
    required this.size,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final TaskActivityDay day;
  final double size;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${_date(day.date)}: ${day.completed}/${day.total} complete',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.06),
            ),
          ),
        ),
      ),
    );
  }

  String _date(DateTime date) => '${date.month}/${date.day}/${date.year}';
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 13,
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFF98A7C7), fontSize: 10),
      ),
    );
  }
}

class _WeekdaySpacer extends StatelessWidget {
  const _WeekdaySpacer();

  @override
  Widget build(BuildContext context) => const SizedBox(height: 13);
}
