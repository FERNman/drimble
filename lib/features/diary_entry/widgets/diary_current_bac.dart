import 'package:flutter/material.dart';

import '../../../domain/bac/bac_time_series.dart';
import '../../../domain/date.dart';
import '../../common/build_context_extensions.dart';

class DiaryCurrentBAC extends StatelessWidget {
  final Date date;
  final BACTimeSeries results;

  const DiaryCurrentBAC({
    required this.date,
    required this.results,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final text = Date.today() == date
        ? TextSpan(
            text: '${results.getEntryAt(DateTime.now())}',
            style: context.textTheme.headlineMedium,
          )
        : TextSpan(
            children: [
              TextSpan(
                text: results.maxBAC.toString(),
                style: context.textTheme.headlineMedium,
              ),
              TextSpan(
                text: context.l10n.diary_maxBAC,
                style: context.textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
            ],
          );

    return RichText(text: text);
  }
}
