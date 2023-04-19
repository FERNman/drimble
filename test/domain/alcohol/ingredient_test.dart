import 'package:drimble/domain/alcohol/ingredient.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../generate_entities.dart';

void main() {
  group(Ingredient, () {
    group('actualVolume', () {
      test('should correctly scale the volume according to the given volume of the cocktail', () {
        final ingredient = generateIngredient();
        final cocktailVolume = faker.randomGenerator.integer(500);

        final ingredientVolume = ingredient.actualVolume(cocktailVolume);
        expect(ingredientVolume, (cocktailVolume * ingredient.percentOfCocktailVolume).round());
      });
    });
  });
}
