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

  factory Ingredient.fromFirestore(Map<String, dynamic> data) {
    return Ingredient(
      name: data['name'] as String,
      iconPath: data['iconPath'] as String,
      alcoholByVolume: data['alcoholByVolume'],
      percentOfCocktailVolume: data['percentOfCocktailVolume'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'iconPath': iconPath,
      'alcoholByVolume': alcoholByVolume,
      'percentOfCocktailVolume': percentOfCocktailVolume,
    };
  }
}
