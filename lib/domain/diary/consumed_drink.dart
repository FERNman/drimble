import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../alcohol/alcohol.dart';
import '../alcohol/cocktail.dart';
import '../alcohol/drink.dart';
import '../alcohol/drink_category.dart';
import 'consumed_cocktail.dart';

class ConsumedDrink extends Alcohol {
  final String id;

  /// The time when drinking this drink started. Only to be used for calculating the BAC.
  ///
  /// <b>Must not be used for date comparisons!</b>
  // TODO: Refactor to TimeOfDay
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;

  ConsumedDrink({
    String? id,
    required super.name,
    required super.iconPath,
    required super.category,
    required super.volume,
    required super.alcoholByVolume,
    required this.startTime,
    required this.duration,
  })  : assert(alcoholByVolume >= 0.0 && alcoholByVolume <= 1.0),
        id = id ?? const Uuid().v4(),
        endTime = startTime.add(duration);

  factory ConsumedDrink.deepCopy(ConsumedDrink drink, {required DateTime startTime}) {
    if (drink is ConsumedCocktail) {
      return ConsumedCocktail.deepCopy(drink, startTime: startTime);
    }

    return ConsumedDrink(
      name: drink.name,
      iconPath: drink.iconPath,
      category: drink.category,
      volume: drink.volume,
      alcoholByVolume: drink.alcoholByVolume,
      startTime: startTime,
      duration: drink.duration,
    );
  }

  factory ConsumedDrink.fromDrink(Drink drink, {required DateTime startTime}) {
    if (drink is Cocktail) {
      return ConsumedCocktail.fromDrink(drink, startTime: startTime);
    }

    return ConsumedDrink(
      name: drink.name,
      iconPath: drink.iconPath,
      category: drink.category,
      volume: drink.volume,
      alcoholByVolume: drink.alcoholByVolume,
      startTime: startTime,
      duration: drink.defaultDuration,
    );
  }

  ConsumedDrink copyWith({
    Milliliter? volume,
    Percentage? alcoholByVolume,
    DateTime? startTime,
    Duration? duration,
  }) =>
      ConsumedDrink(
        id: id,
        name: name,
        iconPath: iconPath,
        category: category,
        volume: volume ?? this.volume,
        alcoholByVolume: alcoholByVolume ?? this.alcoholByVolume,
        startTime: startTime ?? this.startTime,
        duration: duration ?? this.duration,
      );

  factory ConsumedDrink.fromJSON(Map<String, dynamic> json) => json['type'] == 'cocktail'
      ? ConsumedCocktail.fromJSON(json)
      : ConsumedDrink(
          id: json['id'] as String,
          name: json['name'] as String,
          iconPath: json['iconPath'] as String,
          category: DrinkCategory.values.firstWhere((el) => el.name == json['category']),
          volume: json['volume'] as int,
          alcoholByVolume: (json['alcoholByVolume'] as num).toDouble(),
          startTime: (json['startTime'] as Timestamp).toDate(),
          duration: Duration(microseconds: json['duration'] as int),
        );

  Map<String, dynamic> toJSON() => {
        'id': id,
        'name': name,
        'iconPath': iconPath,
        'category': category.name,
        'volume': volume,
        'alcoholByVolume': alcoholByVolume,
        'startTime': startTime,
        'duration': duration.inMicroseconds,
        'type': 'drink', // Inheritance
      };
}
