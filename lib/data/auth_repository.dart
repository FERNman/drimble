import 'dart:convert';

import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/user/body_composition.dart';
import '../domain/user/gender.dart';
import '../domain/user/user.dart';

class AuthRepository {
  static const userKey = 'user';

  final BehaviorSubject<User?> _user = BehaviorSubject.seeded(User(
    name: 'Gabriel',
    age: 23,
    gender: Gender.male,
    weight: 83,
    height: 180,
    bodyComposition: BodyComposition.athletic,
  ));

  AuthRepository() {
    // _tryLoadUser().then((value) => _user.add(value));
  }

  Future<bool> isSignedIn() async => await _user.first != null;

  Future<User?> getUser() {
    return _user.first;
  }

  void setUser(User user) async {
    _user.add(user);
    await _persistUser(user);
  }

  Future<User?> _tryLoadUser() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final encodedUser = sharedPreferences.getString(userKey);
    if (encodedUser != null) {
      return jsonDecode(encodedUser);
    }

    return null;
  }

  Future<void> _persistUser(User user) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final encodedUser = jsonEncode(user);
    await sharedPreferences.setString(userKey, encodedUser);
  }
}
