import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/diary/stomach_fullness.dart';
import '../../infra/l10n/stomach_fullness_translations.dart';
import '../common/build_context_extensions.dart';
import '../common/widgets/extended_app_bar.dart';
import '../common/widgets/selectable_card.dart';
import 'select_stomach_fullness_cubit.dart';

@RoutePage<StomachFullness>()
class SelectStomachFullnessPage extends StatelessWidget implements AutoRouteWrapper {
  const SelectStomachFullnessPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => SelectStomachFullnessCubit(),
        child: this,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ExtendedAppBar.medium(
            leading: const CloseButton(),
            title: Text(context.l10n.select_stomach_fullness_title),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 24, right: 16),
            child: Column(
              children: [
                Text(context.l10n.select_stomach_fullness_description),
                const SizedBox(height: 24),
                _buildStomachFullnessSelection(),
                const SizedBox(height: 24),
                _buildNextButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStomachFullnessSelection() {
    return BlocBuilder<SelectStomachFullnessCubit, SelectStomachFullnessState>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(
          StomachFullness.values.length,
          (index) {
            final value = StomachFullness.values[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SelectableCard(
                isSelected: value == state.stomachFullness,
                onSelect: () => context.read<SelectStomachFullnessCubit>().selectStomachFullness(value),
                child: Text(value.translate(context), style: context.textTheme.labelLarge),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return BlocBuilder<SelectStomachFullnessCubit, SelectStomachFullnessState>(
      builder: (context, state) => FilledButton(
        onPressed: state.stomachFullness == null ? null : () => context.router.pop(state.stomachFullness),
        child: Text(context.l10n.common_continue),
      ),
    );
  }
}
