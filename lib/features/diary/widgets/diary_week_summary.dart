import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/date.dart';
import '../../../infra/extensions/format_date.dart';
import '../../common/build_context_extensions.dart';

class DiaryWeekSummary extends StatelessWidget {
  final Date startDate;
  final Date endDate;
  final double gramsOfAlcohol;

  const DiaryWeekSummary({
    required this.startDate,
    required this.endDate,
    required this.gramsOfAlcohol,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat(DateFormat.NUM_MONTH_DAY);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${dateFormat.formatDate(startDate)} - ${dateFormat.formatDate(endDate)}',
                style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                context.l10n.diary_selectedWeek,
                style: context.textTheme.bodySmall,
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                context.l10n.common_mass(gramsOfAlcohol.round()),
                style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                context.l10n.diary_ofAlcohol,
                style: context.textTheme.bodySmall,
              )
            ],
          )
        ],
      ),
    );
  }
}
