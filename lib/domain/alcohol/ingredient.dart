import 'alcohol.dart';

class Ingredient {
  final String name;
  final String iconPath;
  final Percentage alcoholByVolume;
  final Percentage percentOfCocktailVolume;

  const Ingredient({
    required this.name,
    required this.iconPath,
    required this.alcoholByVolume,
    required this.percentOfCocktailVolume,
  });

  Milliliter actualVolume(Milliliter cocktailVolume) {
    return (cocktailVolume * percentOfCocktailVolume).round();
  }
}
