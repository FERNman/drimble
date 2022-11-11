import 'dart:async';

import '../domain/diary/consumed_drink.dart';
import '../domain/diary/diary_entry.dart';
import 'daos/consumed_drinks_dao.dart';
import 'daos/diary_dao.dart';

class ConsumedDrinksRepository {
  static const oneDay = Duration(days: 1);

  final ConsumedDrinksDAO _consumedDrinksDao;
  final DiaryDAO _diaryDao;

  ConsumedDrinksRepository(this._consumedDrinksDao, this._diaryDao);

  Stream<List<ConsumedDrink>> observeDrinksBetween(DateTime startDate, DateTime endDate) =>
      _consumedDrinksDao.observeBetweenDates(startDate, endDate);

  Stream<List<ConsumedDrink>> observeDrinksOnDate(DateTime date) => _consumedDrinksDao.observeOnDate(date);

  Future<List<ConsumedDrink>> getDrinksOnDate(DateTime date) async => _consumedDrinksDao.findOnDate(date);

  Stream<List<ConsumedDrink>> observeLatestDrinks() => _consumedDrinksDao.observeLatest();

  void save(ConsumedDrink drink) async {
    await _consumedDrinksDao.save(drink);
    await _markAsNonDrinkFree(drink.date);
  }

  void removeDrink(ConsumedDrink drink) async {
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
