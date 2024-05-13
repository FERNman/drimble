import 'package:drimble/domain/alcohol/drink_category.dart';
import 'package:drimble/domain/diary/consumed_cocktail.dart';
import 'package:drimble/domain/diary/consumed_drink.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../generate_entities.dart';

void main() {
  group(ConsumedDrink, () {
    test('should generate a UUID if no id is provided', () {
      final consumedDrink = ConsumedDrink(
        name: faker.lorem.word(),
        iconPath: faker.lorem.word(),
        category: faker.randomGenerator.element(DrinkCategory.values),
        volume: faker.randomGenerator.integer(100),
        alcoholByVolume: faker.randomGenerator.decimal(),
        startTime: faker.date.dateTime(),
        duration: Duration(minutes: faker.randomGenerator.integer(60, min: 1)),
      );

      expect(consumedDrink.id, isNotNull);
    });

    group('copyWith', () {
      final drink = generateConsumedDrink(
        id: faker.guid.guid(),
      );

      test('should also copy the id', () {
        expect(drink.copyWith().id, drink.id);
      });
    });

    group('FromDrink', () {
      test('should create an id', () {
        final drink = generateDrink();

        final startTime = faker.date.dateTime();
        final newDrink = ConsumedDrink.fromDrink(drink, startTime: startTime);

        expect(newDrink.id, isNotNull);
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

      test('should use the first default serving as the volume', () {
        final drink = generateDrink();
        final startTime = faker.date.dateTime();
        final consumedDrink = ConsumedDrink.fromDrink(drink, startTime: startTime);

        expect(consumedDrink.volume, drink.defaultServings.first);
      });

      test('should instantiate the consumed drink as a ConsumedDrink if the given drink is a Drink', () {
        final drink = generateDrink();
        final startTime = faker.date.dateTime();
        final newDrink = ConsumedDrink.fromDrink(drink, startTime: startTime);

        expect(newDrink, isA<ConsumedDrink>());
      });

      test('should instantiate the consumed drink as a ConsumedCocktail if the given drink is a Cocktail', () {
        final drink = generateCocktail();

        final startTime = faker.date.dateTime();
        final newDrink = ConsumedDrink.fromDrink(drink, startTime: startTime);

        expect(newDrink, isA<ConsumedCocktail>());
      });
    });
  });
}
