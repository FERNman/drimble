import 'package:drimble/domain/diary/consumed_cocktail.dart';
import 'package:drimble/domain/diary/stomach_fullness.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../generate_entities.dart';

void main() {
  group(ConsumedCocktail, () {
    test('should correctly calculate the alcoholByVolume from the volume and the ingredients', () {
      const volume = 500;
      final volumePerIngredient = (volume / 4).floor();
      const abvPerIngredient = 0.5;

      final ingredients = [
        generateIngredient(volume: volumePerIngredient, alcoholByVolume: abvPerIngredient),
        generateIngredient(volume: volumePerIngredient, alcoholByVolume: abvPerIngredient),
      ];
      final consumedCocktail = ConsumedCocktail(
        id: 'id',
        name: 'name',
        iconPath: 'iconPath',
        volume: volume,
        ingredients: ingredients,
        startTime: DateTime.now(),
        duration: Duration.zero,
        stomachFullness: StomachFullness.empty,
      );

      final expectedAlcoholByVolume = volumePerIngredient / volume * abvPerIngredient * ingredients.length;
      expect(consumedCocktail.alcoholByVolume, expectedAlcoholByVolume);
    });

    group('FromCocktail', () {
      test('should initialize the id with null', () {
        final cocktail = generateCocktail();
        final startTime = faker.date.dateTime();
        final newCocktail = ConsumedCocktail.fromCocktail(cocktail, startTime: startTime);

        expect(newCocktail.id, isNull);
      });

      test('should copy all the properties', () {
        final cocktail = generateCocktail();
        final startTime = faker.date.dateTime();
        final newCocktail = ConsumedCocktail.fromCocktail(cocktail, startTime: startTime);

        expect(newCocktail.name, cocktail.name);
        expect(newCocktail.iconPath, cocktail.iconPath);
        expect(newCocktail.ingredients, cocktail.ingredients);
        expect(newCocktail.startTime, startTime);
        expect(newCocktail.volume, cocktail.defaultServings.first);
        expect(newCocktail.duration, cocktail.defaultDuration);
        expect(newCocktail.stomachFullness, StomachFullness.empty);
      });
    });
  });
}
