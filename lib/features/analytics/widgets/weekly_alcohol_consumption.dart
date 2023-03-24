import 'dart:math';

import 'package:flutter/material.dart';

import '../../../domain/user/goals.dart';
import '../../common/build_context_extensions.dart';
import '../../common/number_text_style.dart';
import '../../common/widgets/circular_percentage_indicator.dart';

class WeeklyAlcoholConsumption extends StatelessWidget {
  final double totalGramsOfAlcohol;
  final double changeToLastWeek;
  final Goals goals;

  final GestureTapCallback onEdit;

  final double _remainingGramsOfAlcohol;
  late final double _remainingPercentToLimit;

  WeeklyAlcoholConsumption({
    required this.totalGramsOfAlcohol,
    required this.changeToLastWeek,
    required this.goals,
    required this.onEdit,
    super.key,
  }) : _remainingGramsOfAlcohol = max(0.0, (goals.weeklyGramsOfAlcohol ?? 0) - totalGramsOfAlcohol) {
    _remainingPercentToLimit = _remainingGramsOfAlcohol / (goals.weeklyGramsOfAlcohol ?? 1);
  }

  @override
  Widget build(BuildContext context) {
    if (goals.weeklyGramsOfAlcohol == null) {
      return _buildWithoutGoal(context);
    } else {
      return _buildWithGoalSet(context);
    }
  }

  Widget _buildWithoutGoal(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildPercentageIndicator(context),
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              _buildAlcohol(context),
              const SizedBox(height: 4),
              Text(
                context.l18n.analytics_gramsOfAlcohol,
                style: context.textTheme.labelSmall?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: onEdit, child: Text(context.l18n.analytics_setAGoal)),
            ],
          ),
        ),
      ],
    );
  }

  Text _buildAlcohol(BuildContext context) {
    return Text(
      '${totalGramsOfAlcohol.toStringAsFixed(0)}g',
      style: context.textTheme.displaySmall?.forNumbers(),
    );
  }

  Widget _buildWithGoalSet(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit),
        ),
        _buildPercentageIndicator(context),
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAlcohol(context),
              const SizedBox(height: 4),
              Text(
                context.l18n.analytics_gramsOfAlcohol,
                style: context.textTheme.labelSmall?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Text(
                _getLimitText(context, _remainingGramsOfAlcohol),
                style: context.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 8,
          child: Text(
            context.l18n.analytics_goalsWeeklyAlcoholRemaining(_remainingGramsOfAlcohol.round()),
            style: context.textTheme.bodyMedium?.copyWith(color: const Color.fromARGB(180, 0, 0, 0)),
          ),
        ),
      ],
    );
  }

  Widget _buildPercentageIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: CircularPercentageIndicator(
        percentage: _remainingPercentToLimit,
        width: min(250, MediaQuery.of(context).size.width - 32 * 2), // 32 px padding each size
        backgroundColor: context.colorScheme.primaryContainer,
        foregroundColor: context.colorScheme.primary,
      ),
    );
  }

  String _getLimitText(BuildContext context, double remainingGramsOfAlcohol) {
    if (totalGramsOfAlcohol == 0) {
      return context.l18n.analytics_noAlcoholConsumedYet;
    }

    if (remainingGramsOfAlcohol <= 0) {
      return context.l18n.analytics_alcoholConsumptionOverLimit;
    } else if (remainingGramsOfAlcohol < 10) {
      return context.l18n.analytics_alcoholConsumptionCloseToLimit;
    } else {
      return context.l18n.analytics_alcoholConsumptionWithinLimits;
    }
  }
}
