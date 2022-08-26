import 'dart:math';

import 'package:flutter/material.dart';

import '../../../domain/drink/consumed_drink.dart';
import '../../common/widgets/consumed_drink_list_item.dart';

typedef ConsumedDrinkTapCallback = void Function(ConsumedDrink drink);

class RecentDrinks extends StatelessWidget {
  static const recentItemCount = 3;

  final List<ConsumedDrink> drinks;
  final ConsumedDrinkTapCallback onEdit;
  final ConsumedDrinkTapCallback onDelete;
  final GestureTapCallback onViewAll;

  const RecentDrinks(this.drinks, {required this.onEdit, required this.onDelete, required this.onViewAll, super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
          child: Text('Todays drinks', style: textTheme.titleMedium),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: min(drinks.length, recentItemCount + 1),
          itemBuilder: (context, index) {
            if (index < recentItemCount) {
              final drink = drinks[index];

              return ConsumedDrinkListItem(
                drink,
                onEdit: () => onEdit(drink),
                onDelete: () => onDelete(drink),
              );
            } else {
              return _ViewAllRow(
                remainingItemCount: drinks.length - recentItemCount,
                onTap: onViewAll,
              );
            }
          },
        ),
      ],
    );
  }
}

class _ViewAllRow extends StatelessWidget {
  final int remainingItemCount;
  final GestureTapCallback onTap;

  const _ViewAllRow({required this.remainingItemCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('+$remainingItemCount  more', style: textTheme.bodyMedium),
          TextButton(onPressed: onTap, child: const Text('see all')),
        ],
      ),
    );
  }
}
