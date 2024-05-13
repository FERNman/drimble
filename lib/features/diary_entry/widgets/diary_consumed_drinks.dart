import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/diary/consumed_drink.dart';
import '../../common/build_context_extensions.dart';

typedef ConsumedDrinkTapCallback = void Function(ConsumedDrink drink);

class DiaryConsumedDrinks extends StatelessWidget {
  final List<ConsumedDrink> drinks;
  final ConsumedDrinkTapCallback onEdit;
  final ConsumedDrinkTapCallback onDelete;

  const DiaryConsumedDrinks(
    this.drinks, {
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
          child: Text(context.l10n.diary_consumedDrinksTitle, style: context.textTheme.titleSmall),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(0),
          itemCount: drinks.length,
          itemBuilder: (context, index) {
            final drink = drinks[index];

            return _DrinkListItem(
              drink,
              onEdit: () => onEdit(drink),
              onDelete: () => onDelete(drink),
            );
          },
        ),
      ],
    );
  }
}

class _DrinkListItem extends StatelessWidget {
  final ConsumedDrink drink;
  final GestureTapCallback onEdit;
  final GestureTapCallback onDelete;

  const _DrinkListItem(this.drink, {required this.onEdit, required this.onDelete, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Image(
              image: AssetImage(drink.iconPath),
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
