import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/date.dart';
import '../../../domain/diary/diary_entry.dart';
import '../../../infra/extensions/format_date.dart';
import '../../common/build_context_extensions.dart';

class CalendarView extends StatelessWidget {
  final Date month;
  final Map<Date, DiaryEntry> diaryEntries;

  final Date selectedDate;
  final ValueChanged<Date> onDateSelected;

  const CalendarView({
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

    final weeks = lastDayOfLastWeek.difference(firstDayOfFirstWeek).inDays ~/ 7 + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildWeekdayLabels(context),
        const SizedBox(height: 8),
        ...List.generate(weeks, (index) => _buildWeek(context, firstDayOfFirstWeek, index)),
      ],
    );
  }

  Widget _buildWeekdayLabels(BuildContext context) {
    final weekdays = DateFormat().dateSymbols.NARROWWEEKDAYS;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weekdays
            .map(
              (weekday) => SizedBox(
                width: 28, // Matches the size of one date in the calendar (sized box)
                child: Center(
                  child: Text(weekday, style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildWeek(BuildContext context, Date firstDayOfFirstWeek, int week) {
    final firstDayOfWeek = firstDayOfFirstWeek.add(days: week * 7);
    final isSelectedWeek = selectedDate.floorToWeek() == firstDayOfWeek;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        decoration: BoxDecoration(
          color: isSelectedWeek ? Colors.black.withOpacity(0.05) : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => onDateSelected(firstDayOfWeek),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                7,
                (index) => _buildDay(context, firstDayOfFirstWeek, week: week, dayOfWeek: index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDay(BuildContext context, Date firstDayOfFirstWeek, {required int week, required int dayOfWeek}) {
    final date = firstDayOfFirstWeek.add(days: dayOfWeek + week * 7);

    // This check is technically not accurate since the index of the month in different years is the same,
    // but since we're only dealing with adjacent months here, it's fine.
    final isCurrentMonth = date.month == month.month;

    final isToday = date == Date.today();

    final diaryEntry = diaryEntries[date];

    return SizedBox(
      width: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            DateFormat('d').formatDate(date),
            style: context.textTheme.bodyMedium?.copyWith(
              color: isCurrentMonth ? null : Colors.grey[400],
              fontWeight: isToday ? FontWeight.bold : null,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 8,
            height: 8,
            decoration: diaryEntry == null
                ? null
                : BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrentMonth
                        ? diaryEntry.isDrinkFreeDay
                            ? Colors.green
                            : Colors.red
                        : Colors.grey[400],
                  ),
          ),
        ],
      ),
    );
  }
}
