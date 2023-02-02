import 'package:flutter/material.dart';

import '../../../domain/bac_calulation_results.dart';
import '../../../domain/diary/diary_entry.dart';
import '../../common/build_context_extensions.dart';

class BACChartTitle extends StatelessWidget {
  final DateTime dateTime;
  final BACCalculationResults results;
  final DiaryEntry? diaryEntry;

  final GestureTapCallback onMarkAsDrinkFreeDay;

  const BACChartTitle({
    required this.dateTime,
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
    if (_isDrunk()) {
      return Text(
        '${results.getEntryAt(dateTime).value.toStringAsFixed(2)}‰',
        style: context.textTheme.headlineMedium?.copyWith(color: Colors.black87),
      );
    }

    if (diaryEntry == null) {
      return Text(
        context.l18n.diary_notDrinkingToday,
        style: context.textTheme.titleLarge?.copyWith(color: Colors.black87),
      );
    } else if (diaryEntry!.isDrinkFreeDay) {
      return Text(
        context.l18n.diary_drinkFreeDay,
        style: context.textTheme.titleLarge?.copyWith(color: Colors.black87),
      );
    } else if (DateUtils.isSameDay(DateTime.now(), dateTime)) {
      return Text(
        '${results.getEntryAt(dateTime).value.toStringAsFixed(2)}‰',
        style: context.textTheme.headlineMedium?.copyWith(color: Colors.black87),
      );
    } else {
      final maxBAC = results.maxBAC;
      return Text(
        '${maxBAC.value.toStringAsFixed(2)}‰ max',
        style: context.textTheme.titleLarge?.copyWith(color: Colors.black87),
      );
    }
  }

  Widget _buildSubtitle(BuildContext context) {
    if (_isDrunk()) {
      return Text(_drunkSubtitle(context), style: context.textTheme.bodyMedium);
    }

    if (diaryEntry == null) {
      return FilledButton(
        onPressed: onMarkAsDrinkFreeDay,
        child: Text(context.l18n.diary_markAsDrinkFreeDay),
      );
    } else if (diaryEntry!.isDrinkFreeDay) {
      return Text(context.l18n.diary_drinkFreeDayGreatJob, style: context.textTheme.bodyMedium);
    } else {
      return Text(context.l18n.diary_youreSober, style: context.textTheme.bodyMedium);
    }
  }

  String _drunkSubtitle(BuildContext context) {
    final now = DateTime.now();
    final soberAt = results.soberAt;
    final maxBAC = results.findMaxEntryAfter(now);
    final currentBAC = results.getEntryAt(now);

    if (maxBAC.value > currentBAC.value && maxBAC.time.isAfter(now)) {
      return context.l18n.diary_reachesMaxBACAt(maxBAC.value.toStringAsFixed(2), maxBAC.time);
    } else if (soberAt.isAfter(now)) {
      if (soberAt.day > now.day) {
        return context.l18n.diary_soberTomorrowAt(soberAt);
      } else {
        return context.l18n.diary_soberAt(soberAt);
      }
    } else {
      // This should never happen
      return context.l18n.diary_youreSober;
    }
  }

  bool _isDrunk() => results.soberAt.isAfter(DateTime.now());
}
