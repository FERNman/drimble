import 'dart:math';

import 'bac_calulation_results.dart';
import 'drink/alcohol.dart';
import 'drink/consumed_drink.dart';
import 'user/user.dart';

class BACCalculator {
  final User user;

  BACCalculator(this.user);

  BACCalculationResults calculate(List<ConsumedDrink> drinks) {
    assert(drinks.isNotEmpty);

    final timeOfFirstDrink = drinks.map((e) => e.startTime).reduce((first, it) => it.isBefore(first) ? it : first);
    final timeOfLastDrink = drinks.map((e) => e.startTime).reduce((first, it) => it.isAfter(first) ? it : first);

    const deltaTime = Duration(minutes: 5);

    final results = <BACEntry>[];

    final rhoFactor = _calculateRhoFactorForUser();

    var currentBAC = 0.0;
    for (var time = timeOfFirstDrink;
        time.isBefore(timeOfLastDrink.add(const Duration(minutes: 30))) || currentBAC >= Alcohol.soberLimit;
        time = time.add(deltaTime)) {
      final absorbedAlcohol =
          _calculateAbsorbedAlcohol(drinks, time) - _calculateAbsorbedAlcohol(drinks, time.subtract(deltaTime));
      currentBAC += (absorbedAlcohol / rhoFactor);

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
