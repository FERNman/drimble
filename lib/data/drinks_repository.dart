import '../domain/alcohol/cocktail.dart';
import '../domain/alcohol/drink.dart';
import '../domain/alcohol/drink_category.dart';
import '../domain/alcohol/ingredient.dart';

class DrinksRepository {
  DrinksRepository();

  List<Drink> getCommonDrinks() => _drinks;

  /// Returns all drinks that contain the given [name] in their name.
  List<Drink> searchDrinksByName(String name) {
    return _drinks.where((element) => element.name.toLowerCase().contains(name.toLowerCase())).toList();
  }

  /// Returns the drink with the given [name].
  Drink findDrinkByName(String name) {
    return _drinks.firstWhere((element) => element.name == name);
  }

  // Will be replaced by a database and/or server in the future
  static final _drinks = [
    Drink(
      name: 'Beer',
      iconPath: 'assets/icons/beer_small.png',
      category: DrinkCategory.beer,
      alcoholByVolume: 0.05,
      defaultServings: [330, 500],
      defaultDuration: const Duration(minutes: 15),
    ),
    Drink(
      name: 'Ale',
      iconPath: 'assets/icons/ale.png',
      category: DrinkCategory.beer,
      alcoholByVolume: 0.05,
      defaultServings: [330, 500],
      defaultDuration: const Duration(minutes: 15),
    ),
    Drink(
      name: 'Cider',
      iconPath: 'assets/icons/cider.png',
      category: DrinkCategory.cider,
      alcoholByVolume: 0.05,
      defaultServings: [330, 500],
      defaultDuration: const Duration(minutes: 15),
    ),
    Drink(
      name: 'White Wine',
      iconPath: 'assets/icons/white_wine.png',
      category: DrinkCategory.wine,
      alcoholByVolume: 0.12,
      defaultServings: [125, 250],
      defaultDuration: const Duration(minutes: 30),
    ),
    Drink(
      name: 'Red Wine',
      iconPath: 'assets/icons/red_wine.png',
      category: DrinkCategory.wine,
      alcoholByVolume: 0.12,
      defaultServings: [125, 250],
      defaultDuration: const Duration(minutes: 30),
    ),
    Drink(
      name: 'Champagne',
      iconPath: 'assets/icons/champagne.png',
      category: DrinkCategory.champagne,
      alcoholByVolume: 0.12,
      defaultServings: [150, 200],
      defaultDuration: const Duration(minutes: 30),
    ),
    Drink(
      name: 'Whisky',
      iconPath: 'assets/icons/whisky.png',
      category: DrinkCategory.spirit,
      alcoholByVolume: 0.4,
      defaultServings: [20, 40],
      defaultDuration: const Duration(minutes: 5),
    ),
    Drink(
      name: 'Rum',
      iconPath: 'assets/icons/rum.png',
      category: DrinkCategory.spirit,
      alcoholByVolume: 0.4,
      defaultServings: [20, 40],
      defaultDuration: const Duration(minutes: 5),
    ),
    Drink(
      name: 'Vodka',
      iconPath: 'assets/icons/vodka.png',
      category: DrinkCategory.spirit,
      alcoholByVolume: 0.4,
      defaultServings: [20, 40],
      defaultDuration: const Duration(minutes: 5),
    ),
    Cocktail(
      name: 'Aperol Spritz',
      iconPath: 'assets/icons/aperol.png',
      defaultServings: [150, 300],
      defaultDuration: const Duration(minutes: 10),
      ingredients: const [
        Ingredient(
          name: 'Aperol',
          iconPath: 'assets/icons/aperol.png',
          percentOfCocktailVolume: 0.25,
          alcoholByVolume: 0.11,
        ),
        Ingredient(
          name: 'Prosecco',
          iconPath: 'assets/icons/champagne_bottle.png',
          percentOfCocktailVolume: 0.5,
          alcoholByVolume: 0.11,
        ),
      ],
    ),
  ];
}
