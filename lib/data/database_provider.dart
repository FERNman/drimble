import 'package:realm/realm.dart';

class DatabaseProvider {
  final List<SchemaObject> _objects;

  Realm? _realm;

  Realm get realm {
    assert(_realm != null, 'You tried to use the database without a signed in user.');
    return _realm!;
  }

  DatabaseProvider(this._objects);

  void openOfflineInstance() {
    _realm?.close();

    final config = Configuration.local(_objects, schemaVersion: 0);
    _realm = Realm(config);
  }

  void openSyncedInstance(User user) {
    _realm?.close();

    final config = Configuration.flexibleSync(user, _objects);
    _realm = Realm(config);
  }

  void logOut() {
    if (_realm != null) {
      final path = _realm!.config.path;
      _realm!.close();
      Realm.deleteRealm(path);

      _realm = null;
    }
  }
}
