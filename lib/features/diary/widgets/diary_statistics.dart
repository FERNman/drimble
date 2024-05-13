import 'package:flutter/material.dart';

import '../../common/build_context_extensions.dart';

class DiaryStatistics extends StatelessWidget {
  final double gramsOfAlcohol;
  final int calories;

  const DiaryStatistics({
    required this.gramsOfAlcohol,
    required this.calories,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.diary_yourDrinking),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildSmallStatistic(
              context,
              number: context.l10n.common_mass(gramsOfAlcohol.round()),
              text: context.l10n.diary_statisticsAlcohol,
            ),
            const SizedBox(width: 12),
            _buildSmallStatistic(
              context,
              number: context.l10n.common_calories(calories),
              text: context.l10n.diary_kcalInTotal,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallStatistic(BuildContext context, {required String number, required String text}) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: number,
                  style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.primary),
                ),
                TextSpan(
                  text: ' $text',
                  style: context.textTheme.bodyMedium,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
