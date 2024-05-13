import 'package:flutter/material.dart';

import '../../common/build_context_extensions.dart';

class DiaryDrinkFreeDay extends StatelessWidget {
  const DiaryDrinkFreeDay({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.diary_drinkFreeDay,
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(context.l10n.diary_drinkFreeDayGreatJob, style: context.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
