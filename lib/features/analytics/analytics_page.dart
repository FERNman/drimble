import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/date.dart';
import '../../router.gr.dart';
import '../common/build_context_extensions.dart';
import 'analytics_cubit.dart';
import 'widgets/analytics_app_bar.dart';
import 'widgets/weekly_alcohol_consumption.dart';
import 'widgets/weekly_alcohol_per_day_chart.dart';
import 'widgets/weekly_drink_free_days.dart';
import 'widgets/weekly_statistics.dart';

@RoutePage()
class AnalyticsPage extends StatelessWidget implements AutoRouteWrapper {
  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => AnalyticsCubit(context.read(), context.read()),
        child: this,
      );

  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                  Text(context.l10n.analytics_statistics, style: context.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _buildStatistics(),
                  const SizedBox(height: 24),
                  Text(context.l10n.analytics_drinkingTrends, style: context.textTheme.titleMedium),
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
        final sunday = state.lastDayOfWeek.subtract(days: 1);
        return AnalyticsAppBar(
          firstDayOfWeek: state.firstDayOfWeek,
          lastDayOfWeek: sunday,
          onClose: () => context.router.pop(),
          onChangeWeek: () async {
            final result =
                await context.router.push<Date?>(AnalyticsSwitchWeekRoute(initialDate: state.firstDayOfWeek));
            if (result != null && context.mounted) {
              context.read<AnalyticsCubit>().setDate(result);
            }
          },
        );
      },
    );
  }

  Widget _buildAlcoholConsumption() {
    return BlocBuilder<AnalyticsCubit, AnalyticsCubitState>(
      buildWhen: (previous, current) =>
          previous.totalAlcohol != current.totalAlcohol ||
          previous.changeOfAverageAlcohol != current.changeOfAverageAlcohol ||
          previous.goals != current.goals,
      builder: (context, state) => Center(
        child: WeeklyAlcoholConsumption(
          totalGramsOfAlcohol: state.totalAlcohol,
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
      buildWhen: (previous, current) =>
          previous.alcoholByDay != current.alcoholByDay ||
          previous.averageAlcoholPerSession != current.averageAlcoholPerSession ||
          previous.changeOfAverageAlcohol != current.changeOfAverageAlcohol,
      builder: (context, state) => WeeklyAlcoholPerDayChart(
        alcoholPerDayThisWeek: state.alcoholByDay,
        averageThisWeek: state.averageAlcoholPerSession,
        changeToLastWeek: state.changeOfAverageAlcohol,
        height: 140,
      ),
    );
  }

  Widget _buildStatistics() {
    return BlocBuilder<AnalyticsCubit, AnalyticsCubitState>(
      buildWhen: (previous, current) =>
          previous.calories != current.calories || previous.numberOfDrinks != current.numberOfDrinks,
      builder: (context, state) => WeeklyStatistics(
        calories: state.calories,
        numberOfDrinks: state.numberOfDrinks,
      ),
    );
  }
}
