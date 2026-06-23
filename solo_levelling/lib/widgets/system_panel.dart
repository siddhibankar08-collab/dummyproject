import 'package:flutter/material.dart';

import '../theme/hunter_theme.dart';

class SystemPanel extends StatelessWidget {
  const SystemPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: panelBlue.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: manaBlue.withValues(alpha: 0.35)),
      ),
      child: child,
    );
  }
}
