import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/alcohol/alcohol.dart';
import '../../common/build_context_extensions.dart';

class DrinkABVTextField extends StatelessWidget {
  static final _decimalRegex = RegExp(r'^\d*(\.\d*)?$');

  final Percentage value;
  final ValueChanged<Percentage> onChanged;

  const DrinkABVTextField({
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      child: TextFormField(
        initialValue: '${value * 100}',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(_decimalRegex)],
        validator: (value) => value != null && _isValid(value) ? null : context.l10n.edit_drink_invalidABV,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: const InputDecoration(prefixIcon: Icon(Icons.percent_outlined)),
        onChanged: _onChanged,
      ),
    );
  }

  void _onChanged(String value) {
    if (_isValid(value)) {
      onChanged(double.parse(value) / 100.0);
    }
  }

  bool _isValid(String value) {
    final number = double.tryParse(value);
    return number != null && number > 0 && number < 100;
  }
}
