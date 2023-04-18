import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/diary/consumed_cocktail.dart';
import '../common/build_context_extensions.dart';
import 'edit_drink_cubit.dart';
import 'widgets/cocktail_ingredients.dart';
import 'widgets/drink_abv_text_field.dart';
import 'widgets/drink_duration_text_field.dart';
import 'widgets/drink_start_time_text_field.dart';
import 'widgets/drink_volume_selection.dart';
import 'widgets/stomach_fullness_selection.dart';

class EditDrinkForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const EditDrinkForm({required this.formKey, super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l18n.edit_drink_amount, style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildAmountSelection(),
          const SizedBox(height: 16),
          _buildAlcoholSelection(),
          const SizedBox(height: 16),
          Text(context.l18n.edit_drink_stomachFullness, style: context.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(context.l18n.edit_drink_priorToConsumption, style: context.textTheme.bodySmall),
          const SizedBox(height: 8),
          _buildStomachFullnessSelection(),
          const SizedBox(height: 16),
          Text(context.l18n.edit_drink_timing, style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildStartTimePicker()),
              const SizedBox(width: 8),
              Expanded(child: _buildDurationInput()),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAmountSelection() {
    return BlocBuilder<EditDrinkCubit, EditDrinkCubitState>(
      buildWhen: (previous, current) => previous.drink.volume != current.drink.volume,
      builder: (context, state) => DrinkVolumeSelection(
        standardServings: state.drink.category.defaultServings,
        initialValue: state.drink.volume,
        onChanged: (it) {
          context.read<EditDrinkCubit>().updateVolume(it);
        },
      ),
    );
  }

  Widget _buildAlcoholSelection() {
    return BlocBuilder<EditDrinkCubit, EditDrinkCubitState>(
      buildWhen: (previous, current) => previous.drink.alcoholByVolume != current.drink.alcoholByVolume,
      builder: (context, state) => (state.drink is ConsumedCocktail)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l18n.edit_drink_alcoholicIngredients, style: context.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(context.l18n.edit_drink_spiritsLiquors, style: context.textTheme.bodySmall),
                const SizedBox(height: 12),
                CocktailIngredients((state.drink as ConsumedCocktail).ingredients),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l18n.edit_drink_strength, style: context.textTheme.titleMedium),
                const SizedBox(height: 8),
                DrinkABVTextField(
                  value: state.drink.alcoholByVolume,
                  onChanged: (it) {
                    context.read<EditDrinkCubit>().updateABV(it);
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildStomachFullnessSelection() {
    return BlocBuilder<EditDrinkCubit, EditDrinkCubitState>(
      buildWhen: (previous, current) => previous.drink.stomachFullness != current.drink.stomachFullness,
      builder: (context, state) => StomachFullnessSelection(
        value: state.drink.stomachFullness,
        onChanged: (it) {
          context.read<EditDrinkCubit>().updateStomachFullness(it);
        },
      ),
    );
  }

  Widget _buildStartTimePicker() {
    return BlocBuilder<EditDrinkCubit, EditDrinkCubitState>(
      buildWhen: (previous, current) => previous.drink.startTime != current.drink.startTime,
      builder: (context, state) => DrinkStartTimeTextField(
        value: state.drink.startTime,
        onChanged: (it) {
          context.read<EditDrinkCubit>().updateStartTime(it);
        },
      ),
    );
  }

  Widget _buildDurationInput() {
    return BlocBuilder<EditDrinkCubit, EditDrinkCubitState>(
      buildWhen: (previous, current) => previous.drink.duration != current.drink.duration,
      builder: (context, state) => DrinkDurationTextField(
        value: state.drink.duration,
        onChanged: (it) {
          context.read<EditDrinkCubit>().updateDuration(it);
        },
      ),
    );
  }
}
