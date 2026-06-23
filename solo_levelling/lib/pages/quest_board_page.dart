import 'package:flutter/material.dart';

import '../models/quest.dart';
import '../theme/hunter_theme.dart';
import '../widgets/quest_card.dart';
import '../widgets/status_chip.dart';
import '../widgets/system_icon.dart';
import '../widgets/system_panel.dart';

class QuestBoardPage extends StatelessWidget {
  const QuestBoardPage({
    super.key,
    required this.quests,
    required this.remainingQuests,
    required this.isLoading,
    required this.isSaving,
    required this.errorMessage,
    required this.onAddQuest,
    required this.onQuestChanged,
    required this.onRefresh,
  });

  final List<Quest> quests;
  final int remainingQuests;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final Future<void> Function({
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
  })
  onAddQuest;
  final void Function(int index, bool? value) onQuestChanged;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _HunterHeader(
              remainingQuests: remainingQuests,
              totalQuests: quests.length,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: _AddQuestPanel(isSaving: isSaving, onAddQuest: onAddQuest),
            ),
          ),
          if (errorMessage != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _ErrorPanel(message: errorMessage!, onRetry: onRefresh),
              ),
            ),
          if (isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (quests.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No quests for today yet.',
                  style: TextStyle(color: Color(0xFF98A7C7)),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              sliver: SliverList.separated(
                itemCount: quests.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final quest = quests[index];

                  return QuestCard(
                    quest: quest,
                    onChanged: (value) => onQuestChanged(index, value),
                    onTap: () => _showQuestDetails(context, quest),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showQuestDetails(BuildContext context, Quest quest) {
    showDialog<void>(
      context: context,
      builder: (context) => _QuestDetailsDialog(quest: quest),
    );
  }
}

class _QuestDetailsDialog extends StatelessWidget {
  const _QuestDetailsDialog({required this.quest});

  final Quest quest;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF101529),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: manaBlue.withValues(alpha: 0.35)),
      ),
      titlePadding: const EdgeInsets.fromLTRB(22, 20, 14, 0),
      contentPadding: const EdgeInsets.fromLTRB(22, 14, 22, 10),
      actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      title: Row(
        children: [
          Expanded(
            child: Text(
              quest.title,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusChip(label: quest.isComplete ? 'COMPLETE' : 'ACTIVE'),
                StatusChip(label: 'RANK ${quest.rank}'),
                StatusChip(label: quest.difficulty.toUpperCase()),
              ],
            ),
            const SizedBox(height: 18),
            if (quest.description.isNotEmpty)
              _QuestDetailRow(
                icon: Icons.notes,
                label: 'Description',
                value: quest.description,
              ),
            _QuestDetailRow(
              icon: Icons.category,
              label: 'Category',
              value: quest.category,
            ),
            _QuestDetailRow(
              icon: Icons.timer,
              label: 'Estimate',
              value: '${quest.estimatedMinutes} minutes',
            ),
            _QuestDetailRow(
              icon: Icons.event,
              label: 'Due date',
              value: _date(quest.dueDate),
            ),
            if (quest.targetMetric.isNotEmpty)
              _QuestDetailRow(
                icon: Icons.track_changes,
                label: 'Target metric',
                value: quest.targetMetric,
              ),
            if (quest.successCriteria.isNotEmpty)
              _QuestDetailRow(
                icon: Icons.verified_user,
                label: 'Success criteria',
                value: quest.successCriteria,
              ),
            if (quest.reward.isNotEmpty)
              _QuestDetailRow(
                icon: Icons.stars,
                label: 'Reward',
                value: quest.reward,
              ),
            if (quest.notes.isNotEmpty)
              _QuestDetailRow(
                icon: Icons.edit_note,
                label: 'Notes',
                value: quest.notes,
              ),
            if (quest.completedAt != null)
              _QuestDetailRow(
                icon: Icons.check_circle,
                label: 'Completed',
                value: _dateTime(quest.completedAt!),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  String _date(DateTime date) => '${date.month}/${date.day}/${date.year}';

  String _dateTime(DateTime date) {
    final minute = date.minute.toString().padLeft(2, '0');
    return '${_date(date)} ${date.hour}:$minute';
  }
}

class _QuestDetailRow extends StatelessWidget {
  const _QuestDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: manaBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF98A7C7),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFFF3F8FF),
                    fontSize: 14,
                    height: 1.35,
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

class _AddQuestPanel extends StatefulWidget {
  const _AddQuestPanel({required this.isSaving, required this.onAddQuest});

  final bool isSaving;
  final Future<void> Function({
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
  })
  onAddQuest;

  @override
  State<_AddQuestPanel> createState() => _AddQuestPanelState();
}

class _AddQuestPanelState extends State<_AddQuestPanel> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController(text: 'General');
  final _estimateController = TextEditingController(text: '30');
  final _targetController = TextEditingController();
  final _successController = TextEditingController();
  final _notesController = TextEditingController();
  final _rewardController = TextEditingController();
  String _rank = 'E';
  String _difficulty = 'Normal';
  DateTime _dueDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _estimateController.dispose();
    _targetController.dispose();
    _successController.dispose();
    _notesController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final reward = _rewardController.text.trim();

    if (title.isEmpty || widget.isSaving) {
      return;
    }

    await widget.onAddQuest(
      title: title,
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim().isEmpty
          ? 'General'
          : _categoryController.text.trim(),
      difficulty: _difficulty,
      estimatedMinutes: int.tryParse(_estimateController.text.trim()) ?? 30,
      targetMetric: _targetController.text.trim(),
      successCriteria: _successController.text.trim(),
      notes: _notesController.text.trim(),
      reward: reward,
      rank: _rank,
      dueDate: _dueDate,
    );

    if (!mounted) {
      return;
    }

    _titleController.clear();
    _descriptionController.clear();
    _categoryController.text = 'General';
    _estimateController.text = '30';
    _targetController.clear();
    _successController.clear();
    _notesController.clear();
    _rewardController.clear();
    setState(() {
      _rank = 'E';
      _difficulty = 'Normal';
      _dueDate = DateTime.now();
    });
  }

  Future<void> _pickDueDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selected != null) {
      setState(() {
        _dueDate = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SystemPanel(
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Today task',
              prefixIcon: Icon(Icons.add_task),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(Icons.notes),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _estimateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Minutes',
                    prefixIcon: Icon(Icons.timer),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _targetController,
            decoration: const InputDecoration(
              labelText: 'Target metric',
              prefixIcon: Icon(Icons.track_changes),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _successController,
            decoration: const InputDecoration(
              labelText: 'Success criteria',
              prefixIcon: Icon(Icons.verified_user),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              prefixIcon: Icon(Icons.edit_note),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _rewardController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Reward',
              prefixIcon: Icon(Icons.stars),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _difficulty,
            decoration: const InputDecoration(
              labelText: 'Difficulty',
              prefixIcon: Icon(Icons.whatshot),
            ),
            items: const ['Easy', 'Normal', 'Hard', 'Extreme']
                .map(
                  (value) => DropdownMenuItem(value: value, child: Text(value)),
                )
                .toList(),
            onChanged: widget.isSaving
                ? null
                : (value) {
                    if (value != null) {
                      setState(() {
                        _difficulty = value;
                      });
                    }
                  },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _rank,
                  decoration: const InputDecoration(
                    labelText: 'Rank',
                    prefixIcon: Icon(Icons.military_tech),
                  ),
                  items: const ['E', 'D', 'C', 'B', 'A', 'S']
                      .map(
                        (rank) => DropdownMenuItem(
                          value: rank,
                          child: Text('Rank $rank'),
                        ),
                      )
                      .toList(),
                  onChanged: widget.isSaving
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              _rank = value;
                            });
                          }
                        },
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: widget.isSaving ? null : _pickDueDate,
                icon: const Icon(Icons.event),
                label: Text(
                  '${_dueDate.month}/${_dueDate.day}/${_dueDate.year}',
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: widget.isSaving ? null : _submit,
                icon: widget.isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return SystemPanel(
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: warningGold),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFFFDCA0), fontSize: 13),
            ),
          ),
          IconButton(
            tooltip: 'Retry',
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _HunterHeader extends StatelessWidget {
  const _HunterHeader({
    required this.remainingQuests,
    required this.totalQuests,
  });

  final int remainingQuests;
  final int totalQuests;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SystemIcon(icon: Icons.auto_awesome),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SYSTEM QUEST LOG',
                      style: TextStyle(
                        color: manaBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Daily Hunter Training',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SystemPanel(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tasks Remaining',
                        style: TextStyle(
                          color: Color(0xFF98A7C7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$remainingQuests / $totalQuests',
                        style: const TextStyle(
                          color: Color(0xFFECF8FF),
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusChip(label: remainingQuests == 0 ? 'CLEARED' : 'ACTIVE'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
