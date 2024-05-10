import 'package:flutter/material.dart';

import '../../common/build_context_extensions.dart';
import '../../common/number_text_style.dart';

class WeeklyStatistics extends StatelessWidget {
  final int numberOfDrinks;
  final int calories;

  const WeeklyStatistics({
    required this.numberOfDrinks,
    required this.calories,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildConsumedDrinksCard(context)),
        const SizedBox(width: 12),
        Expanded(child: _buildCaloriesCard(context)),
      ],
    );
  }

  Widget _buildConsumedDrinksCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildSmallStatistic(
          context,
          number: numberOfDrinks,
          unit: context.l10n.diary_statisticsDrinks(numberOfDrinks),
          description: context.l10n.analytics_drinksThisWeek,
        ),
      ),
    );
  }

  Widget _buildCaloriesCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            style: context.textTheme.titleMedium,
            children: [
              TextSpan(
                text: '$number ',
                style: TextStyle(color: context.colorScheme.primary, fontSize: 18).forNumbers(),
              ),
              TextSpan(text: unit)
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(description, style: context.textTheme.bodySmall?.copyWith(color: Colors.black54)),
      ],
    );
  }
}
