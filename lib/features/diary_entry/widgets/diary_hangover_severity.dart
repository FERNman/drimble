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
      // Diary entry is in the past -> Display hangover severity
      if (predictedHangoverSeverity == null) {
        return _buildHangoverSelection(context);
      } else {
        return Text(predictedHangoverSeverity!.translate(context), style: context.textTheme.bodyMedium);
      }
    } else {
      if (predictedHangoverSeverity == null) {
        return const SizedBox.shrink();
      }

      // Diary entry is today -> Display hangover prediction
      return Text(predictedHangoverSeverity!.translate(context), style: context.textTheme.bodyMedium);
    }
  }

  Widget _buildHangoverSelection(BuildContext context) {
    return OutlinedButton(
      onPressed: onEnterHangoverSeverity,
      child: Text(context.l10n.diary_trackYourHangover),
    );
  }
}
