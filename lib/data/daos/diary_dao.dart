import 'package:realm/realm.dart';

import '../../domain/diary/diary_entry.dart';
import '../../infra/extensions/floor_date_time.dart';
import '../models/diary_entry_model.dart';
import 'dao.dart';

class DiaryDAO extends DAO {
  DiaryDAO(super.databaseProvider);

  void save(DiaryEntry entry) {
    final entity = entry.toModel();
    databaseProvider.realm.add(entity, update: true);
  }

  void delete(DiaryEntry entry) {
    final entity = databaseProvider.realm.find<DiaryEntryModel>(entry.id);
    if (entity != null) {
      databaseProvider.realm.delete(entity);
    }
  }

  Stream<List<DiaryEntry>> observeBetweenDates(DateTime startDate, DateTime endDate) {
    return databaseProvider.realm
        .query<DiaryEntryModel>(
          'date BETWEEN {\$0, \$1} SORT (date ASC)',
          [startDate.floorToDay().toUtc(), endDate.floorToDay().toUtc()],
        )
        .changes
        .map((event) => event.results.map((e) => _Entity.fromModel(e)).toList());
  }

  DiaryEntry? findOnDate(DateTime date) {
    final results = databaseProvider.realm.query<DiaryEntryModel>('date == \$0', [date.floorToDay().toUtc()]);
    return results.isEmpty ? null : _Entity.fromModel(results.first);
  }

  Stream<List<DiaryEntry>> observeEntriesAfter(DateTime date) {
    return databaseProvider.realm
        .query<DiaryEntryModel>(
          'date >= \$0 SORT (date ASC)',
          [date.floorToDay().toUtc()],
        )
        .changes
        .map((event) => event.results.map((e) => _Entity.fromModel(e)).toList());
  }

  Stream<DiaryEntry?> observeOnDate(DateTime date) {
    return databaseProvider.realm
        .query<DiaryEntryModel>('date == \$0 LIMIT(1)', [date.floorToDay().toUtc()])
        .changes
        .map((event) => event.results.isNotEmpty ? _Entity.fromModel(event.results.first) : null);
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
