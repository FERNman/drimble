import 'package:json_annotation/json_annotation.dart';

import 'body_composition.dart';
import 'gender.dart';
import 'user_goals.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  final String name;

  final Gender gender;
  final int age;

  /// In centimeters
  final int height;

  /// In kilograms
  final int weight;
  final BodyComposition bodyComposition;

  final UserGoals goals;

  User({
    required this.name,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.bodyComposition,
    this.goals = const UserGoals(),
  });

  User copyWith({
    int? age,
    int? height,
    int? weight,
    BodyComposition? bodyComposition,
    UserGoals? goals,
  }) =>
      User(
        name: name,
        gender: gender,
        age: age ?? this.age,
        height: height ?? this.height,
        weight: weight ?? this.weight,
        bodyComposition: bodyComposition ?? this.bodyComposition,
        goals: goals ?? this.goals,
      );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
