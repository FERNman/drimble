import 'package:realm/realm.dart';

import '../../domain/alcohol/drink_category.dart';
import '../../domain/alcohol/ingredient.dart';
import '../../domain/date.dart';
import '../../domain/diary/consumed_cocktail.dart';
import '../../domain/diary/consumed_drink.dart';
import '../../domain/diary/stomach_fullness.dart';
import '../models/consumed_drink_model.dart';
import 'dao.dart';

class ConsumedDrinksDAO extends DAO {
  ConsumedDrinksDAO(super.databaseProvider);

  void save(ConsumedDrink drink) {
    final entity = drink.toModel();
    databaseProvider.realm.add(entity, update: true);
  }

  void delete(ConsumedDrink drink) {
    final entity = databaseProvider.realm.find<ConsumedDrinkModel>(drink.id);
    if (entity != null) {
      databaseProvider.realm.delete(entity);
    }
  }

  void deleteOnDate(Date date) {
    final results = databaseProvider.realm.query<ConsumedDrinkModel>(
      'startTime BETWEEN {\$0, \$1}',
      [date.toDateTime(), date.add(days: 1).toDateTime()],
    );
    databaseProvider.realm.deleteMany(results);
  }

  List<ConsumedDrink> findOnDate(Date date) {
    return databaseProvider.realm
        .query<ConsumedDrinkModel>(
          'startTime BETWEEN {\$0, \$1} SORT(startTime DESC)',
          [date.toDateTime(), date.add(days: 1).toDateTime()],
        )
        .map((e) => _Entity.fromModel(e))
        .toList();
  }

  Stream<List<ConsumedDrink>> observeOnDate(Date date) {
    return databaseProvider.realm
        .query<ConsumedDrinkModel>(
          'startTime BETWEEN {\$0, \$1} SORT(startTime DESC)',
          [date.toDateTime(), date.add(days: 1).toDateTime()],
        )
        .changes
        .map((event) => event.results.map((e) => _Entity.fromModel(e)).toList());
  }

  Stream<List<ConsumedDrink>> observeBetweenDates(Date startDate, Date endDate) {
    return databaseProvider.realm
        .query<ConsumedDrinkModel>(
          'startTime BETWEEN {\$0, \$1} SORT(startTime DESC)',
          [startDate.toDateTime(), endDate.toDateTime()],
        )
        .changes
        .map((event) => event.results.map((e) => _Entity.fromModel(e)).toList());
  }

  Stream<List<ConsumedDrink>> observeLatest() {
    return databaseProvider.realm
        .query<ConsumedDrinkModel>('TRUEPREDICATE SORT(startTime DESC) LIMIT(3)')
        .changes
        .map((event) => event.results.map((e) => _Entity.fromModel(e)).toList());
  }
}

extension _Entity on ConsumedDrink {
  static const _consumedDrinkClassType = 'ConsumedDrink';
  static const _consumedCocktailClassType = 'ConsumedCocktail';

  ConsumedDrinkModel toModel() => ConsumedDrinkModel(
        id ?? ObjectId().hexString,
        name,
        iconPath,
        category.name,
        volume,
        alcoholByVolume,
        startTime,
        startTime.timeZoneName,
        duration.inMilliseconds,
        stomachFullness.name,
        this is ConsumedCocktail ? _consumedCocktailClassType : _consumedDrinkClassType,
        ingredients: this is ConsumedCocktail ? (this as ConsumedCocktail).ingredients.map((e) => e.toModel()) : [],
      );

  static ConsumedDrink fromModel(ConsumedDrinkModel model) {
    if (model.classType == _consumedDrinkClassType) {
      return ConsumedDrink(
        id: model.id,
        name: model.name,
        iconPath: model.iconPath,
        category: DrinkCategory.values.firstWhere((e) => e.name == model.category),
        volume: model.volume,
        alcoholByVolume: model.alcoholByVolume,
        startTime: model.startTime.toLocal(),
        duration: Duration(milliseconds: model.duration),
        stomachFullness: StomachFullness.values.firstWhere((e) => e.name == model.stomachFullness),
      );
    } else {
      return ConsumedCocktail(
        id: model.id,
        name: model.name,
        iconPath: model.iconPath,
        volume: model.volume,
        startTime: model.startTime.toLocal(),
        duration: Duration(milliseconds: model.duration),
        stomachFullness: StomachFullness.values.firstWhere((e) => e.name == model.stomachFullness),
        ingredients: model.ingredients.map((e) => _IngredientEntity.fromModel(e)).toList(),
      );
    }
  }
}

extension _IngredientEntity on Ingredient {
  IngredientModel toModel() => IngredientModel(
        name,
        iconPath,
        category.name,
        volume,
        alcoholByVolume,
      );

  static Ingredient fromModel(IngredientModel model) => Ingredient(
        name: model.name,
        iconPath: model.iconPath,
        category: DrinkCategory.values.firstWhere((e) => e.name == model.category),
        volume: model.volume,
        alcoholByVolume: model.alcoholByVolume,
      );
}
