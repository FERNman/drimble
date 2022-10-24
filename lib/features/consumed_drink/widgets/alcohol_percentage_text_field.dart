import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/alcohol/percentage.dart';

class AlcoholPercentageTextField extends StatelessWidget {
  static final _percentageRegex = RegExp(r'^\d{1,2}$');

  final Percentage value;
  final ValueChanged<Percentage> onChanged;

  const AlcoholPercentageTextField({
    required this.value,
    required this.onChanged,
    super.key,
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
