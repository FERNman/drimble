import 'dart:async';

import 'package:isar/isar.dart';

import '../domain/drink/consumed_drink.dart';
import '../infra/database/database_consumed_drink.dart';
import '../infra/extensions/floor_date_time.dart';

class ConsumedDrinksRepository {
  static const oneDay = Duration(days: 1);

  final IsarCollection<DatabaseConsumedDrink> collection;

  ConsumedDrinksRepository(Isar database) : collection = database.consumedDrinks;

  Stream<List<ConsumedDrink>> observeDrinksOnDate(DateTime date) {
    return collection
        .where()
        .startTimeBetween(date.floorToDay(), date.add(oneDay).floorToDay())
        .sortByStartTimeDesc()
        .watch(fireImmediately: true);
  }

  Future<List<ConsumedDrink>> getDrinksOnDate(DateTime date) async {
    return collection
        .where()
        .startTimeBetween(date.floorToDay(), date.add(oneDay).floorToDay())
        .sortByStartTimeDesc()
        .limit(3)
        .findAll();
  }

  void save(ConsumedDrink drink) async {
    await collection.isar.writeTxn(() async {
      await collection.put(drink.toEntity());
    });
  }

  void removeDrink(ConsumedDrink drink) async {
    if (drink.id != null) {
      await collection.delete(drink.id!);
    }
  }
}
