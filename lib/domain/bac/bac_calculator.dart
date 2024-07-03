import 'dart:math';

import 'package:collection/collection.dart';

import '../alcohol/alcohol.dart';
import '../diary/consumed_drink.dart';
import '../diary/diary_entry.dart';
import '../diary/stomach_fullness.dart';
import '../user/user.dart';
import 'bac_constants.dart';
import 'bac_entry.dart';
import 'bac_time_series.dart';

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
  static const timestep = Duration(minutes: 5);

  final User _user;
  final List<ConsumedDrink> _drinks;
  final StomachFullness _stomachFullness;

  final DateTime _startTime;
  final DateTime _endTime;

  BACCalculator._(this._user, this._drinks, this._stomachFullness)
      : _startTime = _drinks.map((e) => e.startTime).min,
        _endTime = _drinks
            .map((e) => e.endTime)
            .max
            .add(const Duration(minutes: 30)); // add 30 minutes to make sure also the last drink is absorbed

  static BACTimeSeries calculate(User user, DiaryEntry diaryEntry) {
    if (diaryEntry.isDrinkFreeDay) {
      return BACTimeSeries.empty(diaryEntry.date.toDateTime());
    }

    return BACCalculator._(user, diaryEntry.drinks, diaryEntry.stomachFullness!)._run();
  }

  BACTimeSeries _run() {
    var alcoholInStomach = 0.0;
    var alcoholInSmallIntestine = 0.0;
    var alcoholInCentralCompartment = 0.0;

    final deltaTime = (1 / 60) * timestep.inMinutes;

    final results = <BACEntry>[];
    for (var time = _startTime;
        time.isBefore(_endTime) || alcoholInCentralCompartment / 10.0 >= Alcohol.soberLimit;
        time = time.add(timestep)) {
      // Step 0: Calculate the amount of ingested alcohol in grams per liter of the total body water
      final ingestedAlcohol = _calculateIngestedAlcohol(time, time.add(timestep)) / _user.volumeOfDistribution;

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

    return BACTimeSeries(results);
  }

  double _calculateIngestedAlcohol(DateTime from, DateTime until) {
    return _drinks.where((drink) => drink.startTime.isBefore(until) && drink.endTime.isAfter(from)).map((drink) {
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
    final k1 = _user.k1 * dt;
    return (k1 * alcoholInStomach) / (1 + _stomachFullness.absorptionFactor * pow(alcoholInStomach, 2));
  }

  double _rateOfChangeAbsorption(double alcoholInSmallIntestine, double dt) {
    final k2 = _user.k2 * dt;
    return k2 * alcoholInSmallIntestine;
  }

  double _rateOfChangeForADHMetabolism(double previousBAC, double dt) {
    // TODO: Incorporate stomach fullness

    // vMax would be between 0.5 and 2.5 g/L/h in a one-compartment model, kM would be between 0.02 and 0.1g/L
    // However, we need to use the adapted values for the model by Pieters' here
    return (_user.vMax * dt * previousBAC) / (_user.kM + previousBAC);
  }
}
