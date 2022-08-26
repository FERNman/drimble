import 'package:flutter/material.dart';

import '../../../domain/drink/consumed_drink.dart';

class TodaysStatistics extends StatelessWidget {
  final List<ConsumedDrink> consumedDrinks;
  final double unitsOfAlcohol;
  final int calories;

  const TodaysStatistics({
    required this.consumedDrinks,
    required this.unitsOfAlcohol,
    required this.calories,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _HighlightContainer(highlight: '${consumedDrinks.length}', caption: 'drinks consumed')),
          const SizedBox(width: 8),
          Expanded(
            child: _HighlightContainer(highlight: unitsOfAlcohol.toStringAsFixed(2), caption: 'units of alcohol'),
          ),
          const SizedBox(width: 8),
          Expanded(child: _HighlightContainer(highlight: '$calories', caption: 'kcal from alcohol')),
        ],
      ),
    );
  }
}

class _HighlightContainer extends StatelessWidget {
  final String highlight;
  final String caption;

  const _HighlightContainer({required this.highlight, required this.caption});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 3,
      shadowColor: theme.colorScheme.shadow,
      color: theme.colorScheme.primary,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              highlight,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              caption,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
