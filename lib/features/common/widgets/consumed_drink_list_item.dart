import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/diary/consumed_drink.dart';
import '../build_context_extensions.dart';

class ConsumedDrinkListItem extends StatelessWidget {
  final ConsumedDrink drink;
  final GestureTapCallback onEdit;
  final GestureTapCallback onDelete;

  const ConsumedDrinkListItem(this.drink, {required this.onEdit, required this.onDelete, super.key});

  @override
  Widget build(BuildContext context) {
    final labelTextStyle = context.textTheme.labelSmall?.copyWith(color: Colors.black87);

    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Image(
              image: AssetImage(drink.beverage.icon),
              width: 42,
              height: 42,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat(DateFormat.HOUR_MINUTE).format(drink.startTime), style: labelTextStyle),
                Text(drink.beverage.name, style: context.textTheme.titleMedium),
                Text('${drink.volume}ml - ${(drink.alcoholByVolume * 100).round()}%', style: labelTextStyle),
              ],
            ),
            const Spacer(),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline))
          ],
        ),
      ),
    );
  }
}
