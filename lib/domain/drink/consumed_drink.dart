import 'package:isar/isar.dart';

import 'alcohol.dart';
import 'beverage.dart';
import 'milliliter.dart';
import 'percentage.dart';
import 'stomach_fullness.dart';

@Collection()
class ConsumedDrink {
  @Id()
  int? id;

  Beverage beverage;

  Milliliter volume;
  Percentage alcoholByVolume;

  StomachFullness stomachFullness;

  DateTime startTime;
  Duration duration;

  double get unitsOfAlcohol => (volume * alcoholByVolume) / 10;

  double get gramsOfAlcohol => (volume * alcoholByVolume * Alcohol.density);

  int get calories => (gramsOfAlcohol * 7.1).round();

  // How much of this drink is absorbed per hour
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
    required this.beverage,
    required this.volume,
    required this.alcoholByVolume,
    required this.startTime,
    required this.duration,
    required this.stomachFullness,
  });

  ConsumedDrink.fromBeverage(this.beverage)
      : volume = beverage.standardServings.first,
        alcoholByVolume = beverage.defaultABV,
        stomachFullness = StomachFullness.empty,
        startTime = DateTime.now(),
        duration = beverage.defaultDuration;

  ConsumedDrink copyWith(
          {Beverage? beverage,
          Milliliter? volume,
          Percentage? alcoholByVolume,
          DateTime? startTime,
          Duration? duration,
          StomachFullness? stomachFullness}) =>
      ConsumedDrink(
        beverage: beverage ?? this.beverage,
        volume: volume ?? this.volume,
        alcoholByVolume: alcoholByVolume ?? this.alcoholByVolume,
        startTime: startTime ?? this.startTime,
        duration: duration ?? this.duration,
        stomachFullness: stomachFullness ?? this.stomachFullness,
      );
}
