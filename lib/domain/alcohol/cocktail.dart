import 'package:collection/collection.dart';

import 'alcohol.dart';
import 'drink.dart';
import 'drink_category.dart';
import 'ingredient.dart';

class Cocktail extends Drink {
  final List<Ingredient> ingredients;

  Cocktail({
    required super.name,
    required super.iconPath,
    required super.defaultServings,
    required super.defaultDuration,
    required this.ingredients,
  })  : assert(ingredients.isNotEmpty),
        super(
          category: DrinkCategory.cocktail,
          alcoholByVolume: _calculateAlcoholByVolume(ingredients),
        );

  static Percentage _calculateAlcoholByVolume(List<Ingredient> ingredients) {
    return ingredients.map((e) => e.alcoholByVolume * e.percentOfCocktailVolume).sum;
  }
}
