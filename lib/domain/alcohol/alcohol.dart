import 'drink_category.dart';
import 'milliliter.dart';
import 'percentage.dart';

abstract class Alcohol {
  static const eliminationRate = 0.12;
  static const bioavailability = 0.9;
  static const density = 0.789;
  static const soberLimit = 0.01;
  static const caloriesPerGramOfAlcohol = 7.1;

  final String name;
  final String icon;
  final DrinkCategory category;
  final Milliliter volume;
  final Percentage alcoholByVolume;

  double get gramsOfAlcohol => (volume * alcoholByVolume * Alcohol.density);
  int get calories => (gramsOfAlcohol * caloriesPerGramOfAlcohol).round();

  const Alcohol({
    required this.name,
    required this.icon,
    required this.category,
    required this.volume,
    required this.alcoholByVolume,
  });
}
