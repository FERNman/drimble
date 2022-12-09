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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black26),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGramsOfAlcohol(context),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: SizedBox(width: 48, child: Divider())),
              _buildDrinksAndCalories(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGramsOfAlcohol(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${gramsOfAlcohol.toStringAsFloat(1)} ',
                style: context.textTheme.headlineLarge?.copyWith(color: context.colorScheme.primary),
              ),
              TextSpan(text: context.l18n.diary_statisticsGramsOfAlcohol, style: context.textTheme.bodyLarge),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l18n.diary_statisticsGramsOfAlcoholGuidelines,
          style: context.textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }

  Row _buildDrinksAndCalories(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildSmallStatistic(
            context,
            number: numberOfConsumedDrinks,
            title: context.l18n.diary_statisticsConsumedDrinks,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildSmallStatistic(
            context,
            number: calories,
            title: context.l18n.diary_statisticsCaloriesFromAlcohol,
          ),
        ),
      ],
    );
  }

  Column _buildSmallStatistic(BuildContext context, {required int number, required String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number',
          style: context.textTheme.titleLarge?.copyWith(color: context.colorScheme.primary),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: context.textTheme.bodySmall?.copyWith(color: Colors.black.withOpacity(0.7)),
        )
      ],
    );
  }
}
