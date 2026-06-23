import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:solo_levelling/main.dart';
import 'package:solo_levelling/models/quest.dart';
import 'package:solo_levelling/models/task_activity_day.dart';
import 'package:solo_levelling/models/task_report.dart';
import 'package:solo_levelling/services/task_api.dart';

class FakeTaskApi extends TaskApi {
  FakeTaskApi()
    : _quests = [
        Quest(
          id: 'quest-1',
          title: 'Complete daily workout',
          reward: '+20 Strength',
          rank: 'E',
          dueDate: DateTime(2026, 6, 23),
        ),
        Quest(
          id: 'quest-2',
          title: 'Study Flutter widgets',
          reward: '+15 Intelligence',
          rank: 'D',
          dueDate: DateTime(2026, 6, 23),
        ),
        Quest(
          id: 'quest-3',
          title: 'Finish project task',
          reward: '+30 Focus',
          rank: 'C',
          dueDate: DateTime(2026, 6, 23),
        ),
        Quest(
          id: 'quest-4',
          title: 'Review tomorrow plan',
          reward: '+10 Discipline',
          rank: 'E',
          dueDate: DateTime(2026, 6, 23),
        ),
      ];

  final List<Quest> _quests;

  @override
  Future<List<Quest>> fetchToday() async {
    return List.of(_quests);
  }

  @override
  Future<Quest> addTodayTask({
    required String title,
    required String reward,
    required String rank,
    String description = '',
    String category = 'General',
    String difficulty = 'Normal',
    int estimatedMinutes = 30,
    String targetMetric = '',
    String successCriteria = '',
    String notes = '',
    DateTime? dueDate,
  }) async {
    final quest = Quest(
      id: 'quest-${_quests.length + 1}',
      title: title,
      description: description,
      category: category,
      difficulty: difficulty,
      estimatedMinutes: estimatedMinutes,
      targetMetric: targetMetric,
      successCriteria: successCriteria,
      notes: notes,
      reward: reward,
      rank: rank,
      dueDate: dueDate ?? DateTime(2026, 6, 23),
    );
    _quests.add(quest);

    return quest;
  }

  @override
  Future<Quest> updateTaskCompletion(String id, bool isComplete) async {
    final index = _quests.indexWhere((quest) => quest.id == id);
    _quests[index] = _quests[index].copyWith(isComplete: isComplete);

    return _quests[index];
  }

  @override
  Future<List<Quest>> fetchHistory({
    required DateTime start,
    required DateTime end,
  }) async {
    return _quests.where((quest) => quest.dueDate.day == start.day).toList();
  }

  @override
  Future<TaskReport> fetchReport({
    required String period,
    required DateTime anchor,
  }) async {
    final completed = _quests.where((quest) => quest.isComplete).length;
    return TaskReport(
      period: period,
      start: DateTime(2026, 6, 22),
      end: DateTime(2026, 6, 28),
      totalTasks: _quests.length,
      completedTasks: completed,
      missedTasks: 0,
      completionRate: _quests.isEmpty ? 0 : completed / _quests.length,
      xp: completed * 20,
      currentStreak: completed == _quests.length ? 1 : 0,
      longestStreak: 1,
      categoryBreakdown: const {'General': 4},
      rankBreakdown: const {'E': 2, 'D': 1, 'C': 1},
      bestDay: ReportDay(
        date: DateTime(2026, 6, 23),
        total: _quests.length,
        completed: completed,
        completionRate: _quests.isEmpty ? 0 : completed / _quests.length,
      ),
      worstDay: ReportDay(
        date: DateTime(2026, 6, 23),
        total: _quests.length,
        completed: completed,
        completionRate: _quests.isEmpty ? 0 : completed / _quests.length,
      ),
    );
  }

  @override
  Future<List<TaskActivityDay>> fetchActivity({int days = 366}) async {
    return [
      for (var index = 0; index < days; index++)
        TaskActivityDay(
          date: DateTime(2025, 6, 24).add(Duration(days: index)),
          total: index == days - 1 ? _quests.length : 0,
          completed: index == days - 1
              ? _quests.where((quest) => quest.isComplete).length
              : 0,
          completionRate: 0,
          intensity: index == days - 1
              ? _quests.where((quest) => quest.isComplete).length.clamp(0, 4)
              : 0,
        ),
    ];
  }
}

void main() {
  testWidgets('Quest board shows and updates remaining tasks', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      HunterQuestApp(taskApi: FakeTaskApi(), requireAuth: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('SYSTEM QUEST LOG'), findsOneWidget);
    expect(find.text('Tasks Remaining'), findsOneWidget);
    expect(find.text('4 / 4'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Complete daily workout'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Complete daily workout'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Tasks Remaining'),
      -240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('3 / 4'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('HUNTER PROFILE'), findsOneWidget);
    expect(find.text('Sung Drip-Woo'), findsOneWidget);
    expect(find.text('LEVEL 1'), findsOneWidget);
    expect(find.text('1 / 4'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Activity Tracking'),
      240,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.text('Activity Tracking'), findsOneWidget);
  });

  testWidgets('Quest board adds a task through the API', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      HunterQuestApp(taskApi: FakeTaskApi(), requireAuth: false),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Read Supabase docs');
    await tester.enterText(find.byType(TextField).at(7), '+10 Intelligence');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Tasks Remaining'),
      -240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('5 / 5'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Read Supabase docs'),
      240,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Read Supabase docs'), findsOneWidget);
  });
}
