import 'dart:async';

import 'package:isar/isar.dart';

import '../domain/diary/consumed_drink.dart';
import '../infra/database/database_consumed_drink.dart';
import '../infra/database/database_diary_entry.dart';
import '../infra/extensions/floor_date_time.dart';

class ConsumedDrinksRepository {
  static const oneDay = Duration(days: 1);

  final IsarCollection<DatabaseConsumedDrink> _collection;

  Isar get _database => _collection.isar;

  ConsumedDrinksRepository(Isar database) : _collection = database.consumedDrinks;

  Stream<List<ConsumedDrink>> observeDrinksBetween(DateTime startDate, DateTime endDate) {
    return _collection.where().startTimeBetween(startDate, endDate).sortByStartTimeDesc().watch(fireImmediately: true);
  }

  Stream<List<ConsumedDrink>> observeDrinksOnDate(DateTime date) {
    return _collection.where().onSameDate(date).sortByStartTimeDesc().watch(fireImmediately: true);
  }

  Future<List<ConsumedDrink>> getDrinksOnDate(DateTime date) async {
    return _collection.where().onSameDate(date).sortByStartTimeDesc().limit(3).findAll();
  }

  Stream<List<ConsumedDrink>> observeLatestDrinks() {
    return _collection.where().sortByStartTimeDesc().limit(3).watch(fireImmediately: true);
  }

  void save(ConsumedDrink drink) async {
    await _database.writeTxn(() async {
      await _collection.put(drink.toEntity());

      await _markAsNonDrinkFree(drink.date);
    });
  }

  void removeDrink(ConsumedDrink drink) async {
    assert(drink.id != null);

    await _database.writeTxn(() async {
      await _collection.delete(drink.id!);

      final remainingDrinksOnThisDay = await _collection.where().onSameDate(drink.date).count();
      if (remainingDrinksOnThisDay == 0) {
        await _markAsUntracked(drink.date);
      }
    });
  }

  Future<void> _markAsNonDrinkFree(DateTime date) async {
    final diaryEntry = await _database.diary.where().dateEqualTo(date).findFirst() ??
        DatabaseDiaryEntry(date: date, isDrinkFreeDay: false);

    diaryEntry.isDrinkFreeDay = false;

    _database.diary.put(diaryEntry);
  }

  Future<void> _markAsUntracked(DateTime date) async {
    final diaryEntry = await _database.diary.where().dateEqualTo(date).findFirst();
    if (diaryEntry != null) {
      await _database.diary.delete(diaryEntry.id!);
    }
  }
}

extension DrinksQueryBuilder on QueryBuilder<DatabaseConsumedDrink, DatabaseConsumedDrink, QWhere> {
  QueryBuilder<DatabaseConsumedDrink, DatabaseConsumedDrink, QAfterWhereClause> onSameDate(DateTime date) =>
      startTimeBetween(date.floorToDay(hour: 6), date.floorToDay(hour: 6).add(const Duration(days: 1)),
          includeUpper: false);
}
