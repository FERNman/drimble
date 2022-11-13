import 'package:drimble/domain/alcohol/drink_category.dart';
import 'package:drimble/domain/diary/drink.dart';
import 'package:drimble/domain/diary/stomach_fullness.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConsumedDrink', () {
    group('fromExistingDrink', () {
      final existingDrink = Drink(
        id: 19,
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
        id: 19,
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
  });
}
