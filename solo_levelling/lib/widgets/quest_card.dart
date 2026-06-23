import 'package:flutter/material.dart';

import '../models/quest.dart';
import '../theme/hunter_theme.dart';
import 'quest_badge.dart';

class QuestCard extends StatelessWidget {
  const QuestCard({
    super.key,
    required this.quest,
    required this.onChanged,
    this.onTap,
  });

  final Quest quest;
  final ValueChanged<bool?> onChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = quest.isComplete
        ? successGreen.withValues(alpha: 0.55)
        : manaBlue.withValues(alpha: 0.45);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: quest.isComplete
                ? const Color(0xFF10281E).withValues(alpha: 0.72)
                : panelBlue.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.24),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Checkbox(
                value: quest.isComplete,
                onChanged: quest.isComplete ? null : onChanged,
                activeColor: successGreen,
                checkColor: const Color(0xFF06110D),
                side: const BorderSide(color: manaBlue, width: 1.5),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      style: TextStyle(
                        color: quest.isComplete
                            ? const Color(0xFF91A79F)
                            : const Color(0xFFF3F8FF),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        decoration: quest.isComplete
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (quest.description.isNotEmpty) ...[
                      Text(
                        quest.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFB8C5DD),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        QuestBadge(label: 'Rank ${quest.rank}'),
                        const SizedBox(width: 8),
                        QuestBadge(label: quest.category),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            quest.reward.isEmpty
                                ? '${quest.estimatedMinutes} min'
                                : quest.reward,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: runePurple,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                tooltip: quest.isComplete ? 'Completed' : 'Complete quest',
                onPressed: quest.isComplete ? null : () => onChanged(true),
                icon: Icon(
                  quest.isComplete ? Icons.lock : Icons.check_circle_outline,
                  color: quest.isComplete ? successGreen : manaBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
