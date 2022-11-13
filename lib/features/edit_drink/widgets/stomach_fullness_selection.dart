import 'package:flutter/material.dart';

import '../../../domain/diary/stomach_fullness.dart';
import '../../../infra/l18n/stomach_fullness_translations.dart';

class StomachFullnessSelection extends StatefulWidget {
  final StomachFullness initialValue;
  final ValueChanged<StomachFullness> onChanged;

  const StomachFullnessSelection({required this.initialValue, required this.onChanged, super.key});

  @override
  State<StomachFullnessSelection> createState() => _StomachFullnessSelectionState();
}

class _StomachFullnessSelectionState extends State<StomachFullnessSelection> {
  late StomachFullness _stomachFullness;

  @override
  void initState() {
    super.initState();

    _stomachFullness = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final children = StomachFullness.values
        // ignore: unnecessary_cast
        .map((e) => Expanded(
              child: InputChip(
                label: SizedBox(width: double.infinity, child: Text(e.translate(context))),
                selected: _stomachFullness == e,
                onSelected: (selected) => _setValue(e),
              ),
            ) as Widget)
        .toList();

    for (var i = 0; i < children.length - 1; i += 2) {
      children.insert(i + 1, const SizedBox(width: 8));
    }

    return Row(children: children);
  }

  void _setValue(StomachFullness element) {
    setState(() {
      _stomachFullness = element;
    });

    widget.onChanged(_stomachFullness);
  }
}
