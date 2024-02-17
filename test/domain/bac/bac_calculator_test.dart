import 'package:drimble/domain/bac/bac_calculator.dart';
import 'package:drimble/domain/diary/stomach_fullness.dart';
import 'package:drimble/domain/user/gender.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../generate_entities.dart';

void main() {
  group(BACCalculator, () {
    final startTime = faker.date.dateTime();

    test('should work if a drink was consumed in less time than a single simulation timestep (5 minutes)', () {
      final user = generateUser(gender: Gender.male, height: 180, weight: 80);
      final calculator = BACCalculator(user, StomachFullness.normal);

      final wine = generateConsumedDrink(
        volume: 150,
        alcoholByVolume: 0.12,
        startTime: startTime,
        duration: const Duration(minutes: 1),
      );

      final results = calculator.calculate([wine]);
      expect(results.maxBAC.value, greaterThan(0.015));
    });

    test('should run the calculation over all given drinks even if the BAC returns to 0 in between', () {
      final user = generateUser(gender: Gender.male, height: 180, weight: 80);
      final calculator = BACCalculator(user, StomachFullness.normal);

      final beer = generateConsumedDrink(
        volume: 10,
        alcoholByVolume: 0.01,
        startTime: startTime,
        duration: const Duration(minutes: 15),
      );

      final wine = generateConsumedDrink(
        volume: 150,
        alcoholByVolume: 0.12,
        startTime: startTime.add(const Duration(minutes: 120)),
        duration: const Duration(minutes: 30),
      );

      final results = calculator.calculate([beer, wine]);
      expect(results.maxBAC.time.isAfter(wine.startTime), true);
    });

    /// Values take from https://en.wikipedia.org/wiki/Blood_alcohol_content#By_standard_drinks
    group('BAC', () {
      group(StomachFullness.empty, () {
        group(Gender.male, () {
          final user = generateUser(gender: Gender.male, age: 20, height: 180, weight: 80);
          final calculator = BACCalculator(user, StomachFullness.empty);

          test('should correctly estimate the BAC for one standard drink', () {
            final beer = generateConsumedDrink(
              volume: 350,
              alcoholByVolume: 0.045,
              startTime: startTime,
              duration: const Duration(minutes: 20),
            );

            final results = calculator.calculate([beer]);
            expect(results.maxBAC.value, closeTo(0.02, 0.001));
          });

          test('should correctly estimate the BAC for three standard drinks', () {
            final beer = generateConsumedDrink(
              volume: 350,
              alcoholByVolume: 0.045,
              startTime: startTime,
              duration: const Duration(minutes: 20),
            );

            final results = calculator.calculate([beer, beer, beer]);
            expect(results.maxBAC.value, closeTo(0.061, 0.002));
          });
        });

        group(Gender.female, () {
          final user = generateUser(gender: Gender.female, age: 20, height: 165, weight: 64);
          final calculator = BACCalculator(user, StomachFullness.empty);

          test('should correctly estimate the BAC for one standard drink', () {
            final beer = generateConsumedDrink(
              volume: 350,
              alcoholByVolume: 0.045,
              startTime: startTime,
              duration: const Duration(minutes: 20),
            );

            final results = calculator.calculate([beer]);
            expect(results.maxBAC.value, closeTo(0.028, 0.001));
          });

          test('should correctly estimate the BAC for three standard drinks', () {
            final beer = generateConsumedDrink(
              volume: 350,
              alcoholByVolume: 0.045,
              startTime: startTime,
              duration: const Duration(minutes: 20),
            );

            final results = calculator.calculate([beer, beer, beer]);
            expect(results.maxBAC.value, closeTo(0.095, 0.002));
          });
        });
      });
    });
  });
}
