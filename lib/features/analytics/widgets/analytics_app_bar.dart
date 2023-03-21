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
      title: Text(
        context.l18n.analytics_title,
        style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.75),
      ),
      centerTitle: false,
      actions: [
        ActionChip(
          onPressed: () {},
          avatar: const Icon(Icons.calendar_today_outlined),
          label: Text(context.l18n.analytics_date_thisWeek, style: context.textTheme.labelLarge),
          surfaceTintColor: context.colorScheme.primaryContainer,
          side: BorderSide.none,
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
