import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../common/build_context_extensions.dart';
import 'analytics_cubit.dart';
import 'widgets/alcohol_per_day_chart.dart';

class AnalyticsPage extends StatelessWidget implements AutoRouteWrapper {
  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => AnalyticsCubit(context.read(), context.read()),
        child: this,
      );

  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAppBar(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 32),
                _buildTotalAlcoholIndicator(),
                const SizedBox(height: 38),
                _buildAlcoholChart(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return BlocBuilder<AnalyticsCubit, AnalyticsCubitState>(
      buildWhen: (previous, current) => previous.firstDayOfWeek != current.firstDayOfWeek,
      builder: (context, state) {
        // Subtract a day because the last day would be monday otherwise
        final sunday = state.lastDayOfWeek.subtract(const Duration(days: 1));
        return AppBar(
          title: Column(
            children: [
              Text(context.l18n.analytics_title),
              const SizedBox(height: 4),
              Text(
                context.l18n.analytics_weekFromTo(state.firstDayOfWeek, sunday),
                style: context.textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalAlcoholIndicator() {
    return BlocBuilder<AnalyticsCubit, AnalyticsCubitState>(
      buildWhen: (previous, current) =>
          previous.totalGramsOfAlcohol != current.totalGramsOfAlcohol ||
          previous.changeToLastWeek != current.changeToLastWeek,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('${state.totalGramsOfAlcohol.toStringAsFixed(0)}g', style: context.textTheme.displaySmall),
            const SizedBox(height: 4),
            Text(context.l18n.analytics_totalAlcoholConsumed, style: context.textTheme.bodyLarge),
            RichText(
              text: TextSpan(
                style: context.textTheme.bodySmall,
                children: [
                  _buildChangeIndicator(context, state),
                  TextSpan(text: context.l18n.analytics_changeFromLastWeek),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  TextSpan _buildChangeIndicator(BuildContext context, AnalyticsCubitState state) {
    final formatter = NumberFormat.percentPattern();
    if (state.changeToLastWeek > 1) {
      final formatted = formatter.format(state.changeToLastWeek - 1);
      return TextSpan(
          text: '▲ $formatted ', style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.error));
    } else {
      final formatted = formatter.format(state.changeToLastWeek);
      return TextSpan(text: '▼ $formatted ', style: context.textTheme.bodySmall?.copyWith(color: Colors.green));
    }
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
}
