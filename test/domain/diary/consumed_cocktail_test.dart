import 'package:collection/collection.dart';
import 'package:drimble/domain/diary/consumed_cocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../generate_entities.dart';

void main() {
  group(ConsumedCocktail, () {
    test('should correctly calculate the alcoholByVolume from the ingredients', () {
      const volume = 500;
      const percentPerIngredient = 0.25;
      const abvPerIngredient = 0.5;

      final ingredients = [
        generateIngredient(percentOfCocktailVolume: percentPerIngredient, alcoholByVolume: abvPerIngredient),
        generateIngredient(percentOfCocktailVolume: percentPerIngredient, alcoholByVolume: abvPerIngredient),
      ];
      final consumedCocktail = generateConsumedCocktail(volume: volume, ingredients: ingredients);

      final expectedAlcoholByVolume = percentPerIngredient * abvPerIngredient * ingredients.length;
      expect(consumedCocktail.alcoholByVolume, expectedAlcoholByVolume);
    });

    test('should correclty calculate the alcoholByVolume even if the volume is 0', () {
      const volume = 0;
      final ingredients = [
        generateIngredient(percentOfCocktailVolume: 0.25, alcoholByVolume: 0.5),
        generateIngredient(percentOfCocktailVolume: 0.5, alcoholByVolume: 0.5),
      ];
      final consumedCocktail = generateConsumedCocktail(volume: volume, ingredients: ingredients);

      final expectedAlcoholByVolume = ingredients.map((e) => e.alcoholByVolume * e.percentOfCocktailVolume).sum;
      expect(consumedCocktail.alcoholByVolume, expectedAlcoholByVolume);
    });

    group('copyWith', () {
      final drink = generateConsumedCocktail(
        id: faker.guid.guid(),
      );

      test('should also copy the id', () {
        expect(drink.copyWith().id, drink.id);
      });
    });
  });
}
