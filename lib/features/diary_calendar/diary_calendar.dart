import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/date.dart';
import 'diary_calendar_cubit.dart';
import 'widgets/diary_calendar_day.dart';

class DiaryCalendar extends StatelessWidget {
  final Date today = Date.today();

  final Date selectedDay;
  final ValueChanged<Date> onSelectedDayChanged;
  static const double padding = 16;
  static const int futureDayCount = 3;

  final _scrollController = ScrollController();

  DiaryCalendar({required this.selectedDay, required this.onSelectedDayChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiaryCalendarCubit(context.read()),
      child: BlocBuilder<DiaryCalendarCubit, DiaryCalendarCubitState>(
        builder: (context, state) => SizedBox(
          height: 100,
          child: LayoutBuilder(
            builder: (context, constraints) => NotificationListener(
              child: ListView.builder(
                shrinkWrap: true,
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: padding),
                itemBuilder: (context, dayIndex) {
                  final adjustedDayIndex = dayIndex - futureDayCount;
                  final date = today.subtract(days: adjustedDayIndex);

                  return DiaryCalendarDay(
                    date: date,
                    isSelected: selectedDay == date,
                    isDrinkFreeDay: state.isDrinkFreeDay(date),
                    onTap: date.isAfter(today)
                        ? null
                        : () {
                            _scrollTo(adjustedDayIndex, constraints);
                            onSelectedDayChanged(date);
                          },
                  );
                },
              ),
              onNotification: (notification) {
                if (notification is ScrollNotification) {
                  _updateVisibleRange(context, constraints, notification);
                  return true;
                }
                return false;
              },
            ),
          ),
        ),
      ),
    );
  }

  void _updateVisibleRange(BuildContext context, BoxConstraints constraints, ScrollNotification notification) {
    final endPixels = notification.metrics.pixels;
    final startPixels = notification.metrics.pixels + constraints.maxWidth;

    final endIndex = ((endPixels - padding) / DiaryCalendarDay.width).floor() - futureDayCount;
    final startIndex = ((startPixels - padding) / DiaryCalendarDay.width).ceil() - futureDayCount;

    context
        .read<DiaryCalendarCubit>()
        .updateRange(Date.today().subtract(days: startIndex), Date.today().subtract(days: endIndex));
  }

  void _scrollTo(int index, BoxConstraints constraints) {
    final offsetToCenter = padding + DiaryCalendarDay.width / 2 - constraints.maxWidth / 2;
    final itemOffset = (index + futureDayCount) * DiaryCalendarDay.width;

    _scrollController.animateTo(
      itemOffset + offsetToCenter,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }
}
