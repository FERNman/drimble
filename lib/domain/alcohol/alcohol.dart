import 'drink_category.dart';

typedef Milliliter = int;
typedef Percentage = double;

abstract class Alcohol {
  static const eliminationRate = 0.12;
  static const bioavailability = 0.9;
  static const density = 0.789;
  static const soberLimit = 0.01;
  static const caloriesPerGramOfAlcohol = 7.1;

  final String name;
  final String iconPath;
  final DrinkCategory category;

  /// The volume of the drink in milliliters
  final Milliliter volume;

  /// The alcohol by volume (ABV) in percentage (v/v%)
  final Percentage alcoholByVolume;

  double get gramsOfAlcohol => (volume * alcoholByVolume * Alcohol.density);
  int get calories => (gramsOfAlcohol * caloriesPerGramOfAlcohol).round();

  const Alcohol({
    required this.name,
    required this.iconPath,
    required this.category,
    required this.volume,
    required this.alcoholByVolume,
  });
}
