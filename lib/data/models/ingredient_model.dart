import 'package:realm/realm.dart';

import '../../domain/alcohol/alcohol.dart';
import '../../domain/alcohol/ingredient.dart';

part 'ingredient_model.g.dart';

@RealmModel(ObjectType.embeddedObject)
class $IngredientModel {
  late String name;
  late String iconPath;
  late Percentage percentOfCocktailVolume;
  late Percentage alcoholByVolume;
}

extension IngredientEntity on Ingredient {
  IngredientModel toModel() => IngredientModel(
        name,
        iconPath,
        percentOfCocktailVolume,
        alcoholByVolume,
      );

  static Ingredient fromModel(IngredientModel model) => Ingredient(
        name: model.name,
        iconPath: model.iconPath,
        percentOfCocktailVolume: model.percentOfCocktailVolume,
        alcoholByVolume: model.alcoholByVolume,
      );
}
