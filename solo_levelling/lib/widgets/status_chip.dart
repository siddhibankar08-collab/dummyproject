import 'package:flutter/material.dart';

import '../theme/hunter_theme.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: manaBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: manaBlue),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: manaBlue,
          fontWeight: FontWeight.w800,
          fontSize: 13,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
