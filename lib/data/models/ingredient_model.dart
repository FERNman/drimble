import 'package:realm/realm.dart';

import '../../domain/alcohol/alcohol.dart';
import '../../domain/alcohol/drink_category.dart';
import '../../domain/alcohol/ingredient.dart';

part 'ingredient_model.g.dart';

@RealmModel(ObjectType.embeddedObject)
class $IngredientModel {
  late String name;
  late String iconPath;
  late String category;
  late Milliliter volume;
  late Percentage alcoholByVolume;
}

extension IngredientEntity on Ingredient {
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
