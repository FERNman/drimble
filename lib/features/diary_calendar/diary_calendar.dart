import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'diary_calendar_cubit.dart';
import 'widgets/diary_calendar_day.dart';

class DiaryCalendar extends StatelessWidget {
  final DateTime today = DateTime.now();

  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelectedDayChanged;

  final _scrollController = ScrollController();

  DiaryCalendar({required this.selectedDay, required this.onSelectedDayChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiaryCalendarCubit(context.read()),
      child: BlocBuilder<DiaryCalendarCubit, DiaryCalendarCubitState>(
        builder: (context, state) => SizedBox(
          height: 100,
          child: ListView.builder(
            shrinkWrap: true,
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, dayIndex) {
              final adjustedDayIndex = dayIndex - 2;
              final date = today.subtract(Duration(days: adjustedDayIndex));

              return DiaryCalendarDay(
                date: date,
                isSelected: DateUtils.isSameDay(selectedDay, date),
                isDrinkFreeDay: state.isDrinkFreeDay(date),
                onTap: date.isAfter(today)
                    ? null
                    : () {
                        _scrollTo(adjustedDayIndex);
                        onSelectedDayChanged(date);
                      },
              );
            },
          ),
        ),
      ),
    );
  }

  void _scrollTo(int index) {
    _scrollController.animateTo(
      index * DiaryCalendarDay.width,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }
}
