import 'package:flutter/material.dart';

import '../../../domain/user/body_composition.dart';
import '../../common/build_context_extensions.dart';
import '../../common/widgets/selectable_card.dart';

typedef BodyCompositionChangeCallback = void Function(BodyComposition selection);

class BodyCompositionSelection extends StatefulWidget {
  final BodyComposition selection;
  final BodyCompositionChangeCallback onSelectionChange;

  const BodyCompositionSelection({
    required this.selection,
    required this.onSelectionChange,
    super.key,
  });

  @override
  State<BodyCompositionSelection> createState() => _BodyCompositionSelectionState();
}

class _BodyCompositionSelectionState extends State<BodyCompositionSelection> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _selectionCard(context, BodyComposition.lean),
          const SizedBox(width: 8),
          _selectionCard(context, BodyComposition.athletic),
          const SizedBox(width: 8),
          _selectionCard(context, BodyComposition.average),
          const SizedBox(width: 8),
          _selectionCard(context, BodyComposition.overweight),
        ],
      ),
    );
  }

  Widget _selectionCard(BuildContext context, BodyComposition value) {
    return SizedBox(
      width: 200,
      height: 250,
      child: SelectableCard(
        isSelected: widget.selection == value,
        onSelect: () => widget.onSelectionChange(value),
        child: Center(
          child: Text(_translateBodyComposition(context, value), style: context.textTheme.titleMedium),
        ),
      ),
    );
  }

  String _translateBodyComposition(BuildContext context, BodyComposition value) {
    switch (value) {
      case BodyComposition.lean:
        return context.l18n.common_bodyCompositionLean;
      case BodyComposition.athletic:
        return context.l18n.common_bodyCompositionAthletic;
      case BodyComposition.average:
        return context.l18n.common_bodyCompositionAverage;
      case BodyComposition.overweight:
        return context.l18n.common_bodyCompositionOverweight;
    }
  }
}
