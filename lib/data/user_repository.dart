import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/user/user.dart';

class UserRepository {
  static const userKey = 'user';

  final BehaviorSubject<User?> _user = BehaviorSubject();
  final Isar _database;

  Future<User?> get user async => _user.hasValue ? _user.value : await _user.first;

  UserRepository(this._database) {
    _tryLoadUser().then((value) => _user.add(value));
  }

  Stream<User?> observeUser() => _user.stream;

  Future<bool> isSignedIn() async => await user != null;

  void signIn(User user) async {
    _user.add(user);
    await _persistUser(user);
  }

  void signOut() async {
    _user.add(null);
    await _unsetUser();

    await _database.txn(() async {
      await _database.clear();
    });
  }

  Future<User?> _tryLoadUser() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final encodedUser = sharedPreferences.getString(userKey);
    if (encodedUser != null) {
      return User.fromJson(jsonDecode(encodedUser));
    }

    return null;
  }

  Future<void> _persistUser(User user) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final encodedUser = jsonEncode(user.toJson());
    await sharedPreferences.setString(userKey, encodedUser);
  }

  Future<void> _unsetUser() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove(userKey);
  }
}
