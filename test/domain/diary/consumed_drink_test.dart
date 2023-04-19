import 'package:drimble/domain/alcohol/drink_category.dart';
import 'package:drimble/domain/date.dart';
import 'package:drimble/domain/diary/consumed_cocktail.dart';
import 'package:drimble/domain/diary/consumed_drink.dart';
import 'package:drimble/domain/diary/stomach_fullness.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:realm/realm.dart';

import '../../generate_entities.dart';

void main() {
  group(ConsumedDrink, () {
    test('should use the first default serving as the volume', () {
      final drink = generateDrink();
      final startTime = faker.date.dateTime();
      final consumedDrink = ConsumedDrink.fromDrink(drink, startTime: startTime);

      expect(consumedDrink.volume, drink.defaultServings.first);
    });

    group('copyWith', () {
      final drink = ConsumedDrink(
        id: ObjectId().hexString,
        name: 'Beer',
        iconPath: 'test',
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
        final drink = ConsumedDrink(
          id: ObjectId().hexString,
          name: 'Beer',
          iconPath: 'test',
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
        final drink = ConsumedDrink(
          id: ObjectId().hexString,
          name: 'Beer',
          iconPath: 'test',
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

    group('FromDrink', () {
      test('should initialize the id with null', () {
        final drink = generateDrink();

        final startTime = faker.date.dateTime();
        final newDrink = ConsumedDrink.fromDrink(drink, startTime: startTime);

        expect(newDrink.id, isNull);
      });

      test('should copy all the properties', () {
        final drink = generateDrink();

        final startTime = faker.date.dateTime();
        final newDrink = ConsumedDrink.fromDrink(drink, startTime: startTime);

        expect(newDrink.name, drink.name);
        expect(newDrink.iconPath, drink.iconPath);
        expect(newDrink.category, drink.category);
        expect(newDrink.volume, drink.defaultServings.first);
        expect(newDrink.alcoholByVolume, drink.alcoholByVolume);
        expect(newDrink.startTime, startTime);
        expect(newDrink.duration, drink.defaultDuration);
      });

      test('should return a ConsumedCocktail if the given drink is a Cocktail', () {
        final drink = generateCocktail();

        final startTime = faker.date.dateTime();
        final newDrink = ConsumedDrink.fromDrink(drink, startTime: startTime);

        expect(newDrink, isA<ConsumedCocktail>());
      });
    });
  });
}
