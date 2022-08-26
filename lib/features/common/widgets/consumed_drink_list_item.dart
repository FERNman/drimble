import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/drink/consumed_drink.dart';

class ConsumedDrinkListItem extends StatelessWidget {
  final ConsumedDrink drink;
  final GestureTapCallback onEdit;
  final GestureTapCallback onDelete;

  const ConsumedDrinkListItem(this.drink, {required this.onEdit, required this.onDelete, super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Image(
              image: AssetImage(drink.beverage.icon),
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(drink.beverage.name, style: textTheme.bodyLarge),
                Text('${drink.volume}ml - ${(drink.alcoholByVolume * 100).round()}%', style: textTheme.bodySmall),
              ],
            ),
            const Spacer(),
            Text(DateFormat(DateFormat.HOUR_MINUTE).format(drink.startTime), style: textTheme.bodyMedium),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline))
          ],
        ),
      ),
    );
  }
}
