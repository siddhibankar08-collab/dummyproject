class TaskActivityDay {
  const TaskActivityDay({
    required this.date,
    required this.total,
    required this.completed,
    required this.completionRate,
    required this.intensity,
  });

  final DateTime date;
  final int total;
  final int completed;
  final double completionRate;
  final int intensity;

  factory TaskActivityDay.fromJson(Map<String, dynamic> json) {
    return TaskActivityDay(
      date: DateTime.parse(json['date'] as String),
      total: json['total'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      completionRate: (json['completion_rate'] as num? ?? 0).toDouble(),
      intensity: json['intensity'] as int? ?? 0,
    );
  }
}
