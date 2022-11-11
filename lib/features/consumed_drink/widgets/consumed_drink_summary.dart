import 'package:flutter/material.dart';

import '../../../domain/diary/consumed_drink.dart';
import '../../common/build_context_extensions.dart';

class ConsumedDrinkSummary extends StatelessWidget {
  final ConsumedDrink drink;

  const ConsumedDrinkSummary(this.drink, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(drink.name, style: context.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'This drink will raise your blood alcohol level by approx. 0.2‰.',
                style: context.textTheme.bodyMedium,
              )
            ],
          ),
        ),
        Image.asset(drink.icon, width: 96, height: 96, fit: BoxFit.fill)
      ],
    );
  }
}
