import 'package:flutter/material.dart';

import '../../../domain/user/gender.dart';
import '../../common/build_context_extensions.dart';
import '../../common/widgets/selectable_card.dart';

typedef GenderChangeCallback = void Function(Gender selection);

class GenderSelection extends StatefulWidget {
  final Gender selection;
  final GenderChangeCallback onSelectionChange;

  const GenderSelection({
    required this.selection,
    required this.onSelectionChange,
    super.key,
  });

  @override
  State<GenderSelection> createState() => _GenderSelectionState();
}

class _GenderSelectionState extends State<GenderSelection> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SelectableCard(
            isSelected: widget.selection == Gender.male,
            onSelect: () => widget.onSelectionChange(Gender.male),
            child: Column(
              children: [
                const Image(image: AssetImage('assets/images/male.png')),
                const SizedBox(height: 12),
                Text(context.l18n.common_genderMale, style: context.textTheme.titleMedium),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SelectableCard(
            isSelected: widget.selection == Gender.female,
            onSelect: () => widget.onSelectionChange(Gender.female),
            child: Column(
              children: [
                const Image(image: AssetImage('assets/images/female.png')),
                const SizedBox(height: 12),
                Text(context.l18n.common_genderFemale, style: context.textTheme.titleMedium),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
