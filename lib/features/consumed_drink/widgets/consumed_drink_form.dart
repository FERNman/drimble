import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../domain/alcohol/percentage.dart';
import '../../../domain/diary/consumed_drink.dart';
import '../../../infra/extensions/copy_date_time.dart';
import '../../../infra/extensions/copy_duration.dart';
import 'drink_amount_selection.dart';
import 'stomach_fullness_selection.dart';

class ConsumedDrinkForm extends StatelessWidget {
  static final _timespanRegex = RegExp(r'^(([0|1]\d)|(2[0-3])):[0-5]\d$');

  final GlobalKey<FormState> formKey;
  final ConsumedDrink value;
  final ValueChanged<ConsumedDrink> onChanged;

  const ConsumedDrinkForm({
    required this.formKey,
    required ConsumedDrink initialValue,
    required this.onChanged,
    super.key,
  }) : value = initialValue;

  static String _formatDateTimeAsTime(DateTime time) => DateFormat.Hm().format(time);

  static String _formatDurationAsTime(Duration duration) {
    final hours = '${duration.inHours}'.padLeft(2, '0');
    final minutes = '${duration.inMinutes.remainder(60)}'.padLeft(2, '0');
    return '$hours:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Amount'),
          AmountSelection(
            standardServings: value.beverage.standardServings,
            initialValue: value.volume,
            onChanged: (it) {
              value.volume = it;
              onChanged(value);
            },
          ),
          const _SectionTitle('Strenth'),
          Row(children: [
            Expanded(
              child: _AlcoholTextField(
                value: value.alcoholByVolume,
                onChanged: (abv) => onChanged(value.copyWith(alcoholByVolume: abv)),
              ),
            ),
            const SizedBox(width: 8),
            const Spacer()
          ]),
          const _SectionTitle('Stomach fullness'),
          const _SectionSubtitle('Prior to consumption'),
          StomachFullnessSelection(
            initialValue: value.stomachFullness,
            onChanged: (it) {
              value.stomachFullness = it;
              onChanged(value);
            },
          ),
          const _SectionTitle('Timinig'),
          Row(
            children: [
              Expanded(
                child: DateTimePicker(
                  type: DateTimePickerType.time,
                  initialValue: _formatDateTimeAsTime(value.startTime),
                  onChanged: _setStartTime,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.access_time_outlined),
                    label: Text('Start time'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DateTimePicker(
                  type: DateTimePickerType.time,
                  initialValue: _formatDurationAsTime(value.duration),
                  onChanged: _setDuration,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.hourglass_empty_outlined),
                    label: Text('Duration'),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void _setDuration(String duration) {
    if (_timespanRegex.hasMatch(duration)) {
      value.duration = value.duration.copyWith(
        hours: int.parse(duration.substring(0, 2)),
        minutes: int.parse(duration.substring(3, 5)),
      );

      onChanged(value);
    }
  }

  void _setStartTime(String startTime) {
    if (_timespanRegex.hasMatch(startTime)) {
      value.startTime = value.startTime.copyWith(
        hour: int.parse(startTime.substring(0, 2)),
        minute: int.parse(startTime.substring(3, 5)),
      );

      onChanged(value);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(children: [
      const SizedBox(height: 16),
      Text(text, style: textTheme.titleMedium),
      const SizedBox(height: 4),
    ]);
  }
}

class _SectionSubtitle extends StatelessWidget {
  final String text;

  const _SectionSubtitle(this.text);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(children: [
      Text(text, style: textTheme.bodySmall),
      const SizedBox(height: 4),
    ]);
  }
}

class _AlcoholTextField extends StatelessWidget {
  static final _percentageRegex = RegExp(r'^\d{1,2}$');

  final Percentage value;
  final ValueChanged<Percentage> onChanged;

  const _AlcoholTextField({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: '${(value * 100).round()}',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(prefixIcon: Icon(Icons.percent_outlined)),
      onChanged: _onChanged,
    );
  }

  void _onChanged(String value) {
    if (_percentageRegex.hasMatch(value)) {
      onChanged(double.parse(value) / 100.0);
    }
  }
}
