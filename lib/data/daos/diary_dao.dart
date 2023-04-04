import 'package:realm/realm.dart';

import '../../domain/diary/diary_entry.dart';
import '../../infra/extensions/floor_date_time.dart';
import '../models/diary_entry_model.dart';
import 'dao.dart';

class DiaryDAO extends DAO {
  DiaryDAO(super.database);

  void save(DiaryEntry entry) {
    final entity = entry.toModel();
    realm.add(entity, update: true);
  }

  void delete(DiaryEntry entry) {
    final entity = realm.find<DiaryEntryModel>(entry.id);
    if (entity != null) {
      realm.delete(entity);
    }
  }

  Stream<List<DiaryEntry>> observeBetweenDates(DateTime startDate, DateTime endDate) {
    return realm
        .query<DiaryEntryModel>(
          'date BETWEEN {\$0, \$1} SORT (date ASC)',
          [startDate.floorToDay().toUtc(), endDate.floorToDay().toUtc()],
        )
        .changes
        .map((event) => event.results.map((e) => _Entity.fromModel(e)).toList());
  }

  DiaryEntry? findOnDate(DateTime date) {
    final results = realm.query<DiaryEntryModel>('date == \$0', [date.floorToDay().toUtc()]);
    return results.isEmpty ? null : _Entity.fromModel(results.first);
  }

  Stream<List<DiaryEntry>> observeEntriesAfter(DateTime date) {
    return realm
        .query<DiaryEntryModel>(
          'date >= \$0 SORT (date ASC)',
          [date.floorToDay().toUtc()],
        )
        .changes
        .map((event) => event.results.map((e) => _Entity.fromModel(e)).toList());
  }

  Stream<DiaryEntry?> observeOnDate(DateTime date) {
    return realm
        .query<DiaryEntryModel>('date == \$0 LIMIT(1)', [date.floorToDay().toUtc()])
        .changes
        .map((event) => event.results.isNotEmpty ? _Entity.fromModel(event.results.first) : null);
  }

  void drop() {
    realm.deleteAll<DiaryEntryModel>();
  }
}

extension _Entity on DiaryEntry {
  DiaryEntryModel toModel() => DiaryEntryModel(
        id ?? ObjectId().hexString,
        date.toUtc(),
        isDrinkFreeDay,
      );

  static DiaryEntry fromModel(DiaryEntryModel model) => DiaryEntry(
        id: model.id,
        date: model.date.toLocal(),
        isDrinkFreeDay: model.isDrinkFreeDay,
      );
}
