import 'package:flutter/foundation.dart';
import 'package:sqlbrite/sqlbrite.dart';
// ignore: implementation_imports
import 'package:sqlbrite/src/brite_transaction.dart';

abstract class DAO {
  // Has to be static because it is independent of the instance
  // sqflite only supports one concurrent transaction anyways
  // ignore: invalid_use_of_internal_member
  static BriteTransaction? _transaction;

  @protected
  final BriteDatabase database;

  @protected
  BriteDatabaseExecutor get executor => _transaction ?? database;

  DAO(this.database);

  Future<T> transaction<T>(Future<T> Function() action) {
    return database.transactionAndTrigger((txn) async {
      // ignore: invalid_use_of_internal_member
      _transaction = txn as BriteTransaction;

      try {
        return await action();
      } finally {
        _transaction = null;
      }
    });
  }
}
