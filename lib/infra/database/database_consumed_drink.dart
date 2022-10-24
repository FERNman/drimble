import 'package:isar/isar.dart';

import '../../domain/diary/consumed_drink.dart';
import '../../domain/diary/stomach_fullness.dart';
import 'database_beverage.dart';
import 'database_duration.dart';

part 'database_consumed_drink.g.dart';

@Collection(accessor: 'consumedDrinks')
class DatabaseConsumedDrink extends ConsumedDrink {
  DatabaseBeverage get dbBeverage => beverage.toEntity();

  DatabaseDuration get dbDuration => duration.toEntity();

  DatabaseConsumedDrink({
    super.id,
    required DatabaseBeverage dbBeverage,
    required super.volume,
    required super.alcoholByVolume,
    required super.startTime,
    required DatabaseDuration dbDuration,
    required super.stomachFullness,
  }) : super(beverage: dbBeverage, duration: dbDuration.duration);
}

extension ConsumedDrinkDatabaseConveresions on ConsumedDrink {
  DatabaseConsumedDrink toEntity() => DatabaseConsumedDrink(
        id: id,
        dbBeverage: beverage.toEntity(),
        volume: volume,
        alcoholByVolume: alcoholByVolume,
        startTime: startTime,
        dbDuration: duration.toEntity(),
        stomachFullness: stomachFullness,
      );
}
