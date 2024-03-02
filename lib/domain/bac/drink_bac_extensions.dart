import '../diary/consumed_drink.dart';

extension DrinkBacExtensions on ConsumedDrink {
  DateTime get endTime => startTime.add(duration);
}
