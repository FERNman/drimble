import 'package:sqflite/sqflite.dart';

extension DropDatabase on Database {
  Future<void> drop() async {
    final tables = await rawQuery('SELECT name FROM sqlite_master WHERE type = "table"');
    for (final table in tables) {
      await delete(table['name'] as String);
    }
  }
}
