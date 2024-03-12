import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/user/user_goals.dart';
import '../common/build_context_extensions.dart';
import '../common/number_text_style.dart';
import '../edit_weekly_goal/edit_weekly_goal.dart';
import '../edit_weekly_goal/edit_weekly_goal_cubit.dart';

@RoutePage()
class EditWeeklyDrinkFreeDaysGoalPage extends StatelessWidget implements AutoRouteWrapper {
  const EditWeeklyDrinkFreeDaysGoalPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => EditWeeklyGoalCubit(
          context.read(),
          initialGoals: const UserGoals(weeklyDrinkFreeDays: EditWeeklyGoalState.defaultWeeklyDrinkFreeDays),
        ),
        child: EditWeeklyGoal(
          title: Text(context.l18n.editWeeklyDrinkFreeDaysGoal_title),
          description: Text(context.l18n.editWeeklyDrinkFreeDaysGoal_description),
          body: this,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditWeeklyGoalCubit, BaseEditWeeklyGoalState>(
      builder: (context, state) => Column(
        children: [
          Text(
            '${state.goals.weeklyDrinkFreeDays}',
            style: context.textTheme.displaySmall?.forNumbers(),
          ),
          Slider(
            value: state.goals.weeklyDrinkFreeDays!.toDouble(),
            onChanged: (value) {
              context.read<EditWeeklyGoalCubit>().updateDrinkFreeDays(value.round());
            },
            min: 1,
            max: 7,
          ),
        ],
      ),
    );
  }
}
