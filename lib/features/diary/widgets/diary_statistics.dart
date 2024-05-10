import 'package:flutter/material.dart';

import '../../../infra/extensions/to_string_as_float.dart';
import '../../common/build_context_extensions.dart';

class DiaryStatistics extends StatelessWidget {
  final int numberOfConsumedDrinks;
  final double gramsOfAlcohol;
  final int calories;

  const DiaryStatistics({
    required this.numberOfConsumedDrinks,
    required this.gramsOfAlcohol,
    required this.calories,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildGramsOfAlcohol(context),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildConsumedDrinks(context)),
            const SizedBox(width: 12),
            Expanded(child: _buildCaloriesFromAlcohol(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildGramsOfAlcohol(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${gramsOfAlcohol.toStringAsFloat(1)} ',
                    style: context.textTheme.headlineSmall?.copyWith(color: context.colorScheme.primary),
                  ),
                  TextSpan(text: context.l10n.diary_statisticsGramsOfAlcohol, style: context.textTheme.bodyLarge),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.diary_statisticsGramsOfAlcoholGuidelines,
              style: context.textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsumedDrinks(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _buildSmallStatistic(
          context,
          number: numberOfConsumedDrinks,
          unit: context.l10n.diary_statisticsDrinks(numberOfConsumedDrinks),
          description: context.l10n.diary_statisticsConsumedToday,
        ),
      ),
    );
  }

  Widget _buildCaloriesFromAlcohol(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _buildSmallStatistic(
          context,
          number: calories,
          unit: context.l10n.diary_statisticsCalories,
          description: context.l10n.diary_statisticsFromAlcohol,
        ),
      ),
    );
  }

  Widget _buildSmallStatistic(
    BuildContext context, {
    required int number,
    required String unit,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$number ',
                style: context.textTheme.titleLarge?.copyWith(color: context.colorScheme.primary),
              ),
              TextSpan(
                text: unit,
                style: context.textTheme.bodyLarge,
              )
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(description, style: context.textTheme.bodySmall?.copyWith(color: Colors.black54)),
      ],
    );
  }
}
