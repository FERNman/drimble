import 'package:collection/collection.dart';

import '../alcohol/alcohol.dart';
import '../alcohol/drink_category.dart';
import '../alcohol/milliliter.dart';
import '../alcohol/percentage.dart';
import 'drink.dart';

class Cocktail extends Drink {
  final List<Alcohol> ingredients;

  Cocktail({
    required super.name,
    required super.icon,
    required this.ingredients,
    required super.startTime,
    required super.duration,
    required super.stomachFullness,
  })  : assert(ingredients.isNotEmpty),
        super(
          category: DrinkCategory.cocktail,
          volume: _calculateVolume(ingredients),
          alcoholByVolume: _calculateAlcoholByVolume(ingredients),
        );

  static Milliliter _calculateVolume(List<Alcohol> ingredients) {
    return ingredients.map((e) => e.volume).sum;
  }

  static Percentage _calculateAlcoholByVolume(List<Alcohol> ingredients) {
    final totalVolume = _calculateVolume(ingredients);
    return ingredients.map((e) => e.alcoholByVolume * e.volume * (e.volume / totalVolume)).sum;
  }
}
