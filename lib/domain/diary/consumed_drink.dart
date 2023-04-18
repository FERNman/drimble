import '../alcohol/alcohol.dart';
import '../alcohol/cocktail.dart';
import '../alcohol/drink.dart';
import '../date.dart';
import 'consumed_cocktail.dart';
import 'stomach_fullness.dart';

class ConsumedDrink extends Alcohol {
  String? id;
  final StomachFullness stomachFullness;

  /// The time when drinking this drink started. Only to be used for calculating the BAC.
  ///
  /// <b>Must not be used for date comparisons!</b>
  final DateTime startTime;
  final Duration duration;

  /// The date of this drink.
  /// If the drink started before 6am, it is considered to be on the previous day.
  Date get date => startTime.toDate();

  /// How much of this drink is absorbed per hour
  double get rateOfAbsorption {
    switch (stomachFullness) {
      case StomachFullness.empty:
        return 6.5;
      case StomachFullness.normal:
        return 3;
      case StomachFullness.full:
        return 2.3;
    }
  }

  ConsumedDrink({
    this.id,
    required super.name,
    required super.iconPath,
    required super.category,
    required super.volume,
    required super.alcoholByVolume,
    required this.startTime,
    required this.duration,
    required this.stomachFullness,
  }) : assert(alcoholByVolume >= 0.0 && alcoholByVolume <= 1.0);

  factory ConsumedDrink.fromDrink(Drink drink, {required DateTime startTime}) {
    if (drink is Cocktail) {
      return ConsumedCocktail(
        name: drink.name,
        iconPath: drink.iconPath,
        volume: drink.volume,
        ingredients: drink.ingredients,
        startTime: startTime,
        duration: drink.defaultDuration,
        stomachFullness: StomachFullness.empty,
      );
    }

    return ConsumedDrink(
      name: drink.name,
      iconPath: drink.iconPath,
      category: drink.category,
      volume: drink.volume,
      alcoholByVolume: drink.alcoholByVolume,
      startTime: startTime,
      duration: drink.defaultDuration,
      stomachFullness: StomachFullness.empty,
    );
  }

  ConsumedDrink copyWith({
    Milliliter? volume,
    Percentage? alcoholByVolume,
    DateTime? startTime,
    Duration? duration,
    StomachFullness? stomachFullness,
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
        stomachFullness: stomachFullness ?? this.stomachFullness,
      );
}
