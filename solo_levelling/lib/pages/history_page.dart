import 'package:flutter/material.dart';

import '../models/quest.dart';
import '../theme/hunter_theme.dart';
import '../widgets/quest_card.dart';
import '../widgets/system_icon.dart';
import '../widgets/system_panel.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({
    super.key,
    required this.selectedDate,
    required this.quests,
    required this.isLoading,
    required this.onDateChanged,
    required this.onRefresh,
  });

  final DateTime selectedDate;
  final List<Quest> quests;
  final bool isLoading;
  final ValueChanged<DateTime> onDateChanged;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final completed = quests.where((quest) => quest.isComplete).length;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SystemIcon(icon: Icons.history),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'HISTORY',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _pickDate(context),
                        icon: const Icon(Icons.event),
                        label: Text(_formatDate(selectedDate)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SystemPanel(
                    child: Row(
                      children: [
                        Expanded(
                          child: _Metric(
                            label: 'Committed',
                            value: '${quests.length}',
                          ),
                        ),
                        Expanded(
                          child: _Metric(
                            label: 'Completed',
                            value: '$completed',
                          ),
                        ),
                        Expanded(
                          child: _Metric(
                            label: 'Missed',
                            value: '${quests.length - completed}',
                          ),
                        ),
                      ],
                    ),
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
          else if (quests.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No commitments for this day.',
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
                  return QuestCard(quest: quests[index], onChanged: (_) {});
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 366)),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      onDateChanged(selected);
    }
  }

  String _formatDate(DateTime date) => '${date.month}/${date.day}/${date.year}';
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF98A7C7), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: manaBlue,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
