import 'package:flutter/material.dart';

import '../../../domain/date.dart';
import '../../../domain/diary/diary_entry.dart';
import 'diary_calendar_day.dart';

class DiaryCalendarWeek extends StatelessWidget {
  final Date selectedDate;
  final Date weekStartDate;

  final Map<Date, DiaryEntry> diaryEntries;

  final ValueChanged<Date> onChangeDate;

  const DiaryCalendarWeek({
    super.key,
    required this.selectedDate,
    required this.weekStartDate,
    required this.diaryEntries,
    required this.onChangeDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final date = weekStartDate.add(days: index);

        return DiaryCalendarDay(
          date: date,
          isSelected: selectedDate == date,
          diaryEntry: diaryEntries[date],
          onTap: date.isAfter(Date.today()) ? null : () => onChangeDate(date),
        );
      }),
    );
  }
}
