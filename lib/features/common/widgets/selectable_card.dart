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
    final backgroundColor = isSelected ? context.colorScheme.primaryContainer : Colors.transparent;

    return Card(
      color: backgroundColor,
      elevation: 0.0,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onSelect,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black87),
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        ),
      ),
    );
  }
}
