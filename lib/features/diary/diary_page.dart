import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../infra/extensions/floor_date_time.dart';
import '../../router.dart';
import '../common/widgets/remove_drink_dialog.dart';
import '../diary_calendar/diary_calendar.dart';
import 'diary_cubit.dart';
import 'widgets/bac_chart.dart';
import 'widgets/bac_chart_title.dart';
import 'widgets/diary_app_bar.dart';
import 'widgets/diary_consumed_drinks.dart';
import 'widgets/diary_statistics.dart';

class DiaryPage extends StatelessWidget implements AutoRouteWrapper {
  const DiaryPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => DiaryCubit(context.read(), context.read(), context.read()),
        child: this,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            HomeAppBar(
              onTapProfile: () {
                context.router.push(const ProfileRoute());
              },
            ),
            _buildCalendar(),
            const SizedBox(height: 24),
            _buildTitle(),
            const SizedBox(height: 18),
            _buildChart(),
            const SizedBox(height: 12),
            _buildStatistics(),
            const SizedBox(height: 24),
            _buildRecentDrinks(),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildCalendar() {
    return BlocBuilder<DiaryCubit, DiaryCubitState>(
      buildWhen: (previous, current) => !DateUtils.isSameDay(previous.date, current.date),
      builder: (context, state) => DiaryCalendar(
        selectedDay: state.date.floorToDay(),
        onSelectedDayChanged: (value) {
          context.read<DiaryCubit>().switchDate(value);
        },
      ),
    );
  }

  Widget _buildTitle() {
    return BlocBuilder<DiaryCubit, DiaryCubitState>(
      builder: (context, state) => BACChartTitle(
        dateTime: state.date,
        results: state.calculationResults,
        diaryEntry: state.diaryEntry,
        onMarkAsDrinkFreeDay: () => context.read<DiaryCubit>().markAsDrinkFreeDay(),
      ),
    );
  }

  Widget _buildChart() {
    return BlocBuilder<DiaryCubit, DiaryCubitState>(
      buildWhen: (previous, current) => previous.calculationResults != current.calculationResults,
      builder: (context, state) => BACChart(
        results: state.calculationResults,
        currentDate: state.date,
      ),
    );
  }

  Widget _buildStatistics() {
    return BlocBuilder<DiaryCubit, DiaryCubitState>(
      buildWhen: (previous, current) => previous.drinks != current.drinks,
      builder: (context, state) => DiaryStatistics(
        numberOfConsumedDrinks: state.drinks.length,
        unitsOfAlcohol: state.unitsOfAlcohol,
        calories: state.calories,
      ),
    );
  }

  Widget _buildRecentDrinks() {
    return BlocBuilder<DiaryCubit, DiaryCubitState>(
      buildWhen: (previous, current) => previous.drinks != current.drinks,
      builder: (context, state) {
        if (state.drinks.isEmpty) {
          return const SizedBox();
        }

        return DiaryConsumedDrinks(
          state.drinks,
          onEdit: (drink) {
            context.router.push(ConsumedDrinkRoute(drink: drink, isEditing: true));
          },
          onDelete: (drink) {
            showDialog(
              context: context,
              builder: (dialogContext) => RemoveDrinkDialog(
                onCancel: () {
                  Navigator.pop(dialogContext);
                },
                onRemove: () {
                  context.read<DiaryCubit>().deleteDrink(drink);
                  Navigator.pop(dialogContext);
                },
              ),
            );
          },
          onViewAll: () {
            context.router.push(TodaysDrinksRoute(date: state.date));
          },
        );
      },
    );
  }

  Widget _buildFAB() {
    return BlocBuilder<DiaryCubit, DiaryCubitState>(
      buildWhen: (previous, current) => !DateUtils.isSameDay(previous.date, current.date),
      builder: (context, state) => FloatingActionButton(
        onPressed: () => context.router.push(AddDrinkRoute(date: state.date)),
        child: const Icon(Icons.add),
      ),
    );
  }
}
