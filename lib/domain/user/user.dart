import 'body_composition.dart';
import 'gender.dart';
import 'goals.dart';

class User {
  final String name;
  final Gender gender;
  final int age;

  /// In centimeters
  final int height;

  /// In kilograms
  final int weight;
  final BodyComposition bodyComposition;

  final Goals goals;

  User({
    required this.name,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.bodyComposition,
    this.goals = const Goals(),
  });

  User copyWith({
    int? age,
    int? height,
    int? weight,
    BodyComposition? bodyComposition,
    Goals? goals,
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
}
