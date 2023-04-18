import 'package:drimble/data/daos/consumed_drinks_dao.dart';
import 'package:drimble/data/database_provider.dart';
import 'package:drimble/data/models/consumed_drink_model.dart';
import 'package:drimble/data/models/ingredient_model.dart';
import 'package:drimble/domain/diary/consumed_cocktail.dart';
import 'package:drimble/domain/diary/consumed_drink.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:realm/realm.dart';

import '../../generate_entities.dart';

void main() {
  group(ConsumedDrinksDAO, () {
    final realm = Realm(Configuration.inMemory([ConsumedDrinkModel.schema, IngredientModel.schema]));
    final databaseProvider = DatabaseProvider.initialized(realm);

    setUp(() {
      realm.write(() {
        realm.deleteAll<ConsumedDrinkModel>();
      });
    });

    tearDownAll(() {
      realm.close();
    });

    test('should allow saving and loading a drink', () {
      final drink = generateConsumedDrink();

      final dao = ConsumedDrinksDAO(databaseProvider);
      realm.write(() {
        dao.save(drink);
      });

      final result = dao.findOnDate(drink.date);
      expect(result.length, 1);
      expect(result.first, isA<ConsumedDrink>());
    });

    test('should allow saving and loading a cocktail', () {
      final cocktail = generateConsumedCocktail();

      final dao = ConsumedDrinksDAO(databaseProvider);
      realm.write(() {
        dao.save(cocktail);
      });

      final result = dao.findOnDate(cocktail.date);
      expect(result.length, 1);
      expect(result.first, isA<ConsumedCocktail>());

      final loadedCocktail = result.first;
      expect(loadedCocktail.alcoholByVolume, cocktail.alcoholByVolume);
    });

    test('should correctly instantiate drinks and cocktails', () {
      final date = faker.date.date();
      final drink = generateConsumedDrinkOnDate(date: date);
      final cocktail = generateConsumedCocktailOnDate(date: date);

      final dao = ConsumedDrinksDAO(databaseProvider);
      realm.write(() {
        dao.save(drink);
        dao.save(cocktail);
      });

      final result = dao.findOnDate(date);
      expect(result.length, 2);
      // TODO: Finalize
    });
  });
}
