import '../diary/consumed_drink.dart';
import '../diary/stomach_fullness.dart';
import 'drink_category.dart';

abstract class Drinks {
  static final beer = _drinkFromCategory(DrinkCategory.beer, name: 'Beer', icon: 'assets/icons/beer_small.png');
  static final ale = _drinkFromCategory(DrinkCategory.beer, name: 'Ale', icon: 'assets/icons/ale.png');
  static final cider = _drinkFromCategory(DrinkCategory.beer, name: 'Cider', icon: 'assets/icons/cider.png');

  static final whiteWine = _drinkFromCategory(
    DrinkCategory.wine,
    name: 'White Wine',
    icon: 'assets/icons/white_wine.png',
  );

  static final redWine = _drinkFromCategory(
    DrinkCategory.wine,
    name: 'Red Wine',
    icon: 'assets/icons/red_wine.png',
  );

  static final champagne = _drinkFromCategory(
    DrinkCategory.champagne,
    name: 'Champagne',
    icon: 'assets/icons/champagne.png',
  );

  static final whisky = _drinkFromCategory(DrinkCategory.spirit, name: 'Whisky', icon: 'assets/icons/whisky.png');

  static final rum = _drinkFromCategory(DrinkCategory.spirit, name: 'Rum', icon: 'assets/icons/rum.png');

  static final vodka = _drinkFromCategory(DrinkCategory.spirit, name: 'Vodka', icon: 'assets/icons/vodka.png');

  static ConsumedDrink _drinkFromCategory(DrinkCategory category, {required String name, required String icon}) =>
      ConsumedDrink(
        name: name,
        icon: icon,
        category: category,
        volume: category.defaultServings.first,
        alcoholByVolume: category.defaultABV,
        startTime: DateTime.now(),
        duration: category.defaultDuration,
        stomachFullness: StomachFullness.empty,
      );
}
