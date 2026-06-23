class ReportDay {
  const ReportDay({
    required this.date,
    required this.total,
    required this.completed,
    required this.completionRate,
  });

  final DateTime date;
  final int total;
  final int completed;
  final double completionRate;

  factory ReportDay.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ReportDay(
        date: DateTime.now(),
        total: 0,
        completed: 0,
        completionRate: 0,
      );
    }

    return ReportDay(
      date: DateTime.parse(json['date'] as String),
      total: json['total'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      completionRate: (json['completion_rate'] as num? ?? 0).toDouble(),
    );
  }
}

class TaskReport {
  const TaskReport({
    required this.period,
    required this.start,
    required this.end,
    required this.totalTasks,
    required this.completedTasks,
    required this.missedTasks,
    required this.completionRate,
    required this.xp,
    required this.currentStreak,
    required this.longestStreak,
    required this.categoryBreakdown,
    required this.rankBreakdown,
    required this.bestDay,
    required this.worstDay,
  });

  final String period;
  final DateTime start;
  final DateTime end;
  final int totalTasks;
  final int completedTasks;
  final int missedTasks;
  final double completionRate;
  final int xp;
  final int currentStreak;
  final int longestStreak;
  final Map<String, int> categoryBreakdown;
  final Map<String, int> rankBreakdown;
  final ReportDay bestDay;
  final ReportDay worstDay;

  int get level => 1 + xp ~/ 250;
  String get streakTitle {
    if (currentStreak >= 30) return 'Shadow Monarch';
    if (currentStreak >= 14) return 'Elite Hunter';
    if (currentStreak >= 7) return 'Raid Captain';
    if (currentStreak >= 3) return 'Rising Hunter';
    return 'Initiate';
  }

  factory TaskReport.fromJson(Map<String, dynamic> json) {
    return TaskReport(
      period: json['period'] as String? ?? 'week',
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      totalTasks: json['total_tasks'] as int? ?? 0,
      completedTasks: json['completed_tasks'] as int? ?? 0,
      missedTasks: json['missed_tasks'] as int? ?? 0,
      completionRate: (json['completion_rate'] as num? ?? 0).toDouble(),
      xp: json['xp'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      categoryBreakdown: _intMap(json['category_breakdown']),
      rankBreakdown: _intMap(json['rank_breakdown']),
      bestDay: ReportDay.fromJson(json['best_day'] as Map<String, dynamic>?),
      worstDay: ReportDay.fromJson(json['worst_day'] as Map<String, dynamic>?),
    );
  }

  static Map<String, int> _intMap(Object? value) {
    final map = value is Map<String, dynamic> ? value : <String, dynamic>{};
    return map.map((key, value) => MapEntry(key, value as int? ?? 0));
  }
}
