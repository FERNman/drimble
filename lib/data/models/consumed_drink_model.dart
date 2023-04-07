import 'package:realm/realm.dart';

import '../../domain/alcohol/alcohol.dart';

part 'consumed_drink_model.g.dart';

@RealmModel(ObjectType.embeddedObject)
class _IngredientModel {
  late String name;
  late String iconPath;
  late String category;
  late Milliliter volume;
  late Percentage alcoholByVolume;
}

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
  late List<_IngredientModel> ingredients;

  /// Must be either "ConsumedDrinkModel" or "ConsumedCocktailModel". 
  /// Used as a placeholder for inheritance.
  late String classType;
}
