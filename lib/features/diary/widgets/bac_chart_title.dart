import 'package:flutter/material.dart';

import '../../../domain/bac/bac_calculation_results.dart';
import '../../../domain/date.dart';
import '../../../domain/diary/diary_entry.dart';
import '../../common/build_context_extensions.dart';

class BACChartTitle extends StatelessWidget {
  final Date date;
  final BACCalculationResults results;
  final DiaryEntry? diaryEntry;

  final GestureTapCallback onMarkAsDrinkFreeDay;

  const BACChartTitle({
    required this.date,
    required this.results,
    required this.diaryEntry,
    required this.onMarkAsDrinkFreeDay,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTitle(context),
          const SizedBox(height: 8),
          _buildSubtitle(context),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    if (diaryEntry == null) {
      return Text(
        context.l18n.diary_notDrinkingToday,
        style: context.textTheme.titleLarge,
      );
    } else if (diaryEntry!.isDrinkFreeDay) {
      return Text(
        context.l18n.diary_drinkFreeDay,
        style: context.textTheme.titleLarge,
      );
    } else {
      return _buildBAC(context);
    }
  }

  Widget _buildBAC(BuildContext context) {
    final text = Date.today() == date
        ? TextSpan(
            text: '${results.getEntryAt(DateTime.now())}',
            style: context.textTheme.displaySmall,
          )
        : TextSpan(
            children: [
              TextSpan(
                text: results.maxBAC.toString(),
                style: context.textTheme.displaySmall,
              ),
              TextSpan(
                text: context.l18n.diary_maxBAC,
                style: context.textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
            ],
          );

    return RichText(text: text);
  }

  Widget _buildSubtitle(BuildContext context) {
    if (diaryEntry == null) {
      return FilledButton(
        onPressed: onMarkAsDrinkFreeDay,
        child: Text(context.l18n.diary_markAsDrinkFreeDay),
      );
    } else if (diaryEntry!.isDrinkFreeDay) {
      return Text(context.l18n.diary_drinkFreeDayGreatJob, style: context.textTheme.bodyMedium);
    } else {
      return _buildSobrietyText(context);
    }
  }

  Widget _buildSobrietyText(BuildContext context) {
    final now = DateTime.now();
    final soberAt = results.soberAt;

    if (soberAt.isAfter(now)) {
      if (soberAt.day > now.day) {
        return Text(context.l18n.diary_soberTomorrowAt(soberAt), style: context.textTheme.bodyMedium);
      } else {
        return Text(context.l18n.diary_soberAt(soberAt), style: context.textTheme.bodyMedium);
      }
    } else {
      return Text(context.l18n.diary_youreSober, style: context.textTheme.bodyMedium);
    }
  }
}
