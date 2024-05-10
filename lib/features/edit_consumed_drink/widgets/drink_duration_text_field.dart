import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/build_context_extensions.dart';

class DrinkDurationTextField extends StatelessWidget {
  final Duration value;
  final ValueChanged<Duration> onChanged;

  const DrinkDurationTextField({
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: '${value.inMinutes}',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) => value != null && _isValid(value) ? null : context.l10n.edit_drink_invalidDuration,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.hourglass_empty_outlined),
        labelText: context.l10n.edit_drink_duration,
        suffixText: context.l10n.edit_drink_minutes,
      ),
      onChanged: _onChanged,
    );
  }

  void _onChanged(String rawValue) {
    if (_isValid(rawValue)) {
      final duration = Duration(minutes: int.parse(rawValue));
      onChanged(duration);
    }
  }

  bool _isValid(String value) {
    final number = int.tryParse(value);
    return number != null && number > 0;
  }
}
