import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../build_context_extensions.dart';

class TimeInputField extends StatelessWidget {
  static final _digitsAndColonRegex = RegExp(r'^[0-9:]*$');
  static final _timespanRegex = RegExp(r'^(([0|1]\d)|(2[0-3])):[0-5]\d$');

  final TimeOfDay initialValue;
  final ValueChanged<TimeOfDay> onChanged;
  final InputDecoration? decoration;

  const TimeInputField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue.format(context),
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [
        FilteringTextInputFormatter.allow(_digitsAndColonRegex),
      ],
      validator: (value) => _timespanRegex.hasMatch(value!) ? null : context.l18n.common_invalidTimeFormat,
      decoration: decoration,
      onChanged: _onChanged,
    );
  }

  void _onChanged(String rawValue) {
    if (_timespanRegex.hasMatch(rawValue)) {
      final timeParts = rawValue.split(':');
      final hours = int.parse(timeParts[0]);
      final minutes = int.parse(timeParts[1]);

      onChanged(TimeOfDay(hour: hours, minute: minutes));
    }
  }
}
