import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/build_context_extensions.dart';
import '../common/widgets/extended_app_bar.dart';
import 'edit_weekly_goal_cubit.dart';

class EditWeeklyGoal extends StatelessWidget {
  final Widget title;
  final Widget description;
  final Widget body;

  const EditWeeklyGoal({
    required this.title,
    required this.description,
    required this.body,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            description,
            const SizedBox(height: 32),
            body,
            const Spacer(),
            FilledButton(
              child: Text(context.l10n.editWeeklyGoal_setGoal),
              onPressed: () {
                context.read<EditWeeklyGoalCubit>().saveGoals().then((v) => context.router.pop());
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return ExtendedAppBar.large(
      leading: const BackButton(),
      title: title,
    );
  }
}
