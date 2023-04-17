import '../domain/date.dart';
import '../domain/diary/consumed_drink.dart';
import '../domain/diary/diary_entry.dart';
import 'daos/consumed_drinks_dao.dart';
import 'daos/diary_dao.dart';

class DiaryRepository {
  final DiaryDAO _diaryDao;
  final ConsumedDrinksDAO _drinksDao;

  DiaryRepository(this._diaryDao, this._drinksDao);

  Stream<List<DiaryEntry>> observeEntriesAfter(Date date) => _diaryDao.observeEntriesAfter(date);

  Stream<DiaryEntry?> observeEntryOnDate(Date date) => _diaryDao.observeOnDate(date);

  Stream<List<DiaryEntry>> observeEntriesBetween(Date startDate, Date endDate) =>
      _diaryDao.observeBetweenDates(startDate, endDate);

  DiaryEntry? findEntryOnDate(Date date) => _diaryDao.findOnDate(date);

  Stream<List<ConsumedDrink>> observeDrinksBetweenDays(Date startDate, Date endDate) =>
      _drinksDao.observeBetweenDates(startDate, endDate);

  Stream<List<ConsumedDrink>> observeDrinksOnDate(Date date) => _drinksDao.observeOnDate(date);

  Stream<List<ConsumedDrink>> observeLatestDrinks() => _drinksDao.observeLatest();

  List<ConsumedDrink> findDrinksOnDate(Date date) => _drinksDao.findOnDate(date);

  void markAsDrinkFree(Date date) async {
    await _diaryDao.transaction(() {
      _drinksDao.deleteOnDate(date);

      final entity = _diaryDao.findOnDate(date);
      final entry = entity?.copyWith(isDrinkFreeDay: true) ?? DiaryEntry(date: date, isDrinkFreeDay: true);
      _diaryDao.save(entry);
    });
  }

  void addDrink(ConsumedDrink drink) async {
    await _drinksDao.transaction(() {
      _drinksDao.save(drink);
      _markAsNonDrinkFree(drink.date);
    });
  }

  void removeDrink(ConsumedDrink drink) async {
    await _drinksDao.transaction(() {
      _drinksDao.delete(drink);

      final remainingDrinksOnThisDay = _drinksDao.findOnDate(drink.date);
      if (remainingDrinksOnThisDay.isEmpty) {
        _deleteEntryOnDate(drink.date);
      }
    });
  }

  void _markAsNonDrinkFree(Date date) {
    final existingEntry = _diaryDao.findOnDate(date);
    final diaryEntry = existingEntry?.copyWith(isDrinkFreeDay: false) ?? DiaryEntry(date: date, isDrinkFreeDay: false);
    _diaryDao.save(diaryEntry);
  }

  void _deleteEntryOnDate(Date date) {
    final diaryEntry = _diaryDao.findOnDate(date);
    if (diaryEntry != null) {
      _diaryDao.delete(diaryEntry);
    }
  }
}
