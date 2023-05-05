import 'body_composition.dart';
import 'gender.dart';
import 'goals.dart';

class User {
  final String name;
  final Gender gender;
  final int age;
  final int height; // In centimeters
  final int weight; // In kilograms
  final BodyComposition bodyComposition;

  final Goals goals;

  double get totalBodyWater {
    switch (gender) {
      case Gender.male:
        return 2.447 - (0.09516 * age) + (0.1074 * height) + (0.3352 * weight);
      case Gender.female:
        return -2.097 + (0.1069 * height) + (0.2466 * weight);
    }
  }

  double get bloodWaterContent {
    switch (gender) {
      case Gender.male:
        return 0.825;
      case Gender.female:
        return 0.838;
    }
  }

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
