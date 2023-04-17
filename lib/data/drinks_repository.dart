import '../domain/alcohol/drink_category.dart';
import '../domain/alcohol/ingredient.dart';
import '../domain/diary/consumed_cocktail.dart';
import '../domain/diary/consumed_drink.dart';
import '../domain/diary/stomach_fullness.dart';

class DrinksRepository {
  DrinksRepository();

  Stream<List<ConsumedDrink>> observeCommonDrinks() => Stream.value([
        _beer,
        _ale,
        _cider,
        _whiteWine,
        _redWine,
        _champagne,
        _whisky,
        _rum,
        _aperol,
      ]);

  static final _beer = _drinkFromCategory(DrinkCategory.beer, name: 'Beer', icon: 'assets/icons/beer_small.png');
  static final _ale = _drinkFromCategory(DrinkCategory.beer, name: 'Ale', icon: 'assets/icons/ale.png');
  static final _cider = _drinkFromCategory(DrinkCategory.beer, name: 'Cider', icon: 'assets/icons/cider.png');

  static final _whiteWine = _drinkFromCategory(
    DrinkCategory.wine,
    name: 'White Wine',
    icon: 'assets/icons/white_wine.png',
  );

  static final _redWine = _drinkFromCategory(
    DrinkCategory.wine,
    name: 'Red Wine',
    icon: 'assets/icons/red_wine.png',
  );

  static final _champagne = _drinkFromCategory(
    DrinkCategory.champagne,
    name: 'Champagne',
    icon: 'assets/icons/champagne.png',
  );

  static final _whisky = _drinkFromCategory(DrinkCategory.spirit, name: 'Whisky', icon: 'assets/icons/whisky.png');

  static final _rum = _drinkFromCategory(DrinkCategory.spirit, name: 'Rum', icon: 'assets/icons/rum.png');

  static final _vodka = _drinkFromCategory(DrinkCategory.spirit, name: 'Vodka', icon: 'assets/icons/vodka.png');

  static final _aperol = ConsumedCocktail(
    name: 'Aperol Spritz',
    iconPath: 'assets/icons/aperol.png',
    volume: DrinkCategory.cocktail.defaultServings.first,
    startTime: DateTime.now(),
    duration: DrinkCategory.cocktail.defaultDuration,
    stomachFullness: StomachFullness.empty,
    ingredients: const [
      Ingredient(
        name: 'Aperol',
        category: DrinkCategory.liqueur,
        iconPath: 'assets/icons/aperol.png',
        volume: 25,
        alcoholByVolume: 0.11,
      ),
      Ingredient(
        name: 'Prosecco',
        category: DrinkCategory.champagne,
        iconPath: 'assets/icons/champagne_bottle.png',
        volume: 50,
        alcoholByVolume: 0.11,
      ),
    ],
  );

  static ConsumedDrink _drinkFromCategory(DrinkCategory category, {required String name, required String icon}) =>
      ConsumedDrink(
        name: name,
        iconPath: icon,
        category: category,
        volume: category.defaultServings.first,
        alcoholByVolume: category.defaultABV,
        startTime: DateTime.now(),
        duration: category.defaultDuration,
        stomachFullness: StomachFullness.empty,
      );
}
