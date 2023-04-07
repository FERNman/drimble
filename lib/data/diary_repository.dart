import '../domain/date.dart';
import '../domain/diary/diary_entry.dart';
import 'daos/diary_dao.dart';
import 'daos/drinks_dao.dart';

class DiaryRepository {
  final DiaryDAO _diaryDao;
  final DrinksDAO _drinksDao;

  DiaryRepository(this._diaryDao, this._drinksDao);

  Stream<List<DiaryEntry>> observeEntriesAfter(Date date) => _diaryDao.observeEntriesAfter(date);

  Stream<DiaryEntry?> observeEntryOnDate(Date date) => _diaryDao.observeOnDate(date);

  Stream<List<DiaryEntry>> observeEntriesBetween(Date startDate, Date endDate) =>
      _diaryDao.observeBetweenDates(startDate, endDate);

  DiaryEntry? findEntryOnDate(Date date) => _diaryDao.findOnDate(date);

  void markAsDrinkFree(Date date) async {
    await _diaryDao.transaction(() {
      _drinksDao.deleteOnDate(date);

      final entity = _diaryDao.findOnDate(date);
      final entry = entity?.copyWith(isDrinkFreeDay: true) ?? DiaryEntry(date: date, isDrinkFreeDay: true);
      _diaryDao.save(entry);
    });
  }
}
