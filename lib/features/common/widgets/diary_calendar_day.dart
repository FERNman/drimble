import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/date.dart';
import '../../../domain/diary/diary_entry.dart';
import '../../../domain/diary/hangover_severity.dart';
import '../../../infra/extensions/format_date.dart';
import '../../../infra/l10n/hangover_severity_translations.dart';
import '../build_context_extensions.dart';

class DiaryCalendarDay extends StatelessWidget {
  // We track all the sizes in constants to make the full height of the widget calculatable
  static const _hangoverIndicatorSize = 28.0;
  static const _horizontalPadding = 12.0;
  static const _verticalPadding = 8.0;
  static const _spacing = 6.0;
  static const _labelFontSize = 11.0;
  static const _labelLineHeight = 1.2;

  // The width is determined by the hangover indicator
  static const width = _horizontalPadding * 2 + _hangoverIndicatorSize;
  static const height =
      _verticalPadding * 2 + _spacing * 2 + (_labelFontSize * _labelLineHeight) * 2 + _hangoverIndicatorSize;

  final Date date;
  final bool isSelected;

  final DiaryEntry? diaryEntry;
  final GestureTapCallback? onTap;

  final DateFormat _dateFormat;

  DiaryCalendarDay({
    required this.date,
    required this.isSelected,
    required this.diaryEntry,
    required this.onTap,
    DateFormat? dateFormat,
    super.key,
  }) : _dateFormat = dateFormat ?? DateFormat(DateFormat.ABBR_WEEKDAY);

  @override
  Widget build(BuildContext context) {
    final dayOfWeek = _dateFormat.formatDate(date);

    final dayOfWeekTextStyle = context.textTheme.labelSmall?.copyWith(
      color: onTap == null ? Colors.black26 : Colors.black87,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      fontSize: _labelFontSize,
      height: _labelLineHeight,
    );

    final gramsOfAlcohol = diaryEntry == null ? '-' : context.l10n.common_mass(diaryEntry!.gramsOfAlcohol.round());

    return SizedBox(
      height: height,
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: _verticalPadding, horizontal: _horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(dayOfWeek.toLowerCase(), style: dayOfWeekTextStyle),
              const SizedBox(height: _spacing),
              _drawHangoverIndicator(context),
              const SizedBox(height: _spacing),
              Text(gramsOfAlcohol, style: dayOfWeekTextStyle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawHangoverIndicator(BuildContext context) {
    const emojiSize = 15.0;

    final container = Container(
      width: _hangoverIndicatorSize,
      height: _hangoverIndicatorSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _getColor(), width: 3, strokeAlign: BorderSide.strokeAlignCenter),
      ),
      child: Center(
        child: SizedBox(
          width: emojiSize,
          height: emojiSize,
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
