import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/date.dart';
import '../../../domain/diary/diary_entry.dart';
import '../../../infra/extensions/format_date.dart';
import '../../common/build_context_extensions.dart';
import '../../common/widgets/diary_calendar_day.dart';

class CalendarMonth extends StatelessWidget {
  static const _spacing = 8.0;

  static const _titlePadding = 8.0;
  static const _titleFontSize = 24.0;
  static const _titleLineHeight = 1.2;

  static const _weekdayLabelFontSize = 14.0;
  static const _weekdayLabelLineHeight = 1.0;

  static double calculateHeight(Date month) {
    final firstDayOfMonth = month.floorToMonth();
    final lastDayOfMonth = firstDayOfMonth.add(months: 1).subtract(days: 1);

    final firstDayOfFirstWeek = firstDayOfMonth.subtract(days: firstDayOfMonth.weekday - 1);
    final lastDayOfLastWeek = lastDayOfMonth.add(days: 7 - lastDayOfMonth.weekday);

    final weeksThisMonth = lastDayOfLastWeek.difference(firstDayOfFirstWeek).inDays ~/ 7 + 1;

    return _spacing * 2 +
        _titlePadding * 2 +
        (_titleFontSize * _titleLineHeight).round() +
        _weekdayLabelFontSize * _weekdayLabelLineHeight +
        DiaryCalendarDay.height * weeksThisMonth;
  }

  final Date month;
  final Map<Date, DiaryEntry> diaryEntries;

  final Date selectedDate;
  final ValueChanged<Date> onDateSelected;

  const CalendarMonth({
    required this.month,
    required this.diaryEntries,
    required this.selectedDate,
    required this.onDateSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = month.floorToMonth();
    final lastDayOfMonth = firstDayOfMonth.add(months: 1).subtract(days: 1);

    final firstDayOfFirstWeek = firstDayOfMonth.subtract(days: firstDayOfMonth.weekday - 1);
    final lastDayOfLastWeek = lastDayOfMonth.add(days: 7 - lastDayOfMonth.weekday);

    final weeksThisMonth = lastDayOfLastWeek.difference(firstDayOfFirstWeek).inDays ~/ 7 + 1;

    return SizedBox(
      height: calculateHeight(month),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(_titlePadding),
            child: Text(
              DateFormat(DateFormat.YEAR_MONTH).formatDate(month),
              style: context.textTheme.headlineSmall?.copyWith(fontSize: _titleFontSize, height: _titleLineHeight),
            ),
          ),
          const SizedBox(height: _spacing),
          _buildWeekdayLabels(context),
          const SizedBox(height: _spacing),
          _buildDays(weeksThisMonth, firstDayOfFirstWeek, firstDayOfMonth, lastDayOfMonth),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels(BuildContext context) {
    final weekdays = DateFormat().dateSymbols.NARROWWEEKDAYS;
    final textStyle = context.textTheme.bodyMedium?.copyWith(
      fontSize: _weekdayLabelFontSize,
      height: _weekdayLabelLineHeight,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays
          .map((weekday) => SizedBox(
              width: 14.0, // Fixed to make all labels the same width
              child: Text(
                weekday,
                style: textStyle,
                textAlign: TextAlign.center,
              )))
          .toList(),
    );
  }

  Widget _buildDays(int weekCount, Date firstDayOfFirstWeek, Date firstDayOfMonth, Date lastDayOfMonth) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: weekCount * 7,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: DiaryCalendarDay.height,
      ),
      itemBuilder: (context, index) {
        final date = firstDayOfFirstWeek.add(days: index);
        if (date.isBefore(firstDayOfMonth) || date.isAfter(lastDayOfMonth)) {
          return const SizedBox();
        }

        final isInFuture = date.isAfter(Date.today());

        return DiaryCalendarDay(
          date: date,
          isSelected: date == selectedDate,
          diaryEntry: diaryEntries[date],
          onTap: isInFuture ? null : () => onDateSelected(date),
          dateFormat: DateFormat('d'),
        );
      },
    );
  }
}
