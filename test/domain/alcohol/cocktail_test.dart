import 'package:collection/collection.dart';
import 'package:drimble/domain/alcohol/cocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../generate_entities.dart';

void main() {
  group(Cocktail, () {
    test('should use the first default serving as the volume', () {
      final cocktail = generateCocktail();
      expect(cocktail.volume, cocktail.defaultServings.first);
    });

    test('should calculate the alcoholByVolume based on the ingredients', () {
      final ingredients = [
        generateIngredient(percentOfCocktailVolume: 0.5, alcoholByVolume: 0.5),
        generateIngredient(percentOfCocktailVolume: 0.25, alcoholByVolume: 0.5),
      ];
      final cocktail = generateCocktail(ingredients: ingredients);

      final expectedAlcoholByVolume = ingredients.map((e) => e.alcoholByVolume * e.percentOfCocktailVolume).sum;
      expect(cocktail.alcoholByVolume, expectedAlcoholByVolume);
    });
  });
}
