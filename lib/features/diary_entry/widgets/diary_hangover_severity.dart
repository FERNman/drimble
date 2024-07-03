import 'package:flutter/material.dart';

import '../../../domain/date.dart';
import '../../../domain/diary/hangover_severity.dart';
import '../../../infra/l10n/hangover_severity_translations.dart';
import '../../common/build_context_extensions.dart';

class DiaryHangoverSeverity extends StatelessWidget {
  final Date date;
  final HangoverSeverity? trackedHangoverSeverity;
  final HangoverSeverity? predictedHangoverSeverity;

  final GestureTapCallback onEnterHangoverSeverity;

  const DiaryHangoverSeverity({
    required this.date,
    required this.trackedHangoverSeverity,
    required this.predictedHangoverSeverity,
    required this.onEnterHangoverSeverity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final today = Date.today();

    if (date.isBefore(today)) {
      // Diary entry is in the past -> Display tracked hangover severity
      if (trackedHangoverSeverity == null) {
        return _buildHangoverSelection(context);
      } else {
        return Text(trackedHangoverSeverity!.translate(context), style: context.textTheme.bodyMedium);
      }
    } else {
      if (predictedHangoverSeverity == null) {
        return const SizedBox.shrink();
      }

      // Diary entry is today -> Display hangover prediction
      return _buildPredictedHangoverSeverity(context);
    }
  }

  Widget _buildPredictedHangoverSeverity(BuildContext context) {
    final labelStyle = context.textTheme.labelMedium?.copyWith(color: context.colorScheme.onSurface.withOpacity(0.7));

    switch (predictedHangoverSeverity!) {
      case HangoverSeverity.none:
        return Text(context.l10n.diary_predictingNoHangover, style: labelStyle);
      case HangoverSeverity.veryMild:
      case HangoverSeverity.mild:
        return Text(context.l10n.diary_predictingMildHangover, style: labelStyle);
      case HangoverSeverity.moderate:
      case HangoverSeverity.prettyBad:
        return Text(context.l10n.diary_predictingBadHangover, style: labelStyle);
      case HangoverSeverity.heavy:
      case HangoverSeverity.severe:
        return Text(context.l10n.diary_predictingSevereHangover, style: labelStyle);
    }
  }

  Widget _buildHangoverSelection(BuildContext context) {
    return OutlinedButton(
      onPressed: onEnterHangoverSeverity,
      child: Text(context.l10n.diary_trackYourHangover),
    );
  }
}
