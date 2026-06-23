import 'package:flutter/material.dart';

import '../theme/hunter_theme.dart';

class HunterBackground extends StatelessWidget {
  const HunterBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [voidBlue, Color(0xFF101C36), Color(0xFF120A24)],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}
