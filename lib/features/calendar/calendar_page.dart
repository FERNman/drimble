import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/date.dart';
import '../common/build_context_extensions.dart';
import 'calendar_cubit.dart';
import 'widgets/calendar_month.dart';

@RoutePage<Date?>()
class CalendarPage extends StatefulWidget implements AutoRouteWrapper {
  final Date initialDate;

  const CalendarPage({required this.initialDate, super.key});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => CalendarCubit(context.read(), initiallyVisibleDate: initialDate),
        child: this,
      );

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  static const _itemSpacing = 12.0;

  late final ScrollController _scrollController;
  final Date _monthWithZeroIndex = Date.today().floorToMonth();

  // In a perfect world, we would create our own ListView and corresponding ScrollController that enables scrolling by index based on item height
  final List<double> _itemHeightCache = [];

  @override
  void initState() {
    super.initState();

    var currentVisibleMonthIndex = _monthWithZeroIndex.differenceInMonths(widget.initialDate);

    final initialScrollOffset = _getScrollOffsetForIndex(currentVisibleMonthIndex);
    _scrollController = ScrollController(initialScrollOffset: initialScrollOffset)
      ..addListener(() {
        final currentMonth = _monthWithZeroIndex.subtract(months: currentVisibleMonthIndex);
        final currentMonthHeight = CalendarMonth.calculateHeight(currentMonth) + _itemSpacing;
        final currentVisibleMonthScrollOffset = _getScrollOffsetForIndex(currentVisibleMonthIndex);

        // Scroll offset can become negative because of the bounce effect
        final scrollOffset = max(0, _scrollController.offset);
        if (scrollOffset > currentVisibleMonthScrollOffset + currentMonthHeight) {
          currentVisibleMonthIndex++;

          final month = _monthWithZeroIndex.subtract(months: currentVisibleMonthIndex);
          context.read<CalendarCubit>().loadEntriesForMonth(month);
        } else if (scrollOffset < currentVisibleMonthScrollOffset) {
          currentVisibleMonthIndex--;

          final month = _monthWithZeroIndex.subtract(months: currentVisibleMonthIndex);
          context.read<CalendarCubit>().loadEntriesForMonth(month);
        }
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(context.l10n.calendar_title),
      ),
      body: BlocBuilder<CalendarCubit, CalendarCubitBaseState>(
        buildWhen: (previous, current) => previous.runtimeType != current.runtimeType,
        builder: (context, state) => state is CalendarCubitLoadingState
            ? const SizedBox(height: 256, child: Center(child: CircularProgressIndicator()))
            : _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        reverse: true,
        itemExtentBuilder: (index, dimensions) => _getItemExtentForIndex(index),
        itemBuilder: (context, index) {
          final month = _monthWithZeroIndex.subtract(months: index);

          // We need this builder here because the month might render before the diary entries are loaded
          return BlocBuilder<CalendarCubit, CalendarCubitBaseState>(
            buildWhen: (previous, current) =>
                _monthWasLoaded(previous as CalendarCubitState, current as CalendarCubitState, month),
            builder: (context, state) => CalendarMonth(
              month: month,
              diaryEntries: (state as CalendarCubitState).diaryEntries,
              selectedDate: widget.initialDate,
              onDateSelected: (value) => context.router.pop(value),
            ),
          );
        },
      ),
    );
  }

  bool _monthWasLoaded(CalendarCubitState previous, CalendarCubitState current, Date month) {
    return (previous.earliestLoadedDate.isAfter(month) && current.earliestLoadedDate.isBefore(month) ||
        previous.latestLoadedDate.isBefore(month) && current.latestLoadedDate.isAfter(month));
  }

  double _getItemExtentForIndex(int index) {
    if (index >= _itemHeightCache.length) {
      _calulateItemHeightForRange(_itemHeightCache.length, index + 1);
    }

    return _itemHeightCache[index];
  }

  double _getScrollOffsetForIndex(int index) {
    if (index >= _itemHeightCache.length) {
      _calulateItemHeightForRange(_itemHeightCache.length, index + 1);
    }

    return _itemHeightCache.slice(0, index).sum;
  }

  void _calulateItemHeightForRange(int start, int end) {
    _itemHeightCache.addAll(List.generate(end - start, (i) {
      final month = _monthWithZeroIndex.subtract(months: start + i);
      return CalendarMonth.calculateHeight(month) + _itemSpacing;
    }));
  }
}
