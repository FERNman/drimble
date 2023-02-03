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
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildAlcoholChart(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlcoholChart() {
    return BlocBuilder<AnalyticsCubit, AnalyticsCubitState>(
      buildWhen: (previous, current) => previous.gramsOfAlcoholPerDay != current.gramsOfAlcoholPerDay,
      builder: (context, state) {
        final dateFormatter = DateFormat.E();
        final days = List.generate(state.timespan.inDays, (index) => state.startDate.add(Duration(days: index)));

        return AlcoholPerDayChart(
          data: state.gramsOfAlcoholPerDay,
          labels: days
              .map((date) => TextSpan(
                    text: dateFormatter.format(date),
                    style: context.textTheme.labelMedium!.copyWith(color: Colors.black87),
                  ))
              .toList(),
          height: 140,
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Column(
        children: [
          Text(context.l18n.analytics_title),
          const SizedBox(height: 4),
          Text(
            context.l18n.analytics_weekFromTo(DateTime.now(), DateTime.now().add(const Duration(days: 7))),
            style: context.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
