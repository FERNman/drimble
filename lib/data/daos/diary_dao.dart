import 'package:sqlbrite/sqlbrite.dart';

import '../../domain/diary/diary_entry.dart';
import '../../infra/extensions/floor_date_time.dart';
import 'dao.dart';

class DiaryDAO extends DAO {
  DiaryDAO(super.database);

  static Future<void> create(Database database) async {
    await database.execute('''CREATE TABLE IF NOT EXISTS ${_Entity.table} (
      ${_Entity.id} INTEGER PRIMARY KEY,
      ${_Entity.date} INTEGER NOT NULL,
      ${_Entity.isDrinkFreeDay} INTEGER NOT NULL
      )''');

    await database.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_date ON ${_Entity.table} (${_Entity.date} ASC)');
  }

  Future<void> save(DiaryEntry entry) async {
    if (entry.id == null) {
      final id = await executor.insert(_Entity.table, entry.toEntity());
      entry.id = id;
    } else {
      await executor.update(_Entity.table, entry.toEntity(), where: '${_Entity.id} = ?', whereArgs: [entry.id]);
    }
  }

  Future<void> delete(DiaryEntry entry) async {
    await executor.delete(_Entity.table, where: '${_Entity.id} = ?', whereArgs: [entry.id]);
  }

  Stream<List<DiaryEntry>> observeBetweenDates(DateTime startDate, DateTime endDate) {
    return database
        .createQuery(
          _Entity.table,
          where: '${_Entity.date} BETWEEN ? AND ?',
          whereArgs: [startDate.floorToDay().millisecondsSinceEpoch, endDate.floorToDay().millisecondsSinceEpoch],
          orderBy: '${_Entity.date} ASC',
        )
        .mapToList((e) => _Entity.fromEntity(e));
  }

  Future<DiaryEntry?> findOnDate(DateTime date) {
    return executor
        .query(
          _Entity.table,
          where: '${_Entity.date} = ?',
          whereArgs: [date.floorToDay().millisecondsSinceEpoch],
          limit: 1,
        )
        .then((entities) => entities.isEmpty ? null : _Entity.fromEntity(entities.first));
  }

  Stream<List<DiaryEntry>> observeEntriesAfter(DateTime date) {
    return database.createQuery(
      _Entity.table,
      where: '${_Entity.date} >= ?',
      whereArgs: [date.floorToDay().millisecondsSinceEpoch],
    ).mapToList((e) => _Entity.fromEntity(e));
  }

  Stream<DiaryEntry?> observeEntryOnDate(DateTime date) {
    return database
        .createQuery(
          _Entity.table,
          where: '${_Entity.date} = ?',
          whereArgs: [date.floorToDay().millisecondsSinceEpoch],
          limit: 1,
        )
        .mapToOneOrDefault((row) => _Entity.fromEntity(row), null);
  }

  Future<void> drop() async {
    await executor.delete(_Entity.table);
  }
}

extension _Entity on DiaryEntry {
  static const table = 'diary';

  static const id = 'id';
  static const date = 'date';
  static const isDrinkFreeDay = 'isDrinkFreeDay';

  Map<String, dynamic> toEntity() => {
        id: this.id,
        date: this.date.millisecondsSinceEpoch,
        isDrinkFreeDay: this.isDrinkFreeDay ? 1 : 0,
      };

  static DiaryEntry fromEntity(Map<String, dynamic> entity) => DiaryEntry(
        id: entity[id],
        date: DateTime.fromMillisecondsSinceEpoch(entity[date]),
        isDrinkFreeDay: entity[isDrinkFreeDay] == 1,
      );
}
