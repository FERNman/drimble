import 'package:flutter/material.dart';

import '../../../domain/diary/consumed_drink.dart';
import '../../common/build_context_extensions.dart';

class EditDrinkSummary extends StatelessWidget {
  final ConsumedDrink drink;

  const EditDrinkSummary(this.drink, {super.key});

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
              Text(context.l18n.edit_drink_alcoholContent(drink.gramsOfAlcohol), style: context.textTheme.bodyMedium)
            ],
          ),
        ),
        Image.asset(drink.iconPath, width: 96, height: 96, fit: BoxFit.fill)
      ],
    );
  }
}
