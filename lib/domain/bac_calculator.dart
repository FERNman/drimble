import 'dart:math';

import '../features/common/copy_date_time.dart';
import 'drink/alcohol.dart';
import 'drink/consumed_drink.dart';
import 'user/user.dart';

class BacCalculator {
  final User user;

  BacCalculator._(this.user);

  static Map<DateTime, double> calculate(User user, List<ConsumedDrink> drinks, {DateTime? time}) {
    final calculator = BacCalculator._(user);
    return calculator._calculate(drinks, time ?? DateTime.now());
  }

  Map<DateTime, double> _calculate(List<ConsumedDrink> drinks, DateTime startTime) {
    final thirtyMinutesAgo = DateTime.now().subtract(const Duration(minutes: 30));
    final startTime = thirtyMinutesAgo.copyWith(minute: [15, 30, 45, 60][(thirtyMinutesAgo.minute / 15).floor()]);

    final Map<DateTime, double> bloodAlcoholContent = {};

    const simulationDuration = Duration(hours: 6);
    const deltaTime = Duration(minutes: 5);

    final rhoFactor = _calculateRhoFactorForUser();

    var currentBAC = 0.0;
    for (var minute = 0; minute < simulationDuration.inMinutes; minute += deltaTime.inMinutes) {
      final timestamp = startTime.add(Duration(minutes: minute));

      final absorbedAlcohol = _calculateAbsorbedAlcohol(drinks, timestamp) -
          _calculateAbsorbedAlcohol(drinks, timestamp.subtract(deltaTime));
      currentBAC += (absorbedAlcohol / rhoFactor);

      final metabolizedAlcohol = _calculateRateOfMetabolism(currentBAC) * (deltaTime.inMinutes / 60.0);
      currentBAC -= metabolizedAlcohol;

      bloodAlcoholContent[timestamp] = currentBAC / (user.weight);
    }

    return bloodAlcoholContent;
  }

  double _calculateRhoFactorForUser() => (user.totalBodyWater / user.weight) / user.bloodWaterContent;

  double _calculateAbsorbedAlcohol(List<ConsumedDrink> drinks, DateTime at) {
    return drinks.fold<double>(0.0, (absorbedAlcohol, drink) {
      return absorbedAlcohol + _calculateAbsorbedAlcoholForDrink(drink, at);
    });
  }

  double _calculateAbsorbedAlcoholForDrink(ConsumedDrink drink, DateTime at) {
    if (drink.startTime.isAfter(at)) {
      return 0.0;
    }

    final timeSinceDrinkStarted = at.difference(drink.startTime);
    final amountConsumed = min(1.0, timeSinceDrinkStarted.inMinutes / drink.duration.inMinutes);
    final ingestedAlcohol = drink.alcoholByVolume * drink.volume * Alcohol.density * amountConsumed;

    final amountAbsorbed = 1 - exp(-drink.rateOfAbsorption * (timeSinceDrinkStarted.inMinutes / 60.0));
    return ingestedAlcohol * amountAbsorbed;
  }

  double _calculateRateOfMetabolism(double currentBAC) {
    const vmax = 20.0;
    const km = 8;

    return (vmax * currentBAC) / (km + currentBAC);
  }
}
