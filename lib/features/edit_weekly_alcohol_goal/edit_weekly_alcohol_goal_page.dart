import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/build_context_extensions.dart';
import '../edit_weekly_goal/edit_weekly_goal.dart';
import '../edit_weekly_goal/edit_weekly_goal_cubit.dart';

class EditWeeklyAlcoholGoalPage extends StatelessWidget implements AutoRouteWrapper {
  const EditWeeklyAlcoholGoalPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => EditWeeklyGoalCubit(context.read()),
        child: EditWeeklyGoal(
          title: Text(context.l18n.editWeeklyAlcoholGoal_title),
          description: Text(context.l18n.editWeeklyAlcoholGoal_description),
          body: this,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditWeeklyGoalCubit, EditWeeklyGoalState>(
      builder: (context, state) => Column(
        children: [
          Text(
            '${state.newGoals.weeklyGramsOfAlcohol ?? state.defaultWeeklyGramsOfAlcohol}g',
            style: context.textTheme.displaySmall,
          ),
          Slider(
            value: state.newGoals.weeklyGramsOfAlcohol?.toDouble() ?? state.defaultWeeklyGramsOfAlcohol.toDouble(),
            onChanged: (value) {
              context.read<EditWeeklyGoalCubit>().updateGramsOfAlcohol(value.round());
            },
            min: 0,
            max: 200,
          ),
        ],
      ),
    );
  }
}
