import 'package:drimble/domain/alcohol/alcohol.dart';
import 'package:drimble/domain/diary/diary_entry.dart';
import 'package:drimble/domain/diary/stomach_fullness.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../generate_entities.dart';

void main() {
  group(DiaryEntry, () {
    test('should throw an assertion when creating a DiaryEntry with drinks and no stomach fullness', () {
      expect(() => DiaryEntry(date: faker.date.date(), drinks: [generateConsumedDrink()]), throwsAssertionError);
    });

    group('drinks', () {
      test('should be empty by default', () {
        final diaryEntry = DiaryEntry(date: faker.date.date());
        expect(diaryEntry.drinks, []);
      });

      test('should be unmodifiable', () {
        final diaryEntry = DiaryEntry(date: faker.date.date());
        expect(() => diaryEntry.drinks.add(generateConsumedDrink()), throwsUnsupportedError);
      });

      test('should be the same as the drinks passed to the constructor', () {
        final drinks = [generateConsumedDrink(), generateConsumedDrink()];
        final diaryEntry = DiaryEntry(
          date: faker.date.date(),
          stomachFullness: StomachFullness.full,
          drinks: drinks,
        );
        expect(diaryEntry.drinks, drinks);
      });
    });

    group('isDrinkFreeDay', () {
      test('should be true if there are no drinks', () {
        final diaryEntry = DiaryEntry(date: faker.date.date());
        final result = diaryEntry.isDrinkFreeDay;
        expect(result, true);
      });

      test('should be false if there are drinks', () {
        final diaryEntry = DiaryEntry(
          date: faker.date.date(),
          stomachFullness: StomachFullness.litte,
          drinks: [generateConsumedDrink()],
        );
        final result = diaryEntry.isDrinkFreeDay;
        expect(result, false);
      });
    });

    group('gramsOfAlcohol', () {
      test('should be 0 if there are no drinks', () {
        final diaryEntry = DiaryEntry(date: faker.date.date());
        final result = diaryEntry.gramsOfAlcohol;
        expect(result, 0);
      });

      test('should be the sum of grams of alcohol of all drinks', () {
        final diaryEntry = generateDiaryEntry(drinks: [
          generateConsumedDrink(alcoholByVolume: 0.5, volume: 100),
          generateConsumedDrink(alcoholByVolume: 0.5, volume: 100),
        ]);
        final result = diaryEntry.gramsOfAlcohol;
        expect(result, 0.5 * 100.0 * 2.0 * Alcohol.density);
      });
    });

    group('calories', () {
      test('should be 0 if there are no drinks', () {
        final diaryEntry = generateDiaryEntry(drinks: []);
        final result = diaryEntry.calories;
        expect(result, 0);
      });

      test('should be the sum of calories of all drinks', () {
        final diaryEntry = generateDiaryEntry(drinks: [
          generateConsumedDrink(alcoholByVolume: 0.5, volume: 100),
          generateConsumedDrink(alcoholByVolume: 0.5, volume: 100),
        ]);
        final result = diaryEntry.calories;
        expect(result, 0.5 * 100.0 * 2.0 * Alcohol.density * Alcohol.caloriesPerGramOfAlcohol);
      }, skip: 'Weird rounding error');
    });

    group('addDrink', () {
      test('should add the drink to the drinks list', () {
        final diaryEntry = generateDiaryEntry(stomachFullness: StomachFullness.full);
        final drink = generateConsumedDrink();
        final updatedDiaryEntry = diaryEntry.addDrink(drink);
        expect(updatedDiaryEntry.drinks, [drink]);
      });

      test('should throw an assertion if the drink is already in the drinks list', () {
        final consumedDrink = generateConsumedDrink();
        final diaryEntry = generateDiaryEntry(drinks: [consumedDrink]);
        expect(() => diaryEntry.addDrink(consumedDrink), throwsAssertionError);
      });
    });

    group('upsertDrink', () {
      test('should add the drink if it does not exist', () {
        final diaryEntry = generateDiaryEntry(stomachFullness: StomachFullness.full);
        final drink = generateConsumedDrink();
        final updatedDiaryEntry = diaryEntry.upsertDrink(drink.id, drink);
        expect(updatedDiaryEntry.drinks, [drink]);
      });

      test('should update the drink in the drinks list', () {
        final drink = generateConsumedDrink(volume: 100);
        final diaryEntry = generateDiaryEntry(drinks: [drink]);

        final updatedDrink = drink.copyWith(volume: 1000);

        final updatedDiaryEntry = diaryEntry.upsertDrink(drink.id, updatedDrink);
        expect(updatedDiaryEntry.drinks, [updatedDrink]);
      });
    });

    group('removeDrink', () {
      test('should remove the drink from the drinks list', () {
        final consumedDrink = generateConsumedDrink();
        final diaryEntry = generateDiaryEntry(drinks: [consumedDrink]);
        final updatedDiaryEntry = diaryEntry.removeDrink(consumedDrink.id);
        expect(updatedDiaryEntry.drinks, isEmpty);
      });
    });

    group('addGlassOfWater', () {
      test('should add a glass of water to the diary entry', () {
        final diaryEntry = generateDiaryEntry();
        final updatedDiaryEntry = diaryEntry.addGlassOfWater();
        expect(updatedDiaryEntry.glassesOfWater, diaryEntry.glassesOfWater + 1);
      });
    });

    group('removeGlassOfWater', () {
      test('should remove a glass of water from the diary entry', () {
        final diaryEntry = generateDiaryEntry(glassesOfWater: 1);
        final updatedDiaryEntry = diaryEntry.removeGlassOfWater();
        expect(updatedDiaryEntry.glassesOfWater, diaryEntry.glassesOfWater - 1);
      });

      test('should not remove a glass of water if there are 0 glasses', () {
        final diaryEntry = generateDiaryEntry(glassesOfWater: 0);
        final updatedDiaryEntry = diaryEntry.removeGlassOfWater();
        expect(updatedDiaryEntry.glassesOfWater, 0);
      });
    });

    group('setStomachFullness', () {
      test('should set the stomach fullness of the diary entry', () {
        final diaryEntry = generateDiaryEntry();
        final updatedDiaryEntry = diaryEntry.setStomachFullness(StomachFullness.full);
        expect(updatedDiaryEntry.stomachFullness, StomachFullness.full);
      });
    });
  });
}
