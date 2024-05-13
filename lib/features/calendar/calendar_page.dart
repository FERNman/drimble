import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/date.dart';
import '../common/build_context_extensions.dart';
import 'calendar_cubit.dart';
import 'widgets/calendar_view.dart';
import 'widgets/select_month_chips.dart';

@RoutePage<Date?>()
class CalendarPage extends StatelessWidget implements AutoRouteWrapper {
  final Date initialDate;

  const CalendarPage({required this.initialDate, super.key});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => CalendarCubit(context.read(), initialDate: initialDate),
        child: this,
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarCubit, CalendarCubitBaseState>(
      buildWhen: (previous, current) => previous.runtimeType != current.runtimeType,
      builder: (context, state) => Scaffold(
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            _buildMonthSelection(),
            _buildCalendarView(),
          ],
        ),
        persistentFooterButtons: [
          _buildApplyButton(),
        ],
        persistentFooterAlignment: AlignmentDirectional.center,
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close_outlined),
        onPressed: () => context.router.pop(null),
      ),
      title: Text(context.l10n.analytics_switch_week_selectWeek),
    );
  }

  Widget _buildMonthSelection() {
    return BlocBuilder<CalendarCubit, CalendarCubitBaseState>(
      buildWhen: (previous, current) => previous.visibleMonth != current.visibleMonth,
      builder: (context, state) => SelectMonthChips(
        selectedMonth: state.visibleMonth,
        onMonthSelected: (value) => context.read<CalendarCubit>().changeVisibleMonth(value),
      ),
    );
  }

  Widget _buildCalendarView() {
    return BlocBuilder<CalendarCubit, CalendarCubitBaseState>(
      builder: (context, state) => state is CalendarCubitLoadingState
          ? const SizedBox(height: 256, child: Center(child: CircularProgressIndicator()))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: CalendarView(
                month: state.visibleMonth,
                diaryEntries: (state as CalendarCubitState).diaryEntries,
                selectedDate: state.selectedDate,
                onDateSelected: (value) => context.read<CalendarCubit>().changeSelectedDate(value),
              ),
            ),
    );
  }

  Widget _buildApplyButton() {
    return BlocBuilder<CalendarCubit, CalendarCubitBaseState>(
      buildWhen: (previous, current) => previous.selectedDate != current.selectedDate,
      builder: (context, state) => TextButton(
        onPressed: () => context.router.pop(state.selectedDate),
        child: Text(context.l10n.analytics_switch_week_apply),
      ),
    );
  }
}
