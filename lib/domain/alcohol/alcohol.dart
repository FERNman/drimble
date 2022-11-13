import 'drink_category.dart';
import 'milliliter.dart';
import 'percentage.dart';

abstract class Alcohol {
  static const eliminationRate = 0.12;
  static const bioavailability = 0.9;
  static const density = 0.789;
  static const soberLimit = 0.01;

  final String name;
  final String icon;
  final DrinkCategory category;
  final Milliliter volume;
  final Percentage alcoholByVolume;

  const Alcohol({
    required this.name,
    required this.icon,
    required this.category,
    required this.volume,
    required this.alcoholByVolume,
  });
}
