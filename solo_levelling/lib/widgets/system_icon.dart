import 'package:flutter/material.dart';

import '../theme/hunter_theme.dart';

class SystemIcon extends StatelessWidget {
  const SystemIcon({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: manaBlue),
        boxShadow: [
          BoxShadow(color: manaBlue.withValues(alpha: 0.35), blurRadius: 18),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFF152A48), Color(0xFF261044)],
        ),
      ),
      child: Icon(icon, color: manaBlue),
    );
  }
}
