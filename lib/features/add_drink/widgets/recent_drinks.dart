import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/diary/drink.dart';
import '../../common/build_context_extensions.dart';

typedef ConsumedDrinkTapCallback = void Function(Drink);

class RecentDrinks extends StatelessWidget {
  final List<Drink> recentDrinks;
  final ConsumedDrinkTapCallback onTap;

  const RecentDrinks(this.recentDrinks, {required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
            child: Text(context.l18n.add_drink_recentlyAdded, style: context.textTheme.titleMedium),
          ),
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentDrinks.length,
            itemBuilder: (context, index) {
              final drink = recentDrinks[index];

              return _RecentDrink(drink, onTap: () => onTap(drink));
            },
          )
        ],
      ),
    );
  }
}

class _RecentDrink extends StatelessWidget {
  final Drink drink;
  final GestureTapCallback onTap;

  const _RecentDrink(this.drink, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Image(image: AssetImage(drink.icon), width: 32, height: 32),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(drink.name, style: context.textTheme.bodyLarge),
                Text(
                  '${drink.volume}ml - ${NumberFormat.percentPattern().format(drink.alcoholByVolume)}',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
            const Spacer(),
            IconButton(onPressed: onTap, icon: const Icon(Icons.add))
          ],
        ),
      ),
    );
  }
}
