import 'beverage.dart';

abstract class Beverages {
  static Beverage beer = const Beverage(
    name: 'Beer',
    icon: 'icons/beer_small.png',
    standardServings: [330, 500],
    defaultABV: 0.05,
    defaultDuration: Duration(minutes: 30),
  );

  static Beverage ale = const Beverage(
    name: 'Ale',
    icon: 'icons/ale.png',
    standardServings: [330, 500],
    defaultABV: 0.05,
    defaultDuration: Duration(minutes: 30),
  );

  static Beverage cider = const Beverage(
    name: 'Cider',
    icon: 'icons/cider.png',
    standardServings: [330, 500],
    defaultABV: 0.05,
    defaultDuration: Duration(minutes: 30),
  );

  static Beverage whiteWine = const Beverage(
    name: 'White Wine',
    icon: 'icons/white_wine.png',
    standardServings: [125, 250],
    defaultABV: 0.12,
    defaultDuration: Duration(minutes: 20),
  );

  static Beverage redWine = const Beverage(
    name: 'Red Wine',
    icon: 'icons/red_wine.png',
    standardServings: [125, 250],
    defaultABV: 0.12,
    defaultDuration: Duration(minutes: 20),
  );

  static Beverage champagne = const Beverage(
    name: 'Champagne',
    icon: 'icons/champagne.png',
    standardServings: [125, 250],
    defaultABV: 0.12,
    defaultDuration: Duration(minutes: 20),
  );

  static Beverage whisky = const Beverage(
    name: 'Whisky',
    icon: 'icons/whisky.png',
    standardServings: [20, 40],
    defaultABV: 0.12,
    defaultDuration: Duration(minutes: 5),
  );

  static Beverage rum = const Beverage(
    name: 'Rum',
    icon: 'icons/rum.png',
    standardServings: [20, 40],
    defaultABV: 0.12,
    defaultDuration: Duration(minutes: 5),
  );

  static Beverage vodka = const Beverage(
    name: 'Vodka',
    icon: 'icons/vodka.png',
    standardServings: [20, 40],
    defaultABV: 0.12,
    defaultDuration: Duration(minutes: 5),
  );
}
