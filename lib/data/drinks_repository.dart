import 'dart:async';

import '../domain/date.dart';
import '../domain/diary/diary_entry.dart';
import '../domain/diary/drink.dart';
import 'daos/diary_dao.dart';
import 'daos/drinks_dao.dart';

class DrinksRepository {
  final DrinksDAO _drinksDao;
  final DiaryDAO _diaryDao;

  DrinksRepository(this._drinksDao, this._diaryDao);

  Stream<List<Drink>> observeDrinksBetweenDays(Date startDate, Date endDate) =>
      _drinksDao.observeBetweenDates(startDate, endDate);

  Stream<List<Drink>> observeDrinksOnDate(Date date) => _drinksDao.observeOnDate(date);

  Stream<List<Drink>> observeLatestDrinks() => _drinksDao.observeLatest();

  List<Drink> findDrinksOnDate(Date date) => _drinksDao.findOnDate(date);

  void save(Drink drink) async {
    await _drinksDao.transaction(() {
      _drinksDao.save(drink);
      _markAsNonDrinkFree(drink.date);
    });
  }

  void _markAsNonDrinkFree(Date date) {
    final existingEntry = _diaryDao.findOnDate(date);
    final diaryEntry = existingEntry?.copyWith(isDrinkFreeDay: false) ?? DiaryEntry(date: date, isDrinkFreeDay: false);
    _diaryDao.save(diaryEntry);
  }

  void removeDrink(Drink drink) async {
    await _drinksDao.transaction(() {
      _drinksDao.delete(drink);

      final remainingDrinksOnThisDay = _drinksDao.findOnDate(drink.date);
      if (remainingDrinksOnThisDay.isEmpty) {
        _markAsUntracked(drink.date);
      }
    });
  }

  void _markAsUntracked(Date date) {
    final diaryEntry = _diaryDao.findOnDate(date);
    if (diaryEntry != null) {
      _diaryDao.delete(diaryEntry);
    }
  }
}
