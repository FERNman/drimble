import 'dart:math';

import 'alcohol/alcohol.dart';
import 'bac_calulation_results.dart';
import 'diary/consumed_drink.dart';
import 'user/user.dart';

class BACCalculationArgs {
  final List<ConsumedDrink> drinks;
  final DateTime startTime;
  final DateTime endTime;

  const BACCalculationArgs({
    required this.drinks,
    required this.startTime,
    required this.endTime,
  });
}

class BACCalculator {
  final User user;

  BACCalculator(this.user);

  BACCalculationResults calculate(BACCalculationArgs args) {
    const deltaTime = Duration(minutes: 5);

    final results = <BACEntry>[];

    final rhoFactor = _calculateRhoFactorForUser();

    var currentBAC = 0.0;
    var previousAbsorbedAlcohol = 0.0;
    for (var time = args.startTime;
        time.isBefore(args.endTime) || currentBAC >= Alcohol.soberLimit;
        time = time.add(deltaTime)) {
      final absorbedAlcohol = _calculateAbsorbedAlcohol(args.drinks, time);
      final deltaAbsorbedAlcohol = absorbedAlcohol - previousAbsorbedAlcohol;
      currentBAC += (deltaAbsorbedAlcohol / rhoFactor);

      previousAbsorbedAlcohol = absorbedAlcohol;

      final metabolizedAlcohol = _calculateRateOfMetabolism(currentBAC) * (deltaTime.inMinutes / 60.0);
      currentBAC -= metabolizedAlcohol;

      results.add(BACEntry(time, currentBAC / (user.weight)));
    }

    return BACCalculationResults(results);
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
    const vmax = 20.0; // TODO: Adapt to BAC and user
    const km = 8; // TODO: Look up values

    return (vmax * currentBAC) / (km + currentBAC);
  }
}
