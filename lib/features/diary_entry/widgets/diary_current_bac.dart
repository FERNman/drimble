import 'package:flutter/material.dart';

import '../../../domain/bac/bac_calculation_results.dart';
import '../../../domain/date.dart';
import '../../../domain/diary/diary_entry.dart';
import '../../../infra/l10n/hangover_severity_translations.dart';
import '../../common/build_context_extensions.dart';

class DiaryCurrentBAC extends StatelessWidget {
  final BACCalculationResults results;
  final DiaryEntry diaryEntry;

  final GestureTapCallback onSelectHangoverSeverity;

  const DiaryCurrentBAC({
    required this.results,
    required this.diaryEntry,
    required this.onSelectHangoverSeverity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBAC(context),
          const SizedBox(height: 8),
          _buildHangoverSeverity(context),
        ],
      ),
    );
  }

  Widget _buildBAC(BuildContext context) {
    final text = Date.today() == diaryEntry.date
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

  Widget _buildHangoverSeverity(BuildContext context) {
    final now = DateTime.now();

    if (results.endTime.isAfter(now)) {
      // Still drunk -> Display hangover prediction
      return Text(context.l10n.diary_hangoverPrediction, style: context.textTheme.bodyMedium);
    } else {
      // Sober -> Display hangover severity
      if (diaryEntry.hangoverSeverity == null) {
        return _buildHangoverSelection(context);
      } else {
        return Text(diaryEntry.hangoverSeverity!.translate(context), style: context.textTheme.bodyMedium);
      }
    }
  }

  Widget _buildHangoverSelection(BuildContext context) {
    return OutlinedButton(
      onPressed: onSelectHangoverSeverity,
      child: Text(context.l10n.diary_trackYourHangover),
    );
  }
}
