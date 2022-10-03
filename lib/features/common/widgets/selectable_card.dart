import 'package:flutter/material.dart';

import '../build_context_extensions.dart';

class SelectableCard extends StatelessWidget {
  final bool isSelected;
  final GestureTapCallback onSelect;

  final Widget child;

  const SelectableCard({
    required this.isSelected,
    required this.onSelect,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isSelected ? context.colorScheme.onPrimary : context.colorScheme.onPrimaryContainer;
    final backgroundColor = isSelected ? context.colorScheme.primary : context.colorScheme.primaryContainer;

    return Card(
      color: backgroundColor,
      elevation: isSelected ? 0.0 : 1.0,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: foregroundColor),
            child: child,
          ),
        ),
      ),
    );
  }
}
