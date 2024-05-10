import 'package:flutter/material.dart';

import '../../common/build_context_extensions.dart';
import '../../common/widgets/time_input_field.dart';

class DrinkStartTimeTextField extends StatelessWidget {
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  const DrinkStartTimeTextField({
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TimeInputField(
      initialValue: TimeOfDay.fromDateTime(value),
      onChanged: (rawValue) => _onChanged(context, rawValue, value),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.access_time_outlined),
        label: Text(context.l10n.edit_drink_startTime),
      ),
    );
  }

  void _onChanged(BuildContext context, TimeOfDay rawValue, DateTime previousTime) {
    final startTime = previousTime.copyWith(
      hour: rawValue.hour,
      minute: rawValue.minute,
    );

    onChanged(startTime);
  }
}
