import 'package:isar/isar.dart';

import 'milliliter.dart';
import 'percentage.dart';

class Beverage {
  final String name;
  final String icon;
  final List<Milliliter> standardServings;
  final Percentage defaultABV;

  @ignore
  final Duration defaultDuration;

  const Beverage({
    required this.name,
    required this.icon,
    required this.standardServings,
    required this.defaultABV,
    required this.defaultDuration,
  });
}
