import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../build_context_extensions.dart';

class TimeInputField extends StatelessWidget {
  static final _inputRegex = RegExp(r'^[0-9:\sAPM]*$', caseSensitive: false);
  static final _timespanRegex = RegExp(
      r'^\s*(?<hour>(?:[01]?\d)|(?:2[0-3])):(?<minute>[0-5]\d)(?:\s?(?<modifier>[AP]M))?\s*$',
      caseSensitive: false);

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
      keyboardType: TextInputType.datetime,
      inputFormatters: [
        FilteringTextInputFormatter.allow(_inputRegex),
      ],
      validator: (value) => _timespanRegex.hasMatch(value!) ? null : context.l18n.common_invalidTimeFormat,
      decoration: decoration,
      onChanged: _onChanged,
    );
  }

  void _onChanged(String rawValue) {
    final match = _timespanRegex.firstMatch(rawValue);
    if (match != null) {
      final hour = match.namedGroup('hour');
      final minute = match.namedGroup('minute');
      final modifier = match.namedGroup('modifier');

      if (hour != null && minute != null) {
        var hours = int.parse(hour);
        final minutes = int.parse(minute);

        if (modifier?.toLowerCase() == 'pm') {
          hours += 12;
        }

        onChanged(TimeOfDay(hour: hours, minute: minutes));
      }
    }
  }
}
