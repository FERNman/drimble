import 'alcohol.dart';

enum DrinkCategory {
  beer,
  wine,
  champagne,
  fortifiedWine,
  spirit,
  liqueur,
  cocktail;

  List<Milliliter> get defaultServings {
    switch (this) {
      case DrinkCategory.beer:
        return [330, 500];
      case DrinkCategory.wine:
      case DrinkCategory.fortifiedWine:
        return [125, 250];
      case DrinkCategory.champagne:
        return [150, 200];
      case DrinkCategory.spirit:
      case DrinkCategory.liqueur:
        return [20, 40];
      case DrinkCategory.cocktail:
        return [125, 250];
    }
  }

  Percentage get defaultABV {
    switch (this) {
      case DrinkCategory.beer:
        return 0.05;
      case DrinkCategory.wine:
      case DrinkCategory.champagne:
        return 0.12;
      case DrinkCategory.fortifiedWine:
        return 0.18;
      case DrinkCategory.spirit:
        return 0.4;
      case DrinkCategory.liqueur:
        return 0.15;
      case DrinkCategory.cocktail:
        return 0.1;
    }
  }

  Duration get defaultDuration {
    switch (this) {
      case DrinkCategory.beer:
        return const Duration(minutes: 30);
      case DrinkCategory.wine:
        return const Duration(minutes: 30);
      case DrinkCategory.champagne:
        return const Duration(minutes: 30);
      case DrinkCategory.fortifiedWine:
        return const Duration(minutes: 30);
      case DrinkCategory.spirit:
        return const Duration(minutes: 5);
      case DrinkCategory.liqueur:
        return const Duration(minutes: 5);
      case DrinkCategory.cocktail:
        return const Duration(minutes: 30);
    }
  }
}
