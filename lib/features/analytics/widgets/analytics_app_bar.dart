import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/date.dart';
import '../../../infra/extensions/format_date.dart';
import '../../common/build_context_extensions.dart';

class AnalyticsAppBar extends StatelessWidget {
  final Date firstDayOfWeek;
  final Date lastDayOfWeek;

  final GestureTapCallback onClose;
  final GestureTapCallback onChangeWeek;

  const AnalyticsAppBar({
    required this.firstDayOfWeek,
    required this.lastDayOfWeek,
    required this.onClose,
    required this.onChangeWeek,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: onClose,
      ),
      title: Text(
        context.l10n.analytics_title,
        style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.75),
      ),
      centerTitle: false,
      actions: [
        ActionChip(
          onPressed: onChangeWeek,
          avatar: const Icon(Icons.calendar_today_outlined),
          label: Text(_getDateText(context), style: context.textTheme.labelLarge),
          surfaceTintColor: context.colorScheme.primaryContainer,
          side: BorderSide.none,
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  String _getDateText(BuildContext context) {
    final firstDayOfThisWeek = Date.today().floorToWeek();
    final firstDayOflastWeek = firstDayOfThisWeek.subtract(days: 7);

    if (firstDayOfWeek == firstDayOfThisWeek) {
      return context.l10n.analytics_date_thisWeek;
    } else if (firstDayOfWeek == firstDayOflastWeek) {
      return 'Last week';
    } else {
      final dateFormat = DateFormat(DateFormat.ABBR_MONTH_DAY);

      return '${dateFormat.formatDate(firstDayOfWeek)} - ${dateFormat.formatDate(lastDayOfWeek)}';
    }
  }
}
