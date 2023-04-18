import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/build_context_extensions.dart';

class DrinkStartTimeTextField extends StatelessWidget {
  static final _timespanRegex = RegExp(r'^(([0|1]\d)|(2[0-3])):[0-5]\d$');

  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  const DrinkStartTimeTextField({
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.Hm();
    return DateTimePicker(
      type: DateTimePickerType.time,
      initialValue: timeFormat.format(value),
      onChanged: (rawValue) => _onChanged(context, rawValue, value),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.access_time_outlined),
        label: Text(context.l18n.edit_drink_startTime),
      ),
    );
    ;
  }

  void _onChanged(BuildContext context, String rawValue, DateTime previousTime) {
    if (_timespanRegex.hasMatch(rawValue)) {
      final startTime = previousTime.copyWith(
        hour: int.parse(rawValue.substring(0, 2)),
        minute: int.parse(rawValue.substring(3, 5)),
      );

      onChanged(startTime);
    }
  }
}
