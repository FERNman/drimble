import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/alcohol/ingredient.dart';
import '../../../domain/diary/consumed_cocktail.dart';
import '../../common/build_context_extensions.dart';

class CocktailIngredients extends StatelessWidget {
  final ConsumedCocktail _cocktail;
  final List<Ingredient> _ingredients;

  const CocktailIngredients(this._cocktail, this._ingredients, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _ingredients.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) => _buildIngredientItem(context, _ingredients[index]),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }

  Widget _buildIngredientItem(BuildContext context, Ingredient ingredient) {
    final percentFormat = NumberFormat.percentPattern();

    return Row(
      children: [
        Image.asset(ingredient.iconPath, width: 28, height: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ingredient.name, style: context.textTheme.bodyLarge),
              const SizedBox(height: 2),
              Text(
                percentFormat.format(ingredient.alcoholByVolume),
                style: context.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Text(
          context.l18n.common_amountInMilliliters(ingredient.actualVolume(_cocktail.volume)),
          style: context.textTheme.labelLarge,
        ),
      ],
    );
  }
}
