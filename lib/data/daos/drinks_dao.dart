import 'package:realm/realm.dart';

import '../../domain/alcohol/drink_category.dart';
import '../../domain/diary/drink.dart';
import '../../domain/diary/stomach_fullness.dart';
import '../../infra/extensions/floor_date_time.dart';
import '../models/drink_model.dart';
import 'dao.dart';

class DrinksDAO extends DAO {
  DrinksDAO(super.realm);

  void save(Drink drink) {
    final entity = drink.toModel();
    realm.add(entity, update: true);
  }

  void delete(Drink drink) {
    final entity = realm.find<DrinkModel>(drink.id);
    if (entity != null) {
      realm.delete(entity);
    }
  }

  void deleteOnDate(DateTime date) {
    final startTime = date.floorToDay(hour: 6);
    final endTime = startTime.add(const Duration(days: 1));

    final results = realm.query<DrinkModel>('startTime BETWEEN {\$0, \$1}', [startTime.toUtc(), endTime.toUtc()]);
    realm.deleteMany(results);
  }

  List<Drink> findOnDate(DateTime date) {
    final startTime = date.floorToDay(hour: 6);
    final endTime = startTime.add(const Duration(days: 1));

    return realm
        .query<DrinkModel>('startTime BETWEEN {\$0, \$1} SORT(startTime DESC)', [startTime.toUtc(), endTime.toUtc()])
        .map((e) => _Entity.fromModel(e))
        .toList();
  }

  Stream<List<Drink>> observeOnDate(DateTime date) {
    final startTime = date.floorToDay(hour: 6);
    final endTime = startTime.add(const Duration(days: 1));

    return realm
        .query<DrinkModel>('startTime BETWEEN {\$0, \$1} SORT(startTime DESC)', [startTime.toUtc(), endTime.toUtc()])
        .changes
        .map((event) => event.results.map((e) => _Entity.fromModel(e)).toList());
  }

  Stream<List<Drink>> observeBetweenDates(DateTime startDate, DateTime endDate) {
    return realm
        .query<DrinkModel>(
          'startTime BETWEEN {\$0, \$1} SORT(startTime DESC)',
          [startDate.floorToDay(hour: 6).toUtc(), endDate.floorToDay(hour: 6).toUtc()],
        )
        .changes
        .map((event) => event.results.map((e) => _Entity.fromModel(e)).toList());
  }

  Stream<List<Drink>> observeLatest() {
    return realm
        .query<DrinkModel>('TRUEPREDICATE SORT(startTime DESC) LIMIT(3)')
        .changes
        .map((event) => event.results.map((e) => _Entity.fromModel(e)).toList());
  }

  void drop() {
    realm.deleteAll<DrinkModel>();
  }
}

extension _Entity on Drink {
  DrinkModel toModel() => DrinkModel(
        id ?? ObjectId().hexString,
        name,
        icon,
        category.name,
        volume,
        alcoholByVolume,
        startTime.toUtc(),
        duration.inMilliseconds,
        stomachFullness.name,
      );

  static Drink fromModel(DrinkModel model) => Drink(
        id: model.id,
        name: model.name,
        icon: model.icon,
        category: DrinkCategory.values.firstWhere((e) => e.name == model.category),
        volume: model.volume,
        alcoholByVolume: model.alcoholByVolume,
        startTime: model.startTime.toLocal(),
        duration: Duration(milliseconds: model.duration),
        stomachFullness: StomachFullness.values.firstWhere((e) => e.name == model.stomachFullness),
      );
}
