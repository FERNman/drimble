import 'dart:convert';

import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../domain/user/body_composition.dart';
import '../domain/user/gender.dart';
import '../domain/user/goals.dart';
import '../domain/user/user.dart';
import '../infra/extensions/database_drop.dart';

class UserRepository {
  static const _userKey = 'user';

  final BehaviorSubject<User?> _user = BehaviorSubject();
  final Database _database;

  Future<User?> get user async => _user.hasValue ? _user.value : await _user.first;

  UserRepository(this._database) {
    _tryLoadUser().then((value) => _user.add(value));
  }

  Stream<User?> observeUser() => _user.stream;

  Future<bool> isSignedIn() async => await user != null;

  Future<void> signIn(User user) async {
    _user.add(user);
    await _persistUser(user);
  }

  Future<void> signOut() async {
    _user.add(null);
    await _unsetUser();

    await _database.drop();
  }

  // TODO: Maybe change to simply update the whole user...
  //  (signing in and out is also not perfect for the methods above...)
  Future<void> setGoals(Goals goals) async {
    if (_user.value != null) {
      final user = _user.value!.copyWith(goals: goals);
      _user.add(user);
      await _persistUser(user);
    }
  }

  Future<User?> _tryLoadUser() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final encodedUser = sharedPreferences.getString(_userKey);
    if (encodedUser != null) {
      return _UserJson.fromJson(jsonDecode(encodedUser));
    }

    return null;
  }

  Future<void> _persistUser(User user) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final encodedUser = jsonEncode(user.toJson());
    await sharedPreferences.setString(_userKey, encodedUser);
  }

  Future<void> _unsetUser() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove(_userKey);
  }
}

extension _UserJson on User {
  static const _name = 'name';
  static const _gender = 'gender';
  static const _age = 'age';
  static const _height = 'height';
  static const _weight = 'weight';
  static const _bodyComposition = 'bodyComposition';
  static const _goals = 'goals';

  static User fromJson(Map<String, dynamic> json) => User(
        name: json[_name],
        gender: Gender.values.firstWhere((el) => el.name == json[_gender]),
        age: json[_age],
        height: json[_height],
        weight: json[_weight],
        bodyComposition: BodyComposition.values.firstWhere((el) => el.name == json[_bodyComposition]),
        goals: json.containsKey(_goals) ? _GoalsJson.fromJson(json[_goals]) : const Goals(),
      );

  Map<String, dynamic> toJson() => {
        _name: name,
        _gender: gender.name,
        _age: age,
        _height: height,
        _weight: weight,
        _bodyComposition: bodyComposition.name,
        _goals: goals.toJson(),
      };
}

extension _GoalsJson on Goals {
  static const _weeklyGramsOfAlcohol = 'weeklyGramsOfAlcohol';
  static const _weeklyDrinkFreeDays = 'weeklyDrinkFreeDays';

  static Goals fromJson(Map<String, dynamic> json) => Goals(
        weeklyGramsOfAlcohol: json[_weeklyGramsOfAlcohol],
        weeklyDrinkFreeDays: json[_weeklyDrinkFreeDays],
      );

  Map<String, dynamic> toJson() => {
        _weeklyGramsOfAlcohol: weeklyGramsOfAlcohol,
        _weeklyDrinkFreeDays: weeklyDrinkFreeDays,
      };
}
