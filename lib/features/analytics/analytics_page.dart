import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../common/build_context_extensions.dart';
import 'analytics_cubit.dart';
import 'widgets/alcohol_per_day_chart.dart';
import 'widgets/analytics_app_bar.dart';
import 'widgets/highest_bac_card.dart';
import 'widgets/total_alcohol_indicator.dart';

class AnalyticsPage extends StatelessWidget implements AutoRouteWrapper {
  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => AnalyticsCubit(context.read(), context.read(), context.read()),
        child: this,
      );

  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAppBar(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 32),
                _buildTotalAlcoholIndicator(),
                const SizedBox(height: 48),
                _buildAlcoholChart(),
                const SizedBox(height: 24),
                _buildHighestBACCard(),
              ],
            ),
          ),
        ],
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

  Widget _buildTotalAlcoholIndicator() {
    return BlocBuilder<AnalyticsCubit, AnalyticsCubitState>(
      buildWhen: (previous, current) =>
          previous.totalGramsOfAlcohol != current.totalGramsOfAlcohol ||
          previous.changeToLastWeek != current.changeToLastWeek,
      builder: (context, state) => TotalAlcoholIndicator(
        totalGramsOfAlcohol: state.totalGramsOfAlcohol,
        changeToLastWeek: state.changeToLastWeek,
      ),
    );
  }

  Widget _buildAlcoholChart() {
    return BlocBuilder<AnalyticsCubit, AnalyticsCubitState>(
      buildWhen: (previous, current) => previous.gramsOfAlcoholPerDay != current.gramsOfAlcoholPerDay,
      builder: (context, state) {
        final dateFormatter = DateFormat.E();
        final days = List.generate(state.timespan.inDays, (index) => state.firstDayOfWeek.add(Duration(days: index)));

        return AlcoholPerDayChart(
          data: state.gramsOfAlcoholPerDay,
          labels: days
              .map((date) => TextSpan(text: dateFormatter.format(date), style: context.textTheme.labelMedium))
              .toList(),
          height: 140,
        );
      },
    );
  }

  Widget _buildHighestBACCard() {
    return BlocBuilder<AnalyticsCubit, AnalyticsCubitState>(
      buildWhen: (previous, current) => previous.maxBAC != current.maxBAC,
      builder: (context, state) => HighestBACCard(maxBAC: state.maxBAC),
    );
  }
}
