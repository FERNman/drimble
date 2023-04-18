import 'package:collection/collection.dart';

import '../alcohol/alcohol.dart';
import '../alcohol/cocktail.dart';
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

  static Percentage _calculateAlcoholByVolume(List<Ingredient> ingredients, int volume) {
    return ingredients.map((e) => e.alcoholByVolume * (e.volume / volume)).sum;
  }

  ConsumedCocktail.fromCocktail(Cocktail cocktail, {required super.startTime})
      : ingredients = cocktail.ingredients,
        super(
          name: cocktail.name,
          iconPath: cocktail.iconPath,
          volume: cocktail.defaultServings.first,
          duration: cocktail.defaultDuration,
          stomachFullness: StomachFullness.empty,
          alcoholByVolume: cocktail.alcoholByVolume,
          category: cocktail.category,
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
