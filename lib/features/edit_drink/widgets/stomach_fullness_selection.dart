import 'package:flutter/material.dart';

import '../../../domain/diary/stomach_fullness.dart';
import '../../../infra/l18n/stomach_fullness_translations.dart';

class StomachFullnessSelection extends StatelessWidget {
  final StomachFullness value;
  final ValueChanged<StomachFullness> onChanged;

  const StomachFullnessSelection({
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final children = StomachFullness.values
        // ignore: unnecessary_cast
        .map((el) => Expanded(
              child: InputChip(
                label: SizedBox(width: double.infinity, child: Text(el.translate(context))),
                selected: value == el,
                onSelected: (selected) => onChanged(el),
              ),
            ) as Widget)
        .toList();

    for (var i = 0; i < children.length - 1; i += 2) {
      children.insert(i + 1, const SizedBox(width: 8));
    }

    return Row(children: children);
  }
}
