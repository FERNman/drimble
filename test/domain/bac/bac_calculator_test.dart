import 'package:drimble/domain/alcohol/alcohol.dart';
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
      final calculator = BACCalculator(user);

      final wine = generateConsumedDrink(
        volume: 150,
        alcoholByVolume: 0.12,
        startTime: startTime,
        duration: const Duration(minutes: 1),
      );

      final results = calculator.calculate(generateDiaryEntry(drinks: [wine]));
      expect(results.maxBAC.value, greaterThan(0.015));
    });

    test('should run the calculation over all given drinks even if the BAC returns to 0 in between', () {
      final user = generateUser(gender: Gender.male, height: 180, weight: 80);
      final calculator = BACCalculator(user);

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

      final results = calculator.calculate(generateDiaryEntry(drinks: [beer, wine]));
      expect(results.maxBAC.time.isAfter(wine.startTime), true);
    });

    group('BAC', () {
      group(StomachFullness.empty, () {
        // A standard drink defined as 14g of pure alcohol (USA)
        // If not otherwise specificed, values are taken from https://en.wikipedia.org/wiki/Blood_alcohol_content#By_standard_drinks
        final standardDrink = generateConsumedDrink(
          volume: 354,
          alcoholByVolume: 0.05,
          startTime: startTime,
          duration: const Duration(minutes: 20),
        );

        group(Gender.male, () {
          final user = generateUser(gender: Gender.male, age: 30, height: 180, weight: 80);
          final calculator = BACCalculator(user);

          test('should correctly estimate the BAC for one standard drink', () {
            final results = calculator.calculate(generateDiaryEntry(drinks: [standardDrink]));
            expect(results.maxBAC.value, closeTo(0.022, 0.001));
          });

          test('should correctly estimate the BAC for three standard drinks', () {
            final results = calculator.calculate(generateDiaryEntry(
              drinks: [standardDrink, standardDrink, standardDrink],
            ));
            expect(results.maxBAC.value, closeTo(0.074, 0.002));
          });

          group('Mitchell et al (2014)', () {
            // Taken from Mitchell et al. (2014) (https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4112772/)
            // 0.5g/kg alcohol consumed by 15 healthy men in 3 different runs (vodka, wine, beer)

            test('should approximate the data for vodka', () {
              const alcoholByVolume = 0.2;
              final volume = 0.5 * user.weight / (alcoholByVolume * Alcohol.density);
              final vodka = generateConsumedDrink(
                volume: volume.round(),
                alcoholByVolume: alcoholByVolume,
                startTime: startTime,
                duration: const Duration(minutes: 20),
              );

              final results = calculator.calculate(generateDiaryEntry(drinks: [vodka]));
              expect(results.maxBAC.value, closeTo(0.077, 0.005));

              // Observed peak BAC after 37 minutes
              final actualPeakBAC = results.maxBAC.time;
              final expectedPeakBAC = vodka.startTime.add(const Duration(minutes: 37));
              const delta = Duration(minutes: 5);
              expect(actualPeakBAC.millisecond, closeTo(expectedPeakBAC.millisecond, delta.inMilliseconds));
            });

            test('should approximate the data for wine', () {
              const alcoholByVolume = 0.125;
              final volume = 0.5 * user.weight / (alcoholByVolume * Alcohol.density);
              final wine = generateConsumedDrink(
                volume: volume.round(),
                alcoholByVolume: alcoholByVolume,
                startTime: startTime,
                duration: const Duration(minutes: 20),
              );

              final results = calculator.calculate(generateDiaryEntry(drinks: [wine]));
              expect(results.maxBAC.value, closeTo(0.0617, 0.005));

              // Observed peak BAC after 54 minutes
              final actualPeakBAC = results.maxBAC.time;
              final expectedPeakBAC = wine.startTime.add(const Duration(minutes: 54));
              const delta = Duration(minutes: 5);
              expect(actualPeakBAC.millisecond, closeTo(expectedPeakBAC.millisecond, delta.inMilliseconds));
            });

            test('should approximate the data for beer', () {
              const alcoholByVolume = 0.51;
              final volume = 0.5 * user.weight / (alcoholByVolume * Alcohol.density);
              final beer = generateConsumedDrink(
                volume: volume.round(),
                alcoholByVolume: alcoholByVolume,
                startTime: startTime,
                duration: const Duration(minutes: 20),
              );

              final results = calculator.calculate(generateDiaryEntry(drinks: [beer]));
              expect(results.maxBAC.value, closeTo(0.0503, 0.005));

              // Observed peak BAC after 62 minutes
              final actualPeakBAC = results.maxBAC.time;
              final expectedPeakBAC = beer.startTime.add(const Duration(minutes: 62));
              const delta = Duration(minutes: 5);
              expect(actualPeakBAC.millisecond, closeTo(expectedPeakBAC.millisecond, delta.inMilliseconds));
            });
          }, skip: 'TODO');

          test('should approximate the data from Jones et al (1994)', () {
            // Taken from Jones et al. (1994) (https://pubmed.ncbi.nlm.nih.gov/8064267/)
            // 0.8g/kg alcohol consumed by 10 healthy men after an overnight fast
            const alcoholByVolume = 0.4;
            final volume = 0.8 * user.weight / (alcoholByVolume * Alcohol.density);
            final vodka = generateConsumedDrink(
              volume: volume.round(),
              alcoholByVolume: alcoholByVolume,
              startTime: startTime,
              duration: const Duration(minutes: 20),
            );

            final results = calculator.calculate(generateDiaryEntry(drinks: [vodka]));
            expect(results.maxBAC.value, closeTo(0.104, 0.015));
          });

          test('should approximate the data from Jones (1984)', () {
            // Taken from Jones (1984) (https://pubmed.ncbi.nlm.nih.gov/6537224/)
            // 0.68g/kg alcohol consumed
            const alcoholByVolume = 0.4;
            final volume = 0.8 * user.weight / (alcoholByVolume * Alcohol.density);
            final vodka = generateConsumedDrink(
              volume: volume.round(),
              alcoholByVolume: alcoholByVolume,
              startTime: startTime,
              duration: const Duration(minutes: 20),
            );

            final results = calculator.calculate(generateDiaryEntry(drinks: [vodka]));
            expect(results.maxBAC.value, closeTo(0.104, 0.015));
          });
        });

        group(Gender.female, () {
          final user = generateUser(gender: Gender.female, age: 20, height: 165, weight: 64);
          final calculator = BACCalculator(user);

          test('should correctly estimate the BAC for one standard drink', () {
            final results = calculator.calculate(generateDiaryEntry(drinks: [standardDrink]));
            expect(results.maxBAC.value, closeTo(0.031, 0.001));
          });

          test('should correctly estimate the BAC for three standard drinks', () {
            final results = calculator.calculate(generateDiaryEntry(
              drinks: [standardDrink, standardDrink, standardDrink],
            ));
            expect(results.maxBAC.value, closeTo(0.107, 0.001));
          });
        });
      });

      group(StomachFullness.normal, () {}, skip: 'TODO');

      group(StomachFullness.full, () {}, skip: 'TODO');
    });
  });
}
