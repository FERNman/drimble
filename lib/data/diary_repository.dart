import '../domain/diary/diary_entry.dart';
import '../infra/extensions/floor_date_time.dart';
import 'daos/diary_dao.dart';
import 'daos/drinks_dao.dart';

class DiaryRepository {
  final DiaryDAO _diaryDao;
  final DrinksDAO _drinksDao;

  DiaryRepository(this._diaryDao, this._drinksDao);

  Stream<List<DiaryEntry>> observeEntriesAfter(DateTime date) => _diaryDao.observeEntriesAfter(date.floorToDay());

  Stream<DiaryEntry?> observeEntryOnDate(DateTime date) => _diaryDao.observeEntryOnDate(date);

  Future<List<DiaryEntry>> findEntriesBetween(DateTime startDate, DateTime endDate) =>
      _diaryDao.findBetweenDates(startDate.floorToDay(), endDate.floorToDay());

  Future<DiaryEntry?> findEntryOnDate(DateTime date) => _diaryDao.findOnDate(date);

  void markAsDrinkFree(DateTime date) async {
    await _diaryDao.transaction(() async {
      await _drinksDao.deleteOnDate(date);

      final entity = await _diaryDao.findOnDate(date.floorToDay());
      final entry = entity?.copyWith(isDrinkFreeDay: true) ?? DiaryEntry(date: date, isDrinkFreeDay: true);
      await _diaryDao.save(entry);
    });
  }
}
