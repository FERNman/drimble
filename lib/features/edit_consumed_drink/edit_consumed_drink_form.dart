import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/diary/consumed_cocktail.dart';
import '../common/build_context_extensions.dart';
import 'edit_consumed_drink_cubit.dart';
import 'widgets/cocktail_ingredients.dart';
import 'widgets/drink_abv_text_field.dart';
import 'widgets/drink_duration_text_field.dart';
import 'widgets/drink_start_time_text_field.dart';
import 'widgets/drink_volume_selection.dart';

class EditConsumedDrinkForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const EditConsumedDrinkForm({required this.formKey, super.key});

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
    return BlocBuilder<EditConsumedDrinkCubit, EditDrinkCubitState>(
      buildWhen: (previous, current) => previous.consumedDrink.volume != current.consumedDrink.volume,
      builder: (context, state) => DrinkVolumeSelection(
        standardServings: state.defaultServings,
        initialValue: state.consumedDrink.volume,
        onChanged: (it) {
          context.read<EditConsumedDrinkCubit>().updateVolume(it);
        },
      ),
    );
  }

  Widget _buildAlcoholSelection() {
    return BlocBuilder<EditConsumedDrinkCubit, EditDrinkCubitState>(
      buildWhen: (previous, current) => previous.consumedDrink.alcoholByVolume != current.consumedDrink.alcoholByVolume,
      builder: (context, state) => (state.consumedDrink is ConsumedCocktail)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l18n.edit_drink_alcoholicIngredients, style: context.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(context.l18n.edit_drink_spiritsLiquors, style: context.textTheme.bodySmall),
                const SizedBox(height: 12),
                CocktailIngredients(
                  (state.consumedDrink as ConsumedCocktail),
                  (state.consumedDrink as ConsumedCocktail).ingredients,
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l18n.edit_drink_strength, style: context.textTheme.titleMedium),
                const SizedBox(height: 8),
                DrinkABVTextField(
                  value: state.consumedDrink.alcoholByVolume,
                  onChanged: (it) {
                    context.read<EditConsumedDrinkCubit>().updateABV(it);
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildStartTimePicker() {
    return BlocBuilder<EditConsumedDrinkCubit, EditDrinkCubitState>(
      buildWhen: (previous, current) => previous.consumedDrink.startTime != current.consumedDrink.startTime,
      builder: (context, state) => DrinkStartTimeTextField(
        value: state.consumedDrink.startTime,
        onChanged: (it) {
          context.read<EditConsumedDrinkCubit>().updateStartTime(it);
        },
      ),
    );
  }

  Widget _buildDurationInput() {
    return BlocBuilder<EditConsumedDrinkCubit, EditDrinkCubitState>(
      buildWhen: (previous, current) => previous.consumedDrink.duration != current.consumedDrink.duration,
      builder: (context, state) => DrinkDurationTextField(
        value: state.consumedDrink.duration,
        onChanged: (it) {
          context.read<EditConsumedDrinkCubit>().updateDuration(it);
        },
      ),
    );
  }
}
