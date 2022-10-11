import 'package:flutter/material.dart';

import '../../../domain/alcohol/beverage.dart';

class ConsumedDrinkSummary extends StatelessWidget {
  final Beverage beverage;

  const ConsumedDrinkSummary(this.beverage, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(beverage.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'This drink will raise your blood alcohol level by approx. 0.2‰.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            ],
          ),
        ),
        Image.asset(beverage.icon, width: 96, height: 96, fit: BoxFit.fill)
      ],
    );
  }
}
