import 'package:drimble/domain/alcohol/drink_category.dart';
import 'package:drimble/domain/date.dart';
import 'package:drimble/domain/diary/drink.dart';
import 'package:drimble/domain/diary/stomach_fullness.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:realm/realm.dart';

void main() {
  group(Drink, () {
    group('fromExistingDrink', () {
      final existingDrink = Drink(
        id: ObjectId().hexString,
        name: 'Beer',
        icon: 'test',
        category: DrinkCategory.beer,
        volume: 500,
        alcoholByVolume: 0.05,
        startTime: DateTime(2020),
        duration: const Duration(hours: 1),
        stomachFullness: StomachFullness.full,
      );

      test('should not copy the id', () {
        final drink = Drink.fromExistingDrink(existingDrink, startTime: DateTime(1999));
        expect(drink.id, null);
      });
    });

    group('copyWith', () {
      final drink = Drink(
        id: ObjectId().hexString,
        name: 'Beer',
        icon: 'test',
        category: DrinkCategory.beer,
        volume: 500,
        alcoholByVolume: 0.05,
        startTime: DateTime(2020),
        duration: const Duration(hours: 1),
        stomachFullness: StomachFullness.full,
      );

      test('should also copy the id', () {
        expect(drink.copyWith().id, drink.id);
      });
    });

    group('date', () {
      test('should be shifted by 1 day if the startTime is before 6am', () {
        final drink = Drink(
          id: ObjectId().hexString,
          name: 'Beer',
          icon: 'test',
          category: DrinkCategory.beer,
          volume: 500,
          alcoholByVolume: 0.05,
          startTime: DateTime(2020, 1, 1, 5, 59),
          duration: const Duration(hours: 1),
          stomachFullness: StomachFullness.full,
        );
        expect(drink.date, const Date(2019, 12, 31));
      });

      test('should not be shifted if the startTime is after 6am', () {
        final drink = Drink(
          id: ObjectId().hexString,
          name: 'Beer',
          icon: 'test',
          category: DrinkCategory.beer,
          volume: 500,
          alcoholByVolume: 0.05,
          startTime: DateTime(2020, 1, 1, 6, 0),
          duration: const Duration(hours: 1),
          stomachFullness: StomachFullness.full,
        );

        expect(drink.date, const Date(2020, 1, 1));
      });
    });
  });
}
