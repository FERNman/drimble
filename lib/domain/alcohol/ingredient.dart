import 'alcohol.dart';

class Ingredient extends Alcohol {
  final Percentage percentOfCocktailVolume;

  @override
  Milliliter get volume => throw UnimplementedError('Use `scaleVolume` instead.');

  const Ingredient({
    required super.name,
    required super.iconPath,
    required super.category,
    required super.alcoholByVolume,
    required this.percentOfCocktailVolume,
  }) : super(volume: 0);

  Milliliter actualVolume(Milliliter cocktailVolume) {
    return (cocktailVolume * percentOfCocktailVolume).round();
  }
}
