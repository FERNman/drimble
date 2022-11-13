import 'dart:async';

import '../domain/diary/diary_entry.dart';
import '../domain/diary/drink.dart';
import 'daos/diary_dao.dart';
import 'daos/drinks_dao.dart';

class DrinksRepository {
  final DrinksDAO _consumedDrinksDao;
  final DiaryDAO _diaryDao;

  DrinksRepository(this._consumedDrinksDao, this._diaryDao);

  Stream<List<Drink>> observeDrinksBetween(DateTime startDate, DateTime endDate) =>
      _consumedDrinksDao.observeBetweenDates(startDate, endDate);

  Stream<List<Drink>> observeDrinksOnDate(DateTime date) => _consumedDrinksDao.observeOnDate(date);

  Future<List<Drink>> getDrinksOnDate(DateTime date) async => _consumedDrinksDao.findOnDate(date);

  Stream<List<Drink>> observeLatestDrinks() => _consumedDrinksDao.observeLatest();

  void save(Drink drink) async {
    await _consumedDrinksDao.save(drink);
    await _markAsNonDrinkFree(drink.date);
  }

  void removeDrink(Drink drink) async {
    await _consumedDrinksDao.delete(drink);

    final remainingDrinksOnThisDay = await getDrinksOnDate(drink.date);
    if (remainingDrinksOnThisDay.isEmpty) {
      await _markAsUntracked(drink.date);
    }
  }

  Future<void> _markAsNonDrinkFree(DateTime date) async {
    final existingEntry = await _diaryDao.findOnDate(date);
    final diaryEntry = existingEntry?.copyWith(isDrinkFreeDay: false) ?? DiaryEntry(date: date, isDrinkFreeDay: false);

    _diaryDao.save(diaryEntry);
  }

  Future<void> _markAsUntracked(DateTime date) async {
    final diaryEntry = await _diaryDao.findOnDate(date);
    if (diaryEntry != null) {
      await _diaryDao.delete(diaryEntry);
    }
  }
}
