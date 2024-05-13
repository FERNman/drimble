import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

import '../alcohol/alcohol.dart';
import '../alcohol/cocktail.dart';
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
  })  : assert(ingredients.isNotEmpty),
        super(
          category: DrinkCategory.cocktail,
          alcoholByVolume: _calculateAlcoholByVolume(ingredients),
        );

  static Percentage _calculateAlcoholByVolume(List<Ingredient> ingredients) {
    return ingredients.map((e) => e.alcoholByVolume * e.percentOfCocktailVolume).sum;
  }

  @override
  ConsumedCocktail copyWith({
    Milliliter? volume,
    Percentage? alcoholByVolume,
    DateTime? startTime,
    Duration? duration,
    List<Ingredient>? ingredients,
  }) =>
      ConsumedCocktail(
        id: id,
        name: name,
        iconPath: iconPath,
        volume: volume ?? this.volume,
        ingredients: ingredients ?? this.ingredients,
        startTime: startTime ?? this.startTime,
        duration: duration ?? this.duration,
      );

  factory ConsumedCocktail.deepCopy(ConsumedCocktail cocktail, {required DateTime startTime}) => ConsumedCocktail(
        name: cocktail.name,
        iconPath: cocktail.iconPath,
        volume: cocktail.volume,
        ingredients: cocktail.ingredients,
        startTime: startTime,
        duration: cocktail.duration,
      );

  factory ConsumedCocktail.fromDrink(Cocktail drink, {required DateTime startTime}) => ConsumedCocktail(
        name: drink.name,
        iconPath: drink.iconPath,
        volume: drink.volume,
        ingredients: drink.ingredients,
        startTime: startTime,
        duration: drink.defaultDuration,
      );

  factory ConsumedCocktail.fromJSON(Map<String, dynamic> json) => ConsumedCocktail(
        id: json['id'] as String,
        name: json['name'] as String,
        iconPath: json['iconPath'] as String,
        volume: json['volume'] as int,
        ingredients: (json['ingredients'] as List).map((e) => Ingredient.fromJSON(e)).toList(),
        startTime: (json['startTime'] as Timestamp).toDate(),
        duration: Duration(milliseconds: json['duration'] as int),
      );

  @override
  Map<String, dynamic> toJSON() => {
        'id': id,
        'name': name,
        'iconPath': iconPath,
        'category': category.toString(),
        'volume': volume,
        'alcoholByVolume': alcoholByVolume,
        'startTime': startTime,
        'duration': duration.inMilliseconds,
        'ingredients': ingredients.map((e) => e.toJSON()).toList(),
        'type': 'cocktail', // Inheritance
      };
}
