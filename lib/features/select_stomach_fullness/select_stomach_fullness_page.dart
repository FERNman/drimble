import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/diary/diary_entry.dart';
import '../../domain/diary/stomach_fullness.dart';
import '../../infra/l10n/stomach_fullness_translations.dart';
import '../../router.gr.dart';
import '../common/build_context_extensions.dart';
import '../common/widgets/extended_app_bar.dart';
import '../common/widgets/selectable_card.dart';
import 'select_stomach_fullnes_cubit.dart';

@RoutePage()
class SelectStomachFullnessPage extends StatelessWidget implements AutoRouteWrapper {
  final DiaryEntry diaryEntry;

  const SelectStomachFullnessPage({super.key, required this.diaryEntry});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => SelectStomachFullnessCubit(context.read(), diaryEntry),
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
                _buildSaveButton(),
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
                isSelected: value == state.diaryEntry.stomachFullness,
                onSelect: () => context.read<SelectStomachFullnessCubit>().selectStomachFullness(value),
                child: Text(value.translate(context), style: context.textTheme.labelLarge),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return BlocBuilder<SelectStomachFullnessCubit, SelectStomachFullnessState>(
      builder: (context, state) => FilledButton(
        onPressed: state.diaryEntry.stomachFullness == null
            ? null
            : () {
                context
                    .read<SelectStomachFullnessCubit>()
                    .save()
                    .then((value) => context.router.replace(AddConsumedDrinkRoute(diaryEntry: state.diaryEntry)));
              },
        child: Text(context.l10n.common_save),
      ),
    );
  }
}
