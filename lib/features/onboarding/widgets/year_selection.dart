import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class YearSelection extends StatefulWidget {
  final ValueChanged<int> onChanged;

  const YearSelection({required this.onChanged, super.key});

  @override
  State<YearSelection> createState() => _YearSelectionState();
}

class _YearSelectionState extends State<YearSelection> {
  int _value = 2000;

  @override
  Widget build(BuildContext context) {
    return NumberPicker(
      value: _value,
      minValue: 1900,
      maxValue: DateTime.now().year,
      step: 1,
      haptics: true,
      axis: Axis.vertical,
      onChanged: (value) {
        setState(() {
          _value = value;
        });

        widget.onChanged(value);
      },
    );
  }
}
