import 'package:collection/collection.dart';
import 'package:isar/isar.dart';

import '../domain/diary/diary_entry.dart';
import '../infra/database/database_consumed_drink.dart';
import '../infra/database/database_diary_entry.dart';
import '../infra/extensions/floor_date_time.dart';
import 'consumed_drinks_repository.dart';

class DiaryRepository {
  final IsarCollection<DatabaseDiaryEntry> _collection;

  Isar get _database => _collection.isar;

  DiaryRepository(Isar database) : _collection = database.diary;

  Stream<List<DiaryEntry>> observeEntriesAfter(DateTime date) {
    return _collection.where().dateGreaterThan(date.floorToDay()).sortByDateDesc().watch(fireImmediately: true);
  }

  Stream<DiaryEntry?> overserveEntryOnDate(DateTime date) {
    return _collection
        .where()
        .dateEqualTo(date.floorToDay())
        .limit(1)
        .watch(fireImmediately: true)
        .map((results) => results.firstOrNull);
  }

  void markAsDrinkFree(DateTime date) async {
    await _database.writeTxn(() async {
      await _deleteDrinksOnDate(date);

      final entry = await _collection.where().dateEqualTo(date.floorToDay()).findFirst() ??
          DatabaseDiaryEntry(date: date, isDrinkFreeDay: true);
      entry.isDrinkFreeDay = true;

      await _collection.put(entry);
    });
  }

  Future<void> _deleteDrinksOnDate(DateTime date) async {
    final drinks = await _database.consumedDrinks.where().startTimeOnSameDate(date).findAll();
    final idsToDelete = drinks.map((e) => e.id!).toList();

    await _database.consumedDrinks.deleteAll(idsToDelete);
  }
}
