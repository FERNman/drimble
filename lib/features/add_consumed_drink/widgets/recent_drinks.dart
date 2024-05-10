import 'package:flutter/material.dart';

import '../../../domain/alcohol/drink.dart';
import '../../common/build_context_extensions.dart';

typedef DrinkTapCallback = void Function(Drink);

class RecentDrinks extends StatelessWidget {
  final List<Drink> recentDrinks;
  final DrinkTapCallback onTap;

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
            child: Text(context.l10n.add_drink_recentlyAdded, style: context.textTheme.titleMedium),
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
    return ListTile(
      leading: Image.asset(drink.iconPath, height: 38),
      title: Text(drink.name),
      trailing: const Icon(Icons.add),
      onTap: onTap,
    );
  }
}
