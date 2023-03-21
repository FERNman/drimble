import 'dart:math';

import 'package:flutter/material.dart';

import '../../../domain/user/goals.dart';
import '../../common/build_context_extensions.dart';
import '../../common/widgets/circular_percentage_indicator.dart';

class WeeklyAlcoholConsumption extends StatelessWidget {
  final double totalGramsOfAlcohol;
  final double changeToLastWeek;
  final Goals goals;

  final GestureTapCallback onEdit;

  const WeeklyAlcoholConsumption({
    required this.totalGramsOfAlcohol,
    required this.changeToLastWeek,
    required this.goals,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final remainingGramsOfAlcohol = ((goals.weeklyGramsOfAlcohol ?? 0) - totalGramsOfAlcohol);
    final remainingPercentToLimit = max(0.0, 1 - remainingGramsOfAlcohol / (goals.weeklyGramsOfAlcohol ?? 1));

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          child: CircularPercentageIndicator(
            percentage: remainingPercentToLimit,
            width: min(250, MediaQuery.of(context).size.width - 32 * 2), // 32 px padding each size
            backgroundColor: context.colorScheme.primaryContainer,
            foregroundColor: context.colorScheme.primary,
          ),
        ),
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${totalGramsOfAlcohol.toStringAsFixed(0)}g',
                style: context.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_getLimitText(context)),
            ],
          ),
        ),
        Positioned(
          bottom: 8,
          child: _buildWeeklyAlcoholGoal(context, remainingGramsOfAlcohol),
        ),
      ],
    );
  }

  Widget _buildWeeklyAlcoholGoal(BuildContext context, double remainingGramsOfAlcohol) {
    return Text(
      context.l18n.analytics_goalsWeeklyAlcoholRemaining(remainingGramsOfAlcohol.round()),
      style: context.textTheme.bodyMedium,
    );
  }

  String _getLimitText(BuildContext context) {
    final remainingGramsOfAlcohol = (goals.weeklyGramsOfAlcohol ?? 0) - totalGramsOfAlcohol;

    if (remainingGramsOfAlcohol < 0) {
      return context.l18n.analytics_alcoholConsumptionOverLimit;
    } else if (remainingGramsOfAlcohol < 10) {
      return context.l18n.analytics_alcoholConsumptionCloseToLimit;
    } else {
      return context.l18n.analytics_alcoholConsumptionWithinLimits;
    }
  }
}
