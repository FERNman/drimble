import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../router.dart';
import '../common/build_context_extensions.dart';
import 'analytics_cubit.dart';
import 'widgets/analytics_app_bar.dart';
import 'widgets/weekly_alcohol_consumption.dart';
import 'widgets/weekly_alcohol_per_day_chart.dart';
import 'widgets/weekly_drink_free_days.dart';
import 'widgets/weekly_statistics.dart';

class AnalyticsPage extends StatelessWidget implements AutoRouteWrapper {
  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => AnalyticsCubit(context.read(), context.read(), context.read()),
        child: this,
      );

  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: context.theme.copyWith(
        cardTheme: context.theme.cardTheme.copyWith(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color.fromARGB(10, 0, 0, 0)),
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildAppBar(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildAlcoholConsumption(),
                  const SizedBox(height: 24),
                  _buildDrinkFreeDays(),
                  const SizedBox(height: 24),
                  Text(context.l18n.analytics_statistics, style: context.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _buildStatistics(),
                  const SizedBox(height: 24),
                  Text(context.l18n.analytics_drinkingTrends, style: context.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _buildDrinkingTrends(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return BlocBuilder<AnalyticsCubit, AnalyticsCubitState>(
      buildWhen: (previous, current) => previous.firstDayOfWeek != current.firstDayOfWeek,
      builder: (context, state) {
        // Subtract a day because the last day would be monday otherwise
        final sunday = state.lastDayOfWeek.subtract(const Duration(days: 1));
        return AnalyticsAppBar(firstDayOfWeek: state.firstDayOfWeek, lastDayOfWeek: sunday);
      },
    );
  }

  Widget _buildAlcoholConsumption() {
    return BlocBuilder<AnalyticsCubit, AnalyticsCubitState>(
      buildWhen: (previous, current) =>
          previous.totalAlcoholThisWeek != current.totalAlcoholThisWeek ||
          previous.changeOfAverageAlcohol != current.changeOfAverageAlcohol ||
          previous.goals != current.goals,
      builder: (context, state) => Center(
        child: WeeklyAlcoholConsumption(
          totalGramsOfAlcohol: state.totalAlcoholThisWeek,
          changeToLastWeek: state.changeOfAverageAlcohol,
          goals: state.goals,
          onEdit: () => context.router.push(const EditWeeklyAlcoholGoalRoute()),
        ),
      ),
    );
  }

  Widget _buildDrinkFreeDays() {
    return BlocBuilder<AnalyticsCubit, AnalyticsCubitState>(
      buildWhen: (previous, current) =>
          previous.drinkFreeDays != current.drinkFreeDays || previous.goals != current.goals,
      builder: (context, state) => WeeklyDrinkFreeDays(
        drinkFreeDays: state.drinkFreeDays,
        goals: state.goals,
        onTap: () => context.router.push(const EditWeeklyDrinkFreeDaysGoalRoute()),
      ),
    );
  }

  Widget _buildDrinkingTrends() {
    return BlocBuilder<AnalyticsCubit, AnalyticsCubitState>(
      buildWhen: (previous, current) => previous.alcoholByDayThisWeek != current.alcoholByDayThisWeek,
      builder: (context, state) => WeeklyAlcoholPerDayChart(
        alcoholPerDayThisWeek: state.alcoholByDayThisWeek,
        averageThisWeek: state.averageAlcoholPerSessionThisWeek,
        changeToLastWeek: state.changeOfAverageAlcohol,
        height: 140,
      ),
    );
  }

  Widget _buildStatistics() {
    return BlocBuilder<AnalyticsCubit, AnalyticsCubitState>(
      buildWhen: (previous, current) => previous.highestBAC != current.highestBAC,
      builder: (context, state) => WeeklyStatistics(
        highestBAC: state.highestBAC,
        calories: 1200,
        numberOfDrinks: 8,
      ),
    );
  }
}
