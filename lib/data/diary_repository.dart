import '../domain/diary/diary_entry.dart';
import '../infra/extensions/floor_date_time.dart';
import 'daos/consumed_drinks_dao.dart';
import 'daos/diary_dao.dart';

class DiaryRepository {
  final DiaryDAO _diaryDao;
  final ConsumedDrinksDAO _drinksDao;

  DiaryRepository(this._diaryDao, this._drinksDao);

  Stream<List<DiaryEntry>> observeEntriesAfter(DateTime date) => _diaryDao.observeEntriesAfter(date.floorToDay());

  Stream<DiaryEntry?> observeEntryOnDate(DateTime date) => _diaryDao.observeEntryOnDate(date);

  Future<DiaryEntry?> getEntryOnDate(DateTime date) => _diaryDao.findOnDate(date);

  void markAsDrinkFree(DateTime date) async {
    await _drinksDao.deleteOnDate(date);

    final entry = await _diaryDao.findOnDate(date.floorToDay()) ?? DiaryEntry(date: date, isDrinkFreeDay: true);
    entry.copyWith(isDrinkFreeDay: true);
    await _diaryDao.save(entry);
  }
}
