import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/date.dart';
import '../../../domain/user/goals.dart';
import '../../../infra/extensions/format_date.dart';
import '../../common/build_context_extensions.dart';
import '../../common/number_text_style.dart';

class WeeklyDrinkFreeDays extends StatelessWidget {
  final Map<Date, bool?> drinkFreeDays;
  final Goals goals;
  final GestureTapCallback onTap;

  final int _drinkFreeDayCount;

  WeeklyDrinkFreeDays({
    required this.drinkFreeDays,
    required this.goals,
    required this.onTap,
    super.key,
  }) : _drinkFreeDayCount = drinkFreeDays.values.where((e) => e == true).length;

  @override
  Widget build(BuildContext context) {
    final didSetGoal = goals.weeklyDrinkFreeDays != null;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: didSetGoal ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTextAndIcon(context),
              const SizedBox(height: 24),
              _DrinkFreeDaysIndicator(drinkFreeDays: drinkFreeDays),
              didSetGoal ? const SizedBox() : _buildSetGoalButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextAndIcon(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDrinkFreeDaysText(context),
            const SizedBox(height: 4),
            _buildGoalText(context),
          ],
        ),
        goals.weeklyDrinkFreeDays == null
            ? const SizedBox()
            : const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.edit_outlined),
              ),
      ],
    );
  }

  Widget _buildSetGoalButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextButton(
        onPressed: onTap,
        child: Text(context.l18n.analytics_setAGoal),
      ),
    );
  }

  Widget _buildDrinkFreeDaysText(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: context.textTheme.bodyLarge,
        children: [
          TextSpan(
            text: '$_drinkFreeDayCount ',
            style: TextStyle(fontSize: 18, color: context.colorScheme.primary).forNumbers(),
          ),
          TextSpan(text: context.l18n.analytics_drinkFreeDays(_drinkFreeDayCount)),
        ],
      ),
    );
  }

  Widget _buildGoalText(BuildContext context) {
    if (goals.weeklyDrinkFreeDays == null) {
      return Text(context.l18n.analytics_maybeTrySettingAGoal, style: context.textTheme.bodySmall);
    }

    final remainingDrinkFreeDaysToGoal = goals.weeklyDrinkFreeDays! - _drinkFreeDayCount;
    if (remainingDrinkFreeDaysToGoal <= 0) {
      return Text(context.l18n.analytics_drinkFreeDaysGoalHit, style: context.textTheme.bodySmall);
    } else {
      return RichText(
        text: TextSpan(
          style: context.textTheme.bodySmall,
          children: [
            TextSpan(text: '$remainingDrinkFreeDaysToGoal ', style: NumberTextStyle.style),
            TextSpan(text: context.l18n.analytics_remainingDrinkFreeDaysToGoal)
          ],
        ),
      );
    }
  }
}

/// A statless widget that displays 7 circles representing the days of the week, each one with either a checkmark or an X as an icon,
/// depending on whether the diary entry of the user is marked as a drink-free day or not. If no diary entry exists yet (aka it's null),
/// the circle is empty and it's border is a dashed line.
class _DrinkFreeDaysIndicator extends StatelessWidget {
  final Map<Date, bool?> drinkFreeDays;

  const _DrinkFreeDaysIndicator({required this.drinkFreeDays});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: drinkFreeDays.entries
          .map(
            (e) => Column(
              children: [
                _buildDrinkFreeIndicator(context, e.value),
                const SizedBox(height: 4),
                _buildWeekdayText(context, e.key),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _buildDrinkFreeIndicator(BuildContext context, bool? isDrinkFree) {
    final container = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isDrinkFree == null ? null : Border.all(color: Colors.black54, width: 2),
      ),
      child: _getIcon(context, isDrinkFree),
    );

    if (isDrinkFree == null) {
      return DottedBorder(
        color: Colors.black26,
        borderType: BorderType.Circle,
        dashPattern: const <double>[2, 3],
        padding: EdgeInsets.zero,
        strokeWidth: 2,
        child: container,
      );
    } else {
      return container;
    }
  }

  Widget _getIcon(BuildContext context, bool? isDrinkFree) {
    if (isDrinkFree == null) {
      return const SizedBox();
    }

    return Center(
      child: Icon(
        isDrinkFree ? Icons.check : Icons.close,
        color: isDrinkFree ? context.colorScheme.primary : Colors.black45,
        size: 16,
      ),
    );
  }

  Widget _buildWeekdayText(BuildContext context, Date date) {
    final dateFormatter = DateFormat.E();

    return Text(dateFormatter.formatDate(date), style: context.textTheme.bodySmall?.copyWith(color: Colors.black54));
  }
}
