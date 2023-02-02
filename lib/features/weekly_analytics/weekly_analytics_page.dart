import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/build_context_extensions.dart';
import 'weekly_analytics_cubit.dart';
import 'widgets/alcohol_per_day_chart.dart';

class WeeklyAnalyticsPage extends StatelessWidget implements AutoRouteWrapper {
  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => WeeklyAnalyticsCubit(),
        child: this,
      );

  const WeeklyAnalyticsPage({super.key});

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
                AlcoholPerDayChart(
                  data: const [0, 12, 0, 4, 6, null, null],
                  labels: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                      .map((e) => TextSpan(
                            text: e,
                            style: context.textTheme.labelMedium!.copyWith(color: Colors.black87),
                          ))
                      .toList(),
                  height: 140,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.navigate_before),
        onPressed: () {},
      ),
      title: Column(
        children: [
          Text(context.l18n.weeklyAnalytics_title),
          const SizedBox(height: 4),
          Text(
            context.l18n.weeklyAnalytics_weekFromTo(DateTime.now(), DateTime.now().add(const Duration(days: 7))),
            style: context.textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.navigate_next),
          onPressed: () {}, // TODO: Disable if current week
        ),
      ],
    );
  }
}
