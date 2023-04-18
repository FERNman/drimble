import '../../domain/date.dart';
import '../../domain/diary/consumed_drink.dart';
import '../models/consumed_drink_model.dart';
import 'dao.dart';

class ConsumedDrinksDAO extends DAO {
  ConsumedDrinksDAO(super.databaseProvider);

  void save(ConsumedDrink drink) {
    final entity = drink.toModel();
    databaseProvider.realm.add(entity, update: true);
  }

  void delete(ConsumedDrink drink) {
    final entity = databaseProvider.realm.find<ConsumedDrinkModel>(drink.id);
    if (entity != null) {
      databaseProvider.realm.delete(entity);
    }
  }

  void deleteOnDate(Date date) {
    final results = databaseProvider.realm.query<ConsumedDrinkModel>(
      'startTime BETWEEN {\$0, \$1}',
      [date.toDateTime(), date.add(days: 1).toDateTime()],
    );
    databaseProvider.realm.deleteMany(results);
  }

  List<ConsumedDrink> findOnDate(Date date) {
    return databaseProvider.realm
        .query<ConsumedDrinkModel>(
          'startTime BETWEEN {\$0, \$1} SORT(startTime DESC)',
          [date.toDateTime(), date.add(days: 1).toDateTime()],
        )
        .map((e) => ConsumedDrinkEntity.fromModel(e))
        .toList();
  }

  Stream<List<ConsumedDrink>> observeOnDate(Date date) {
    return databaseProvider.realm
        .query<ConsumedDrinkModel>(
          'startTime BETWEEN {\$0, \$1} SORT(startTime DESC)',
          [date.toDateTime(), date.add(days: 1).toDateTime()],
        )
        .changes
        .map((event) => event.results.map((e) => ConsumedDrinkEntity.fromModel(e)).toList());
  }

  Stream<List<ConsumedDrink>> observeBetweenDates(Date startDate, Date endDate) {
    return databaseProvider.realm
        .query<ConsumedDrinkModel>(
          'startTime BETWEEN {\$0, \$1} SORT(startTime DESC)',
          [startDate.toDateTime(), endDate.toDateTime()],
        )
        .changes
        .map((event) => event.results.map((e) => ConsumedDrinkEntity.fromModel(e)).toList());
  }

  Stream<List<ConsumedDrink>> observeLatest() {
    return databaseProvider.realm
        .query<ConsumedDrinkModel>('TRUEPREDICATE SORT(startTime DESC) DISTINCT (name) LIMIT(3)')
        .changes
        .map((event) => event.results.map((e) => ConsumedDrinkEntity.fromModel(e)).toList());
  }
}
