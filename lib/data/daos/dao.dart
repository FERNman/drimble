import 'package:flutter/foundation.dart';

import '../database_provider.dart';

abstract class DAO {
  @protected
  final DatabaseProvider databaseProvider;

  DAO(this.databaseProvider);

  Future<void> transaction<T>(void Function() action) async {
    await databaseProvider.realm.writeAsync(() {
      action();
    });
  }
}
