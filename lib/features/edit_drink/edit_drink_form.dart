import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../infra/extensions/copy_date_time.dart';
import '../common/build_context_extensions.dart';
import 'edit_drink_cubit.dart';
import 'widgets/alcohol_percentage_text_field.dart';
import 'widgets/drink_amount_selection.dart';
import 'widgets/edit_drink_form_subtitle.dart';
import 'widgets/edit_drink_form_title.dart';
import 'widgets/stomach_fullness_selection.dart';

class EditDrinkForm extends StatelessWidget {
  static final _timespanRegex = RegExp(r'^(([0|1]\d)|(2[0-3])):[0-5]\d$');

  const EditDrinkForm({super.key});

  static String _formatDateTimeAsTime(DateTime time) => DateFormat.Hm().format(time);

  static String _formatDurationAsTime(Duration duration) {
    final hours = '${duration.inHours}'.padLeft(2, '0');
    final minutes = '${duration.inMinutes.remainder(60)}'.padLeft(2, '0');
    return '$hours:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditDrinkFormTitle(context.l18n.edit_drink_amount),
          _buildAmountSelection(),
          EditDrinkFormTitle(context.l18n.edit_drink_strength),
          _buildPercentageTextField(),
          EditDrinkFormTitle(context.l18n.edit_drink_stomachFullness),
          EditDrinkFormSubtitle(context.l18n.edit_drink_priorToConsumption),
          _buildStomachFullnessSelection(),
          EditDrinkFormTitle(context.l18n.edit_drink_timing),
          Row(
            children: [
              Expanded(child: _buildStartTimePicker()),
              const SizedBox(width: 8),
              Expanded(child: _buildDurationPicker()),
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

  Widget _buildPercentageTextField() {
    return BlocBuilder<EditDrinkCubit, EditDrinkCubitState>(
      buildWhen: (previous, current) => previous.drink.alcoholByVolume != current.drink.alcoholByVolume,
      builder: (context, state) => Row(children: [
        Expanded(
          child: AlcoholPercentageTextField(
            value: state.drink.alcoholByVolume,
            onChanged: (it) {
              context.read<EditDrinkCubit>().updatePercentage(it);
            },
          ),
        ),
        const SizedBox(width: 8),
        const Spacer()
      ]),
    );
  }

  Widget _buildStomachFullnessSelection() {
    return BlocBuilder<EditDrinkCubit, EditDrinkCubitState>(
      buildWhen: (previous, current) => previous.drink.stomachFullness != current.drink.stomachFullness,
      builder: (context, state) => StomachFullnessSelection(
        initialValue: state.drink.stomachFullness,
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

  Widget _buildDurationPicker() {
    return BlocBuilder<EditDrinkCubit, EditDrinkCubitState>(
      buildWhen: (previous, current) => previous.drink.duration != current.drink.duration,
      builder: (context, state) {
        return DateTimePicker(
          type: DateTimePickerType.time,
          initialValue: _formatDurationAsTime(state.drink.duration),
          onChanged: (value) => _onDurationChanged(context, value),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.hourglass_empty_outlined),
            label: Text(context.l18n.edit_drink_duration),
          ),
        );
      },
    );
  }

  void _onDurationChanged(BuildContext context, String rawValue) {
    if (_timespanRegex.hasMatch(rawValue)) {
      final duration = Duration(
        hours: int.parse(rawValue.substring(0, 2)),
        minutes: int.parse(rawValue.substring(3, 5)),
      );

      context.read<EditDrinkCubit>().updateDuration(duration);
    }
  }
}
