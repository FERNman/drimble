import '../../infra/extensions/shift_date_time.dart';
import '../alcohol/alcohol.dart';
import '../alcohol/milliliter.dart';
import '../alcohol/percentage.dart';
import 'stomach_fullness.dart';

class Drink extends Alcohol {
  String? id;
  final StomachFullness stomachFullness;

  /// The time when drinking this drink started. Only to be used for calculating the BAC.
  ///
  /// <b>Must not be used for date comparisons!</b>
  final DateTime startTime;
  final Duration duration;

  /// The date of this drink.
  /// If the drink started before 6am, it is considered to be on the previous day.
  DateTime get date => startTime.shift();

  double get gramsOfAlcohol => (volume * alcoholByVolume * Alcohol.density);
  int get calories => (gramsOfAlcohol * 7.1).round();

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

  Drink({
    this.id,
    required super.name,
    required super.icon,
    required super.category,
    required super.volume,
    required super.alcoholByVolume,
    required this.startTime,
    required this.duration,
    required this.stomachFullness,
  }) : assert(alcoholByVolume > 0.0 && alcoholByVolume <= 1.0);

  Drink.fromExistingDrink(Drink drink, {required this.startTime})
      : duration = drink.duration,
        stomachFullness = drink.stomachFullness,
        super(
          name: drink.name,
          icon: drink.icon,
          category: drink.category,
          volume: drink.volume,
          alcoholByVolume: drink.alcoholByVolume,
        );

  Drink copyWith({
    Milliliter? volume,
    Percentage? alcoholByVolume,
    DateTime? startTime,
    Duration? duration,
    StomachFullness? stomachFullness,
  }) =>
      Drink(
        id: id,
        name: name,
        icon: icon,
        category: category,
        volume: volume ?? this.volume,
        alcoholByVolume: alcoholByVolume ?? this.alcoholByVolume,
        startTime: startTime ?? this.startTime,
        duration: duration ?? this.duration,
        stomachFullness: stomachFullness ?? this.stomachFullness,
      );
}
