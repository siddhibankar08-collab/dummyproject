import 'package:flutter/material.dart';

import '../models/hunter_stat.dart';
import '../theme/hunter_theme.dart';
import 'system_panel.dart';

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.stat});

  final HunterStat stat;

  @override
  Widget build(BuildContext context) {
    return SystemPanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(stat.icon, color: manaBlue, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label,
                  style: const TextStyle(
                    color: Color(0xFF98A7C7),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${stat.value}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1,
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
