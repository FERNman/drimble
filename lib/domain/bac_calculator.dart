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

/// This class calculates the BAC for a given user and a given time range.
/// It uses a modified version of the Watson formula.
/// 
/// It does only account for the activity of Aldehyde Dehydrogenase (ADH), Cytochrome P450 and Catalase 
/// are not yet taken into account.
/// It also doesn't yet take into account other pathways of elimination alcohol, such as excretion, breath, and perspiration.
/// However, those are not as important as elimination through metabolism.
class BACCalculator {
  static const _deltaTime = Duration(minutes: 5);

  final User user;

  BACCalculator(this.user);

  BACCalculationResults calculate(BACCalculationArgs args) {
    final rhoFactor = _calculateRhoFactorForUser();

    // We also simulate the drinks before the start time, but not as accurate
    // and we don't add the simulation results to the return value.
    // They are only needed to start with the correct BAC
    final drinksBeforeStartTime = args.drinks.where((el) => el.startTime.isBefore(args.startTime)).toList()
      ..sort((lhs, rhs) => lhs.startTime.compareTo(rhs.startTime));

    var currentBAC = 0.0;
    if (drinksBeforeStartTime.isNotEmpty) {
      currentBAC = _calculateBACFromOlderDrinks(drinksBeforeStartTime, args.startTime, rhoFactor);
    }

    // Only these drinks count to the results
    final drinksAfterStartTime = args.drinks.where((el) => el.startTime.isAfter(args.startTime)).toList();
    final results = <BACEntry>[];

    var previousAbsorbedAlcohol = 0.0;
    for (var time = args.startTime;
        time.isBefore(args.endTime) || currentBAC >= Alcohol.soberLimit;
        time = time.add(_deltaTime)) {
      final absorbedAlcohol = _calculateAbsorbedAlcohol(drinksAfterStartTime, time);
      final deltaAbsorbedAlcohol = absorbedAlcohol - previousAbsorbedAlcohol;
      currentBAC += (deltaAbsorbedAlcohol / rhoFactor);

      previousAbsorbedAlcohol = absorbedAlcohol;

      final metabolizedAlcohol = _calculateRateOfMetabolism(currentBAC) * (_deltaTime.inMinutes / 60.0);
      currentBAC -= metabolizedAlcohol;

      results.add(BACEntry(time, currentBAC / user.weight));
    }

    return BACCalculationResults(results);
  }

  double _calculateBACFromOlderDrinks(List<ConsumedDrink> drinksBeforeStartTime, DateTime startTime, double rhoFactor) {
    var currentBAC = 0.0;
    var previousAbsorbedAlcohol = 0.0;
    final timeOfFirstDrink = drinksBeforeStartTime.first.startTime;
    for (var time = timeOfFirstDrink; time.isBefore(startTime); time = time.add(_deltaTime)) {
      final absorbedAlcohol = _calculateAbsorbedAlcohol(drinksBeforeStartTime, time);
      final deltaAbsorbedAlcohol = absorbedAlcohol - previousAbsorbedAlcohol;
      currentBAC += (deltaAbsorbedAlcohol / rhoFactor);

      previousAbsorbedAlcohol = absorbedAlcohol;

      final metabolizedAlcohol = _calculateRateOfMetabolism(currentBAC) * (_deltaTime.inMinutes / 60.0);
      currentBAC -= metabolizedAlcohol;
    }

    return currentBAC;
  }

  // TODO: Verify this multiplication by 10 is actually correct
  double _calculateRhoFactorForUser() => (user.totalBodyWater / user.weight) / user.bloodWaterContent * 10.0;

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
    // Between 5 and 15 mmol/min/mg
    const vmax = 15.0; // TODO: Adapt to BAC and user
    // Betwee 0.2 and 8 mM
    const km = 6; // TODO: Look up values

    return (vmax * currentBAC) / (km + currentBAC);
  }
}
