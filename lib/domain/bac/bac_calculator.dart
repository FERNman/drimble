import 'dart:math';

import 'package:collection/collection.dart';

import '../alcohol/alcohol.dart';
import '../diary/consumed_drink.dart';
import '../diary/stomach_fullness.dart';
import '../user/user.dart';
import 'bac_calulation_results.dart';
import 'drink_bac_extensions.dart';
import 'stomach_fullness_bac_extensions.dart';
import 'user_bac_extensions.dart';

/// This class estimates the BAC for a given user and a given time range.
/// It is based on a simple 3-compartment PBPK model introduced by Pieters that estimates the concentration of alcohol
/// in the body.
///
/// The metabolism is only based on the activity of Aldehyde Dehydrogenase (ADH), Cytochrome P450 is not yet
/// taken into account. Also, first-pass metabolism (reduced bioavailability by up to 10%)
/// and the impact of food on that as well as on the speed of metabolism is not yet modeled.
///
/// The ODEs are solved using the Euler method, accuracy could be improved by using a more sophisticated method.
///
/// Largely based on Jones, 2019, and Heck, 2006
class BACCalculator {
  final StomachFullness stomachFullness;
  final User user;

  BACCalculator(this.user, this.stomachFullness);

  BACCalculationResults calculate(List<ConsumedDrink> drinks) {
    assert(drinks.isNotEmpty, 'At least one drink is required to calculate the BAC');

    var alcoholInStomach = 0.0;
    var alcoholInSmallIntestine = 0.0;
    var alcoholInCentralCompartment = 0.0;

    const timestep = Duration(minutes: 5);
    final deltaTime = (1 / 60) * timestep.inMinutes;

    final startTime = minBy(drinks, (drink) => drink.startTime)!.startTime;
    final endTime = maxBy(drinks, (drink) => drink.endTime)!
        .endTime
        .add(const Duration(minutes: 30)); // add 30 minutes to make sure also the last drink is absorbed

    final results = <BACEntry>[];
    for (var time = startTime;
        time.isBefore(endTime) || alcoholInCentralCompartment >= Alcohol.soberLimit;
        time = time.add(timestep)) {
      // Step 0: Calculate the amount of ingested alcohol in grams per liter of the total body water
      final ingestedAlcohol = _calculateIngestedAlcohol(drinks, time, time.add(timestep)) / user.volumeOfDistribution;

      // Step 1: Calculate the concentration of alcohol in the stomach
      final gastricEmptying = _rateOfChangeGastricEmptying(alcoholInStomach, deltaTime);
      alcoholInStomach = alcoholInStomach + ingestedAlcohol - gastricEmptying;

      // Step 2: Calculate concentration of alcohol in the small intestine
      final absorption = _rateOfChangeAbsorption(alcoholInSmallIntestine, deltaTime);
      alcoholInSmallIntestine = alcoholInSmallIntestine + gastricEmptying - absorption;

      // Step 3: Calculate the concentration of alcohol in the central compartment
      final metabolism = _rateOfChangeForADHMetabolism(alcoholInCentralCompartment, deltaTime);
      alcoholInCentralCompartment = alcoholInCentralCompartment + absorption - metabolism;

      // Divide by 10 to convert from g/L to g/100mL
      results.add(BACEntry(time, alcoholInCentralCompartment / 10.0));
    }

    return BACCalculationResults(results);
  }

  double _calculateIngestedAlcohol(List<ConsumedDrink> drinks, DateTime from, DateTime until) {
    return drinks.where((drink) => drink.startTime.isBefore(until) && drink.endTime.isAfter(from)).map((drink) {
      final startTime = drink.startTime;
      final endTime = drink.endTime;

      final startTimeForCalculation = from.isAfter(startTime) ? from : startTime;
      final endTimeForCalculation = until.isBefore(endTime) ? until : endTime;
      final relevantTimeForCalculation = endTimeForCalculation.difference(startTimeForCalculation);
      final percentOfDrinkConsumed = min(1.0, relevantTimeForCalculation.inMinutes / drink.duration.inMinutes);
      final alcoholInGramsForDrink = drink.alcoholByVolume * drink.volume * Alcohol.density;

      return alcoholInGramsForDrink * percentOfDrinkConsumed;
    }).sum;
  }

  double _rateOfChangeGastricEmptying(double alcoholInStomach, double dt) {
    final k1 = user.k1 * dt;
    return (k1 * alcoholInStomach) / (1 + stomachFullness.absorptionFactor * pow(alcoholInStomach, 2));
  }

  double _rateOfChangeAbsorption(double alcoholInSmallIntestine, double dt) {
    final k2 = user.k2 * dt;
    return k2 * alcoholInSmallIntestine;
  }

  double _rateOfChangeForADHMetabolism(double previousBAC, double dt) {
    // TODO: Incorporate stomach fullness

    // vMax would be between 0.5 and 2.5 g/L/h in a one-compartment model, kM would be between 0.02 and 0.1g/L
    // However, we need to use the adapted values for the model by Pieters' here
    return (user.vMax * dt * previousBAC) / (user.kM + previousBAC);
  }
}
