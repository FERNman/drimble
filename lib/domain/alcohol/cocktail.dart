import 'package:collection/collection.dart';

import 'alcohol.dart';
import 'drink.dart';
import 'drink_category.dart';
import 'ingredient.dart';

class Cocktail extends Drink {
  /// The volume of the ingredients **is at 100ml of this cocktail**.
  /// I know this is very implicit, but I'm not yet sure if creating a separate class of ingredients is better.
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
          alcoholByVolume: _calculateAlcoholByVolume(ingredients, Drink.defaultVolume),
        );

  static Percentage _calculateAlcoholByVolume(List<Ingredient> ingredients, int volume) {
    return ingredients.map((e) => e.alcoholByVolume * (e.volume / volume)).sum;
  }
}
