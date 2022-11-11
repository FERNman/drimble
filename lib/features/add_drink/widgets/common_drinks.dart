import 'package:flutter/material.dart';

import '../../../domain/diary/consumed_drink.dart';
import '../../common/build_context_extensions.dart';

typedef DrinkTapCallback = void Function(ConsumedDrink);

class CommonDrinks extends StatelessWidget {
  final List<ConsumedDrink> commonDrinks;
  final DrinkTapCallback onTap;

  const CommonDrinks(this.commonDrinks, {required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final beverages = commonDrinks.map((it) => _CommonDrink(it, onTap: () => onTap(it))).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l18n.add_drink_common, style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            physics: const NeverScrollableScrollPhysics(),
            children: beverages,
          ),
        ],
      ),
    );
  }
}

class _CommonDrink extends StatelessWidget {
  final ConsumedDrink drink;
  final GestureTapCallback onTap;

  const _CommonDrink(this.drink, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: context.colorScheme.outline),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Image.asset(drink.icon),
            const SizedBox(height: 8),
            Text(
              drink.name,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
