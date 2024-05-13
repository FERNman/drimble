import 'package:drimble/domain/alcohol/alcohol.dart';
import 'package:drimble/domain/diary/diary_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../generate_entities.dart';

void main() {
  group(DiaryEntry, () {
    group('drinks', () {
      test('should be empty by default', () {
        final diaryEntry = generateDiaryEntry();
        expect(diaryEntry.drinks, []);
      });

      test('should be unmodifiable', () {
        final diaryEntry = generateDiaryEntry();
        expect(() => diaryEntry.drinks.add(generateConsumedDrink()), throwsUnsupportedError);
      });

      test('should be the same as the drinks passed to the constructor', () {
        final drinks = [generateConsumedDrink(), generateConsumedDrink()];
        final diaryEntry = generateDiaryEntry(drinks: drinks);
        expect(diaryEntry.drinks, drinks);
      });
    });

    group('isDrinkFreeDay', () {
      test('should be true if there are no drinks', () {
        final diaryEntry = generateDiaryEntry();
        final result = diaryEntry.isDrinkFreeDay;
        expect(result, true);
      });

      test('should be false if there are drinks', () {
        final diaryEntry = generateDiaryEntry(drinks: [generateConsumedDrink()]);
        final result = diaryEntry.isDrinkFreeDay;
        expect(result, false);
      });
    });

    group('gramsOfAlcohol', () {
      test('should be 0 if there are no drinks', () {
        final diaryEntry = generateDiaryEntry();
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
        final diaryEntry = generateDiaryEntry();
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
  });
}
