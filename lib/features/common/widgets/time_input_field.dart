import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../build_context_extensions.dart';

class TimeInputField extends StatelessWidget {
  static final _inputRegex = RegExp(r'^[0-9:\sAPM]*$', caseSensitive: false);
  static final _timespanRegex = RegExp(
      r'^\s*((?<hour12>(0?[1-9])|(1[0-2])):(?<minute12>([0-5])\d)\s*(?<modifier>[AP]M))|((?<hour24>((0?|1)\d)|(2[0-3])):(?<minute24>([0-5])\d))\s*$',
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
      final time = getTime(match);

      if (time != null) {
        final (hours, minutes) = time;
        onChanged(TimeOfDay(hour: hours, minute: minutes));
      }
    }
  }
}

(int, int)? getTime(RegExpMatch match) {
  final modifier = match.namedGroup('modifier');

  if (modifier != null) {
    final hour = match.namedGroup('hour12');
    final minute = match.namedGroup('minute12');

    if (hour != null && minute != null) {
      final hourModification = modifier.toLowerCase() == 'pm' ? 12 : 0;
      final hours = int.parse(hour) + hourModification;
      final minutes = int.parse(minute);

      return (hours, minutes);
    }
  } else {
    final hour = match.namedGroup('hour24');
    final minute = match.namedGroup('minute24');

    if (hour != null && minute != null) {
      final hours = int.parse(hour);
      final minutes = int.parse(minute);

      return (hours, minutes);
    }
  }

  return null;
}
