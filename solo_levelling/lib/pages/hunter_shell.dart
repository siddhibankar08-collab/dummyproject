import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../models/quest.dart';
import '../models/task_activity_day.dart';
import '../models/task_report.dart';
import '../services/task_api.dart';
import '../theme/hunter_theme.dart';
import '../widgets/hunter_background.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'quest_board_page.dart';
import 'reports_page.dart';

class HunterShell extends StatefulWidget {
  const HunterShell({
    super.key,
    TaskApi? taskApi,
    this.currentUser,
    this.onLogout,
  }) : _taskApi = taskApi;

  final TaskApi? _taskApi;
  final AuthUser? currentUser;
  final VoidCallback? onLogout;

  @override
  State<HunterShell> createState() => _HunterShellState();
}

class _HunterShellState extends State<HunterShell> {
  int _selectedPage = 0;
  late final TaskApi _taskApi;

  List<Quest> _quests = [];
  List<Quest> _historyQuests = [];
  List<TaskActivityDay> _activityDays = [];
  TaskReport? _report;
  DateTime _historyDate = DateTime.now().subtract(const Duration(days: 1));
  String _reportPeriod = 'week';
  bool _isLoading = true;
  bool _isHistoryLoading = true;
  bool _isReportLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  int get _completedQuests {
    return _quests.where((quest) => quest.isComplete).length;
  }

  int get _remainingQuests {
    return _quests.length - _completedQuests;
  }

  @override
  void initState() {
    super.initState();
    _taskApi = widget._taskApi ?? const TaskApi();
    _refreshAll();
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadTodayQuests(),
      _loadHistory(),
      _loadReport(),
      _loadActivity(),
    ]);
  }

  Future<void> _loadTodayQuests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final quests = await _taskApi.fetchToday();

      if (!mounted) {
        return;
      }

      setState(() {
        _quests = quests;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addQuest({
    required String title,
    required String reward,
    required String rank,
    required String description,
    required String category,
    required String difficulty,
    required int estimatedMinutes,
    required String targetMetric,
    required String successCriteria,
    required String notes,
    required DateTime dueDate,
  }) async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final quest = await _taskApi.addTodayTask(
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
        dueDate: dueDate,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        if (_isSameDay(quest.dueDate, DateTime.now())) {
          _quests = [..._quests, quest];
        }
        _isSaving = false;
      });
      await _loadReport();
      await _loadActivity();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _toggleQuest(int index, bool? value) async {
    final previousQuest = _quests[index];
    if (previousQuest.isComplete || value != true) {
      return;
    }

    setState(() {
      _quests[index] = previousQuest.copyWith(isComplete: true);
    });

    try {
      final updatedQuest = await _taskApi.updateTaskCompletion(
        previousQuest.id,
        true,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _quests[index] = updatedQuest;
      });
      await _loadReport();
      await _loadActivity();

      if (!mounted) {
        return;
      }

      final allClear =
          _quests.isNotEmpty && _quests.every((quest) => quest.isComplete);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            allClear
                ? 'Daily clear reward unlocked.'
                : 'Quest locked as complete.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _quests[index] = previousQuest;
        _errorMessage = error.toString();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Quest update failed: $error')));
    }
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isHistoryLoading = true;
    });

    try {
      final quests = await _taskApi.fetchHistory(
        start: _historyDate,
        end: _historyDate,
      );
      if (!mounted) return;
      setState(() {
        _historyQuests = quests;
        _isHistoryLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isHistoryLoading = false;
      });
    }
  }

  Future<void> _loadReport() async {
    setState(() {
      _isReportLoading = true;
    });

    try {
      final report = await _taskApi.fetchReport(
        period: _reportPeriod,
        anchor: DateTime.now(),
      );
      if (!mounted) return;
      setState(() {
        _report = report;
        _isReportLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isReportLoading = false;
      });
    }
  }

  Future<void> _loadActivity() async {
    try {
      final activity = await _taskApi.fetchActivity();
      if (!mounted) return;
      setState(() {
        _activityDays = activity;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  void _changeHistoryDate(DateTime date) {
    setState(() {
      _historyDate = date;
    });
    _loadHistory();
  }

  void _changeReportPeriod(String period) {
    setState(() {
      _reportPeriod = period;
    });
    _loadReport();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HunterBackground(
        child: IndexedStack(
          index: _selectedPage,
          children: [
            QuestBoardPage(
              quests: _quests,
              remainingQuests: _remainingQuests,
              isLoading: _isLoading,
              isSaving: _isSaving,
              errorMessage: _errorMessage,
              onAddQuest: _addQuest,
              onQuestChanged: _toggleQuest,
              onRefresh: _loadTodayQuests,
            ),
            HistoryPage(
              selectedDate: _historyDate,
              quests: _historyQuests,
              isLoading: _isHistoryLoading,
              onDateChanged: _changeHistoryDate,
              onRefresh: _loadHistory,
            ),
            ProfilePage(
              completedQuests: _completedQuests,
              totalQuests: _quests.length,
              activityDays: _activityDays,
              report: _report,
              currentUser: widget.currentUser,
              onLogout: widget.onLogout,
            ),
            ReportsPage(
              period: _reportPeriod,
              report: _report,
              isLoading: _isReportLoading,
              onPeriodChanged: _changeReportPeriod,
              onRefresh: _loadReport,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: panelBlue.withValues(alpha: 0.96),
          border: Border(
            top: BorderSide(color: manaBlue.withValues(alpha: 0.25)),
          ),
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          indicatorColor: manaBlue.withValues(alpha: 0.14),
          selectedIndex: _selectedPage,
          onDestinationSelected: (index) {
            setState(() {
              _selectedPage = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: 'Quests',
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              selectedIcon: Icon(Icons.history_toggle_off),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics),
              label: 'Reports',
            ),
          ],
        ),
      ),
    );
  }
}
