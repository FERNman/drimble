import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/date.dart';
import '../../../domain/diary/diary_entry.dart';
import '../../../domain/diary/hangover_severity.dart';
import '../../../infra/extensions/format_date.dart';
import '../../../infra/l10n/hangover_severity_translations.dart';
import '../../common/build_context_extensions.dart';

class DiaryCalendarDay extends StatelessWidget {
  final Date date;
  final bool isSelected;
  final DiaryEntry? diaryEntry;
  final GestureTapCallback? onTap;

  static const _emojiSize = 15.0;

  const DiaryCalendarDay({
    required this.date,
    required this.isSelected,
    required this.diaryEntry,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dayOfWeek = DateFormat(DateFormat.ABBR_WEEKDAY).formatDate(date);

    final dayOfWeekTextStyle = context.textTheme.labelSmall?.copyWith(
      color: onTap == null ? Colors.black26 : Colors.black87,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    );

    final gramsOfAlcohol = diaryEntry == null ? '-' : context.l10n.common_mass(diaryEntry!.gramsOfAlcohol.round());

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(dayOfWeek.toLowerCase(), style: dayOfWeekTextStyle),
            const SizedBox(height: 6),
            _drawHangoverIndicator(context),
            const SizedBox(height: 6),
            Text(gramsOfAlcohol, style: dayOfWeekTextStyle),
          ],
        ),
      ),
    );
  }

  Widget _drawHangoverIndicator(BuildContext context) {
    final container = Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _getColor(), width: 3, strokeAlign: BorderSide.strokeAlignCenter),
      ),
      child: Center(
        child: SizedBox(
          width: _emojiSize,
          height: _emojiSize,
          child: Text(
            _getIcon(),
            style: context.textTheme.bodyMedium?.copyWith(height: 1),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    if (diaryEntry == null) {
      return DottedBorder(
        color: onTap == null ? Colors.black26 : Colors.black87,
        borderType: BorderType.Circle,
        dashPattern: const <double>[2, 3],
        strokeWidth: 2,
        padding: EdgeInsets.zero,
        child: container,
      );
    } else {
      return container;
    }
  }

  String _getIcon() {
    if (diaryEntry == null) {
      return '';
    } else if (diaryEntry!.isDrinkFreeDay == true) {
      return '🎉';
    } else {
      return diaryEntry!.hangoverSeverity?.icon() ?? '🤔';
    }
  }

  Color _getColor() {
    if (diaryEntry == null) {
      return Colors.transparent;
    } else if (diaryEntry?.isDrinkFreeDay == true) {
      return Colors.green;
    } else if (diaryEntry?.hangoverSeverity == HangoverSeverity.none) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
