import 'package:collection/collection.dart';

import '../alcohol/alcohol.dart';
import '../alcohol/drink_category.dart';
import '../alcohol/ingredient.dart';
import 'consumed_drink.dart';

class ConsumedCocktail extends ConsumedDrink {
  final List<Ingredient> ingredients;

  ConsumedCocktail({
    super.id,
    required super.name,
    required super.iconPath,
    required super.volume,
    required this.ingredients,
    required super.startTime,
    required super.duration,
    required super.stomachFullness,
  })  : assert(ingredients.isNotEmpty),
        super(
          category: DrinkCategory.cocktail,
          alcoholByVolume: _calculateAlcoholByVolume(ingredients, volume),
        );

  static Percentage _calculateAlcoholByVolume(List<Alcohol> ingredients, int volume) {
    return ingredients.map((e) => e.alcoholByVolume * (e.volume / volume)).sum;
  }
}
