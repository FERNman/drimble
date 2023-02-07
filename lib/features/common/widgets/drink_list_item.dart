import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/diary/drink.dart';
import '../build_context_extensions.dart';

class DrinkListItem extends StatelessWidget {
  final Drink drink;
  final GestureTapCallback onEdit;
  final GestureTapCallback onDelete;

  const DrinkListItem(this.drink, {required this.onEdit, required this.onDelete, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Image(
              image: AssetImage(drink.icon),
              width: 42,
              height: 42,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat(DateFormat.HOUR_MINUTE).format(drink.startTime), style: context.textTheme.labelSmall),
                Text(drink.name, style: context.textTheme.titleMedium),
                Text(
                  '${drink.volume}ml - ${NumberFormat.percentPattern().format(drink.alcoholByVolume)}',
                  style: context.textTheme.labelSmall,
                ),
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
