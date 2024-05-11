import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/date.dart';
import '../../router.gr.dart';
import '../diary_entry/diary_entry_page.dart';
import 'diary_cubit.dart';
import 'widgets/diary_app_bar.dart';
import 'widgets/diary_calendar_week.dart';
import 'widgets/diary_drink_free_day.dart';
import 'widgets/diary_mark_as_drink_free.dart';
import 'widgets/diary_week_summary.dart';

@RoutePage()
class DiaryPage extends StatelessWidget implements AutoRouteWrapper {
  const DiaryPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => DiaryCubit(context.read(), Date.today()),
        child: this,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAppBar(context),
            _buildHeader(),
            const SizedBox(height: 24),
            _buildBody(),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return DiaryAppBar(
      onTapCalendar: () async {
        final cubitState = context.read<DiaryCubit>().state;
        context.router.push(CalendarRoute(initialDate: cubitState.selectedDate)).then((result) {
          if (result != null) {
            context.read<DiaryCubit>().switchDate(result as Date);
          }
        });
      },
      onTapProfile: () {
        context.router.push(const ProfileRoute());
      },
    );
  }

  Widget _buildHeader() {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 8, right: 8),
        child: Column(
          children: [
            BlocBuilder<DiaryCubit, DiaryCubitState>(
              buildWhen: (previous, current) =>
                  previous.weekStartDate != current.weekStartDate || previous.gramsOfAlcohol != current.gramsOfAlcohol,
              builder: (context, state) => DiaryWeekSummary(
                startDate: state.weekStartDate,
                endDate: state.weekEndDate,
                gramsOfAlcohol: state.gramsOfAlcohol,
              ),
            ),
            BlocBuilder<DiaryCubit, DiaryCubitState>(
              buildWhen: (previous, current) =>
                  previous.selectedDate != current.selectedDate || previous.diaryEntries != current.diaryEntries,
              builder: (context, state) => DiaryCalendarWeek(
                selectedDate: state.selectedDate,
                weekStartDate: state.weekStartDate,
                diaryEntries: state.diaryEntries,
                onChangeDate: (date) => context.read<DiaryCubit>().switchDate(date),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<DiaryCubit, DiaryCubitState>(
      buildWhen: (previous, current) =>
          previous.selectedDate != current.selectedDate ||
          previous.selectedDiaryEntry?.isDrinkFreeDay != current.selectedDiaryEntry?.isDrinkFreeDay,
      builder: (context, state) {
        if (state.selectedDiaryEntry == null) {
          return DiaryMarkAsDrinkFree(
            onMarkAsDrinkFreeDay: () => context.read<DiaryCubit>().markAsDrinkFreeDay(),
          );
        } else if (state.selectedDiaryEntry!.isDrinkFreeDay == true) {
          return const DiaryDrinkFreeDay();
        } else {
          return DiaryEntryPage(diaryEntry: state.selectedDiaryEntry!);
        }
      },
    );
  }

  Widget _buildFAB() {
    return BlocBuilder<DiaryCubit, DiaryCubitState>(
      buildWhen: (previous, current) => previous.selectedDate != current.selectedDate,
      builder: (context, state) => FloatingActionButton(
        onPressed: () => context.router.push(AddConsumedDrinkRoute(diaryEntry: state.getOrCreateDiaryEntry())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
