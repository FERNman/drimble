import 'package:collection/collection.dart';

import '../alcohol/alcohol.dart';
import '../alcohol/drink_category.dart';
import '../alcohol/ingredient.dart';
import 'consumed_drink.dart';
import 'stomach_fullness.dart';

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

  @override
  ConsumedCocktail.fromExistingDrink(ConsumedDrink drink, {required super.startTime})
      : assert(drink is ConsumedCocktail),
        ingredients = (drink as ConsumedCocktail).ingredients,
        super(
          name: drink.name,
          iconPath: drink.iconPath,
          volume: drink.volume,
          duration: drink.duration,
          stomachFullness: drink.stomachFullness,
          alcoholByVolume: drink.alcoholByVolume,
          category: drink.category,
        );

  @override
  ConsumedCocktail copyWith({
    Milliliter? volume,
    Percentage? alcoholByVolume,
    DateTime? startTime,
    Duration? duration,
    StomachFullness? stomachFullness,
  }) =>
      ConsumedCocktail(
        id: id,
        name: name,
        iconPath: iconPath,
        volume: volume ?? this.volume,
        ingredients: ingredients,
        startTime: startTime ?? this.startTime,
        duration: duration ?? this.duration,
        stomachFullness: stomachFullness ?? this.stomachFullness,
      );
}
