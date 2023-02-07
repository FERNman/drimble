import 'package:flutter/material.dart';

import '../../common/build_context_extensions.dart';

class AnalyticsAppBar extends StatelessWidget {
  final DateTime firstDayOfWeek;
  final DateTime lastDayOfWeek;

  const AnalyticsAppBar({
    required this.firstDayOfWeek,
    required this.lastDayOfWeek,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l18n.analytics_title,
              style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.75),
            ),
            const SizedBox(height: 4),
            Text(
              context.l18n.analytics_weekFromTo(firstDayOfWeek, lastDayOfWeek),
              style: context.textTheme.bodySmall,
            ),
          ],
        ),
      ),
      centerTitle: false,
    );
  }
}
