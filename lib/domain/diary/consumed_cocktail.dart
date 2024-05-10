import 'package:cloud_firestore/cloud_firestore.dart';
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

  factory ConsumedCocktail.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) =>
      ConsumedCocktail(
        id: snapshot.id,
        name: snapshot['name'] as String,
        iconPath: snapshot['iconPath'] as String,
        volume: snapshot['volume'] as int,
        ingredients: (snapshot['ingredients'] as List).map((e) => Ingredient.fromFirestore(e)).toList(),
        startTime: (snapshot['startTime'] as Timestamp).toDate(),
        duration: Duration(milliseconds: snapshot['duration'] as int),
      );

  @override
  Map<String, dynamic> toFirestore() => {
        'name': name,
        'iconPath': iconPath,
        'category': category.toString(),
        'volume': volume,
        'alcoholByVolume': alcoholByVolume,
        'startTime': startTime,
        'duration': duration.inMilliseconds,
        'ingredients': ingredients.map((e) => e.toFirestore()).toList(),
        'type': 'cocktail', // Inheritance
      };
}
