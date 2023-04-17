import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/diary/consumed_cocktail.dart';
import '../../infra/extensions/copy_date_time.dart';
import '../common/build_context_extensions.dart';
import 'edit_drink_cubit.dart';
import 'widgets/alcohol_percentage_text_field.dart';
import 'widgets/cocktail_ingredients.dart';
import 'widgets/drink_amount_selection.dart';
import 'widgets/stomach_fullness_selection.dart';

class EditDrinkForm extends StatelessWidget {
  static final _timespanRegex = RegExp(r'^(([0|1]\d)|(2[0-3])):[0-5]\d$');
  static final _numberRegex = RegExp(r'^\d+$');

  final GlobalKey<FormState> formKey;

  const EditDrinkForm({required this.formKey, super.key});

  static String _formatDateTimeAsTime(DateTime time) => DateFormat.Hm().format(time);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountSelection(),
          const SizedBox(height: 16),
          _buildAlcoholSelection(),
          const SizedBox(height: 16),
          _buildStomachFullnessSelection(),
          const SizedBox(height: 16),
          Text(context.l18n.edit_drink_timing, style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
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
      builder: (context, state) => AmountSelection(
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
          ? CocktailIngredients((state.drink as ConsumedCocktail).ingredients)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l18n.edit_drink_strength, style: context.textTheme.titleMedium),
                const SizedBox(height: 8),
                AlcoholPercentageTextField(
                  value: state.drink.alcoholByVolume,
                  onChanged: (it) {
                    context.read<EditDrinkCubit>().updatePercentage(it);
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
      builder: (context, state) => DateTimePicker(
        type: DateTimePickerType.time,
        initialValue: _formatDateTimeAsTime(state.drink.startTime),
        onChanged: (rawValue) => _onStartTimeChanged(context, rawValue, state.drink.startTime),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.access_time_outlined),
          label: Text(context.l18n.edit_drink_startTime),
        ),
      ),
    );
  }

  void _onStartTimeChanged(BuildContext context, String rawValue, DateTime previousTime) {
    if (_timespanRegex.hasMatch(rawValue)) {
      final startTime = previousTime.copyWith(
        hour: int.parse(rawValue.substring(0, 2)),
        minute: int.parse(rawValue.substring(3, 5)),
      );

      context.read<EditDrinkCubit>().updateStartTime(startTime);
    }
  }

  Widget _buildDurationInput() {
    return BlocBuilder<EditDrinkCubit, EditDrinkCubitState>(
      buildWhen: (previous, current) => previous.drink.duration != current.drink.duration,
      builder: (context, state) {
        return TextFormField(
          initialValue: '${state.drink.duration.inMinutes}',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.hourglass_empty_outlined),
            labelText: context.l18n.edit_drink_duration,
            suffixText: context.l18n.edit_drink_minutes,
          ),
          onChanged: (value) => _onDurationChanged(context, value),
        );
      },
    );
  }

  void _onDurationChanged(BuildContext context, String rawValue) {
    if (_numberRegex.hasMatch(rawValue)) {
      final duration = Duration(minutes: int.parse(rawValue));

      context.read<EditDrinkCubit>().updateDuration(duration);
    }
  }
}
