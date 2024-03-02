import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/date.dart';
import 'diary_calendar_cubit.dart';
import 'widgets/diary_calendar_day.dart';

class DiaryCalendar extends StatefulWidget {
  final Date selectedDay;
  final ValueChanged<Date> onSelectedDayChanged;
  static const double padding = 16;
  static const int futureDayCount = 3;

  const DiaryCalendar({required this.selectedDay, required this.onSelectedDayChanged, super.key});

  @override
  State<DiaryCalendar> createState() => _DiaryCalendarState();
}

class _DiaryCalendarState extends State<DiaryCalendar> {
  final Date today = Date.today();

  ScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiaryCalendarCubit(context.read()),
      child: BlocBuilder<DiaryCalendarCubit, DiaryCalendarCubitState>(
        builder: (context, state) => SizedBox(
          height: 100,
          child: LayoutBuilder(
            builder: (context, constraints) {
              _scrollController ??= ScrollController(initialScrollOffset: _calculateInitialScrollOffset(constraints));

              return NotificationListener(
                child: ListView.builder(
                  shrinkWrap: true,
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: DiaryCalendar.padding),
                  itemBuilder: (context, dayIndex) {
                    final adjustedDayIndex = dayIndex - DiaryCalendar.futureDayCount;
                    final date = today.subtract(days: adjustedDayIndex);

                    return DiaryCalendarDay(
                      date: date,
                      isSelected: widget.selectedDay == date,
                      isDrinkFreeDay: state.isDrinkFreeDay(date),
                      onTap: date.isAfter(today)
                          ? null
                          : () {
                              _scrollTo(adjustedDayIndex, constraints);
                              widget.onSelectedDayChanged(date);
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
              );
            },
          ),
        ),
      ),
    );
  }

  void _updateVisibleRange(BuildContext context, BoxConstraints constraints, ScrollNotification notification) {
    final endPixels = notification.metrics.pixels;
    final startPixels = notification.metrics.pixels + constraints.maxWidth;

    final endIndex =
        ((endPixels - DiaryCalendar.padding) / DiaryCalendarDay.width).floor() - DiaryCalendar.futureDayCount;
    final startIndex =
        ((startPixels - DiaryCalendar.padding) / DiaryCalendarDay.width).ceil() - DiaryCalendar.futureDayCount;

    context
        .read<DiaryCalendarCubit>()
        .updateRange(Date.today().subtract(days: startIndex), Date.today().subtract(days: endIndex));
  }

  void _scrollTo(int index, BoxConstraints constraints) {
    _scrollController!.animateTo(
      _calculateScrollOffset(index, constraints),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  double _calculateInitialScrollOffset(BoxConstraints constraints) {
    return _calculateScrollOffset(0, constraints);
  }

  double _calculateScrollOffset(int index, BoxConstraints constraints) {
    final itemOffset = (index + DiaryCalendar.futureDayCount) * DiaryCalendarDay.width;
    final offsetToCenter = DiaryCalendar.padding + DiaryCalendarDay.width / 2 - constraints.maxWidth / 2;
    return itemOffset + offsetToCenter;
  }
}
