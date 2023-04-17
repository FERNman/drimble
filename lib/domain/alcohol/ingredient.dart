import 'alcohol.dart';

class Ingredient extends Alcohol {
  const Ingredient({
    required super.name,
    required super.iconPath,
    required super.category,
    required super.volume,
    required super.alcoholByVolume,
  });
}
