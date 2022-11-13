import 'package:sqlbrite/sqlbrite.dart';

import '../../domain/alcohol/drink_category.dart';
import '../../domain/diary/drink.dart';
import '../../domain/diary/stomach_fullness.dart';
import '../../infra/extensions/floor_date_time.dart';

class DrinksDAO {
  final BriteDatabase _database;

  const DrinksDAO(this._database);

  static Future<void> create(Database database) async {
    await database.execute('''CREATE TABLE IF NOT EXISTS ${_Entity.table} (
      ${_Entity.id} INTEGER PRIMARY KEY,
      ${_Entity.name} TEXT NOT NULL,
      ${_Entity.icon} TEXT NOT NULL,
      ${_Entity.category} TEXT NOT NULL,
      ${_Entity.volume} INTEGER NOT NULL,
      ${_Entity.alcoholByVolume} REAL NOT NULL,
      ${_Entity.stomachFullness} TEXT NOT NULL,
      ${_Entity.startTime} INTEGER NOT NULL,
      ${_Entity.duration} INTEGER NOT NULL
      )''');

    await database.execute('CREATE INDEX IF NOT EXISTS idx_startTime ON ${_Entity.table} (${_Entity.startTime} ASC)');
  }

  Future<void> save(Drink drink) async {
    if (drink.id == null) {
      final id = await _database.insert(_Entity.table, drink.toEntity());
      drink.id = id;
    } else {
      await _database.update(_Entity.table, drink.toEntity(), where: '${_Entity.id} = ?', whereArgs: [drink.id]);
    }
  }

  Future<void> delete(Drink drink) async {
    await _database.delete(_Entity.table, where: '${_Entity.id} = ?', whereArgs: [drink.id]);
  }

  Future<void> deleteOnDate(DateTime date) async {
    final startTime = date.floorToDay(hour: 6);
    final endTime = startTime.add(const Duration(days: 1));

    await _database.delete(
      _Entity.table,
      where: '${_Entity.startTime} BETWEEN ? AND ?',
      whereArgs: [startTime.millisecondsSinceEpoch, endTime.millisecondsSinceEpoch],
    );
  }

  Future<List<Drink>> findOnDate(DateTime date) {
    final startTime = date.floorToDay(hour: 6);
    final endTime = startTime.add(const Duration(days: 1));

    return _database
        .query(
          _Entity.table,
          where: '${_Entity.startTime} BETWEEN ? AND ?',
          whereArgs: [startTime.millisecondsSinceEpoch, endTime.millisecondsSinceEpoch],
          orderBy: '${_Entity.startTime} ASC',
        )
        .then((entities) => entities.map((e) => _Entity.fromEntity(e)).toList());
  }

  Stream<List<Drink>> observeOnDate(DateTime date) {
    final startTime = date.floorToDay(hour: 6);
    final endTime = startTime.add(const Duration(days: 1));

    return _database
        .createQuery(
          _Entity.table,
          where: '${_Entity.startTime} BETWEEN ? AND ?',
          whereArgs: [startTime.millisecondsSinceEpoch, endTime.millisecondsSinceEpoch],
          orderBy: '${_Entity.startTime} ASC',
        )
        .mapToList((e) => _Entity.fromEntity(e));
  }

  Stream<List<Drink>> observeBetweenDates(DateTime startDate, DateTime endDate) {
    return _database
        .createQuery(
          _Entity.table,
          where: '${_Entity.startTime} BETWEEN ? AND ?',
          whereArgs: [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
          orderBy: '${_Entity.startTime} ASC',
        )
        .mapToList((e) => _Entity.fromEntity(e));
  }

  Stream<List<Drink>> observeLatest() {
    return _database
        .createQuery(
          _Entity.table,
          limit: 3,
          orderBy: '${_Entity.startTime} DESC',
        )
        .mapToList((e) => _Entity.fromEntity(e));
  }

  Future<void> drop() async {
    await _database.delete(_Entity.table);
  }
}

extension _Entity on Drink {
  static const table = 'consumed_drinks';

  static const id = 'id';
  static const name = 'name';
  static const icon = 'icon';
  static const category = 'category';
  static const volume = 'volume';
  static const alcoholByVolume = 'alcoholByVolume';
  static const stomachFullness = 'stomachFullness';
  static const startTime = 'startTime';
  static const duration = 'duration';

  Map<String, dynamic> toEntity() => {
        id: this.id,
        name: this.name,
        icon: this.icon,
        category: this.category.name,
        volume: this.volume,
        alcoholByVolume: this.alcoholByVolume,
        stomachFullness: this.stomachFullness.name,
        startTime: this.startTime.millisecondsSinceEpoch,
        duration: this.duration.inMilliseconds,
      };

  static Drink fromEntity(Map<String, dynamic> entity) => Drink(
        id: entity[id],
        name: entity[name],
        icon: entity[icon],
        category: DrinkCategory.values.firstWhere((e) => e.name == entity[category]),
        volume: entity[volume],
        alcoholByVolume: entity[alcoholByVolume],
        stomachFullness: StomachFullness.values.firstWhere((e) => e.name == entity[stomachFullness]),
        startTime: DateTime.fromMillisecondsSinceEpoch(entity[startTime]),
        duration: Duration(milliseconds: entity[duration]),
      );
}
