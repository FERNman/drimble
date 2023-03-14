import 'dart:convert';

import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../domain/user/body_composition.dart';
import '../domain/user/gender.dart';
import '../domain/user/user.dart';
import '../domain/user/weekly_goals.dart';
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

  void signIn(User user) async {
    _user.add(user);
    await _persistUser(user);
  }

  void signOut() async {
    _user.add(null);
    await _unsetUser();

    await _database.drop();
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
  static const _weeklyGoals = 'weeklyGoals';

  static User fromJson(Map<String, dynamic> json) => User(
        name: json[_name],
        gender: Gender.values.firstWhere((el) => el.name == json[_gender]),
        age: json[_age],
        height: json[_height],
        weight: json[_weight],
        bodyComposition: BodyComposition.values.firstWhere((el) => el.name == json[_bodyComposition]),
        weeklyGoals:
            json.containsKey(_weeklyGoals) ? _WeeklyGoalsJson.fromJson(json[_weeklyGoals]) : const WeeklyGoals(),
      );

  Map<String, dynamic> toJson() => {
        _name: name,
        _gender: gender.name,
        _age: age,
        _height: height,
        _weight: weight,
        _bodyComposition: bodyComposition.name,
        _weeklyGoals: weeklyGoals.toJson(),
      };
}

extension _WeeklyGoalsJson on WeeklyGoals {
  static const _gramsOfAlcohol = 'gramsOfAlcohol';
  static const _drinkFreeDays = 'drinkFreeDays';

  static WeeklyGoals fromJson(Map<String, dynamic> json) => WeeklyGoals(
        gramsOfAlcohol: json[_gramsOfAlcohol],
        drinkFreeDays: json[_drinkFreeDays],
      );

  Map<String, dynamic> toJson() => {
        _gramsOfAlcohol: gramsOfAlcohol,
        _drinkFreeDays: drinkFreeDays,
      };
}
