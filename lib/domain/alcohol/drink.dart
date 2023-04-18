import 'alcohol.dart';

/// Represents a drink that was not yet consumed, something like a preset. [ConsumedDrink] is what results
/// when this drink was consumed.
/// The name of the [ConsumedDrink] must match the name of the [Drink] it is based on.
class Drink extends Alcohol {
  static const defaultVolume = 100;
  final List<Milliliter> defaultServings;
  final Duration defaultDuration;

  Drink({
    required super.name,
    required super.iconPath,
    required super.category,
    required super.alcoholByVolume,
    required this.defaultServings,
    required this.defaultDuration,
  })  : assert(defaultServings.isNotEmpty),
        assert(alcoholByVolume >= 0.0 && alcoholByVolume <= 1.0),
        super(volume: defaultServings.first);
}
