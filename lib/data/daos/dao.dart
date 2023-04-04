import 'package:flutter/foundation.dart';
import 'package:realm/realm.dart';

abstract class DAO {
  @protected
  final Realm realm;

  DAO(this.realm);

  Future<void> transaction<T>(void Function() action) async {
    await realm.writeAsync(() {
      action();
    });
  }
}
