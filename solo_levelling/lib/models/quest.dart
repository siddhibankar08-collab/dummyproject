class Quest {
  const Quest({
    required this.id,
    required this.title,
    required this.reward,
    required this.rank,
    required this.dueDate,
    this.description = '',
    this.category = 'General',
    this.difficulty = 'Normal',
    this.estimatedMinutes = 30,
    this.targetMetric = '',
    this.successCriteria = '',
    this.notes = '',
    this.completedAt,
    this.createdAt,
    this.lockedAt,
    this.isComplete = false,
  });

  final String id;
  final String title;
  final String reward;
  final String rank;
  final DateTime dueDate;
  final String description;
  final String category;
  final String difficulty;
  final int estimatedMinutes;
  final String targetMetric;
  final String successCriteria;
  final String notes;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? lockedAt;
  final bool isComplete;

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      reward: json['reward'] as String? ?? '',
      rank: json['rank'] as String? ?? 'E',
      dueDate: DateTime.parse(json['due_date'] as String),
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      difficulty: json['difficulty'] as String? ?? 'Normal',
      estimatedMinutes: json['estimated_minutes'] as int? ?? 30,
      targetMetric: json['target_metric'] as String? ?? '',
      successCriteria: json['success_criteria'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      completedAt: _optionalDate(json['completed_at']),
      createdAt: _optionalDate(json['created_at']),
      lockedAt: _optionalDate(json['locked_at']),
      isComplete: json['is_complete'] as bool? ?? false,
    );
  }

  Quest copyWith({
    String? id,
    String? title,
    String? reward,
    String? rank,
    DateTime? dueDate,
    String? description,
    String? category,
    String? difficulty,
    int? estimatedMinutes,
    String? targetMetric,
    String? successCriteria,
    String? notes,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? lockedAt,
    bool? isComplete,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      reward: reward ?? this.reward,
      rank: rank ?? this.rank,
      dueDate: dueDate ?? this.dueDate,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      targetMetric: targetMetric ?? this.targetMetric,
      successCriteria: successCriteria ?? this.successCriteria,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      lockedAt: lockedAt ?? this.lockedAt,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  static DateTime? _optionalDate(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}
