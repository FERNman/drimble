import 'package:flutter/material.dart';

import '../../common/build_context_extensions.dart';

class DiaryMarkAsDrinkFree extends StatelessWidget {
  final GestureTapCallback onMarkAsDrinkFreeDay;

  const DiaryMarkAsDrinkFree({
    required this.onMarkAsDrinkFreeDay,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.diary_notDrinkingToday,
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: onMarkAsDrinkFreeDay,
            child: Text(context.l10n.diary_markAsDrinkFreeDay),
          ),
        ],
      ),
    );
  }
}
