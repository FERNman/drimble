import 'beverage.dart';

abstract class Beverages {
  static Beverage beer = const Beverage(
    name: 'Beer',
    icon: 'assets/icons/beer_small.png',
    standardServings: [330, 500],
    defaultABV: 0.05,
    defaultDuration: Duration(minutes: 30),
  );

  static Beverage ale = const Beverage(
    name: 'Ale',
    icon: 'assets/icons/ale.png',
    standardServings: [330, 500],
    defaultABV: 0.05,
    defaultDuration: Duration(minutes: 30),
  );

  static Beverage cider = const Beverage(
    name: 'Cider',
    icon: 'assets/icons/cider.png',
    standardServings: [330, 500],
    defaultABV: 0.05,
    defaultDuration: Duration(minutes: 30),
  );

  static Beverage whiteWine = const Beverage(
    name: 'White Wine',
    icon: 'assets/icons/white_wine.png',
    standardServings: [125, 250],
    defaultABV: 0.12,
    defaultDuration: Duration(minutes: 20),
  );

  static Beverage redWine = const Beverage(
    name: 'Red Wine',
    icon: 'assets/icons/red_wine.png',
    standardServings: [125, 250],
    defaultABV: 0.12,
    defaultDuration: Duration(minutes: 20),
  );

  static Beverage champagne = const Beverage(
    name: 'Champagne',
    icon: 'assets/icons/champagne.png',
    standardServings: [125, 250],
    defaultABV: 0.12,
    defaultDuration: Duration(minutes: 20),
  );

  static Beverage whisky = const Beverage(
    name: 'Whisky',
    icon: 'assets/icons/whisky.png',
    standardServings: [20, 40],
    defaultABV: 0.4,
    defaultDuration: Duration(minutes: 5),
  );

  static Beverage rum = const Beverage(
    name: 'Rum',
    icon: 'assets/icons/rum.png',
    standardServings: [20, 40],
    defaultABV: 0.4,
    defaultDuration: Duration(minutes: 5),
  );

  static Beverage vodka = const Beverage(
    name: 'Vodka',
    icon: 'assets/icons/vodka.png',
    standardServings: [20, 40],
    defaultABV: 0.4,
    defaultDuration: Duration(minutes: 5),
  );
}
