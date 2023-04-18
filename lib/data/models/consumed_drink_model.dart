import 'package:realm/realm.dart';

import '../../domain/alcohol/alcohol.dart';
import '../../domain/alcohol/drink_category.dart';
import '../../domain/diary/consumed_cocktail.dart';
import '../../domain/diary/consumed_drink.dart';
import '../../domain/diary/stomach_fullness.dart';
import 'ingredient_model.dart';

part 'consumed_drink_model.g.dart';

@RealmModel()
class _ConsumedDrinkModel {
  @PrimaryKey()
  late String id;
  late String name;
  late String iconPath;
  late String category;
  late Milliliter volume;
  late Percentage alcoholByVolume;
  late DateTime startTime;
  late String timezone;
  late int duration;
  late String stomachFullness;

  /// Must not be empty if this is a cocktail, must be empty if it's a drink.
  late List<$IngredientModel> ingredients;

  /// Must be either "ConsumedDrinkModel" or "ConsumedCocktailModel".
  /// Used to model inheritance.
  late String classType;
}

extension ConsumedDrinkEntity on ConsumedDrink {
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
        ingredients: model.ingredients.map((e) => IngredientEntity.fromModel(e)).toList(),
      );
    }
  }
}
