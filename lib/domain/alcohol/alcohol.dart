import 'drink_category.dart';

typedef Milliliter = int;
typedef Percentage = double;

abstract class Alcohol {
  static const eliminationRate = 0.12;
  static const bioavailability = 0.9;

  /// The density of alcohol in g/ml
  static const density = 0.789;

  /// The limit of alcohol in the blood to be considered sober in g/100mL
  static const soberLimit = 0.001;
  static const caloriesPerGramOfAlcohol = 7.1;

  final String name;
  final String iconPath;
  final DrinkCategory category;

  /// The volume of the drink in milliliters
  final Milliliter volume;

  /// The alcohol by volume (ABV) in percentage (v/v%)
  final Percentage alcoholByVolume;

  double get gramsOfAlcohol => (volume * alcoholByVolume * density);
  int get calories => (gramsOfAlcohol * caloriesPerGramOfAlcohol).round();

  const Alcohol({
    required this.name,
    required this.iconPath,
    required this.category,
    required this.volume,
    required this.alcoholByVolume,
  });
}
