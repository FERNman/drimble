import 'dart:async';

import '../domain/diary/diary_entry.dart';
import '../domain/diary/drink.dart';
import 'daos/diary_dao.dart';
import 'daos/drinks_dao.dart';

class DrinksRepository {
  final DrinksDAO _drinksDao;
  final DiaryDAO _diaryDao;

  DrinksRepository(this._drinksDao, this._diaryDao);

  Stream<List<Drink>> observeDrinksBetweenDays(DateTime startDate, DateTime endDate) =>
      _drinksDao.observeBetweenDates(startDate, endDate);

  Stream<List<Drink>> observeDrinksOnDate(DateTime date) => _drinksDao.observeOnDate(date);

  Stream<List<Drink>> observeLatestDrinks() => _drinksDao.observeLatest();

  Future<List<Drink>> findDrinksOnDate(DateTime date) => _drinksDao.findOnDate(date);

  void save(Drink drink) async {
    await _drinksDao.transaction(() async {
      await _drinksDao.save(drink);
      await _markAsNonDrinkFree(drink.date);
    });
  }

  Future<void> _markAsNonDrinkFree(DateTime date) async {
    final existingEntry = await _diaryDao.findOnDate(date);
    final diaryEntry = existingEntry?.copyWith(isDrinkFreeDay: false) ?? DiaryEntry(date: date, isDrinkFreeDay: false);
    await _diaryDao.save(diaryEntry);
  }

  void removeDrink(Drink drink) async {
    await _drinksDao.transaction(() async {
      await _drinksDao.delete(drink);

      final remainingDrinksOnThisDay = await _drinksDao.findOnDate(drink.date);
      if (remainingDrinksOnThisDay.isEmpty) {
        await _markAsUntracked(drink.date);
      }
    });
  }

  Future<void> _markAsUntracked(DateTime date) async {
    final diaryEntry = await _diaryDao.findOnDate(date);
    if (diaryEntry != null) {
      await _diaryDao.delete(diaryEntry);
    }
  }
}
