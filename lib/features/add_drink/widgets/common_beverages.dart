import 'package:flutter/material.dart';

import '../../../domain/alcohol/beverage.dart';
import '../../common/build_context_extensions.dart';

typedef CommonBeverageTapCallback = void Function(Beverage);

class CommonBeverages extends StatelessWidget {
  final List<Beverage> commonBeverages;
  final CommonBeverageTapCallback onTap;

  const CommonBeverages(this.commonBeverages, {required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final beverages = commonBeverages.map((it) => _CommonBeverage(it, onTap: () => onTap(it))).toList();

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
          )
        ],
      ),
    );
  }
}

class _CommonBeverage extends StatelessWidget {
  final Beverage beverage;
  final GestureTapCallback onTap;

  const _CommonBeverage(this.beverage, {required this.onTap});

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
            Image.asset(beverage.icon),
            const SizedBox(height: 8),
            Text(
              beverage.name,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
