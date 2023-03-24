import 'body_composition.dart';
import 'gender.dart';
import 'goals.dart';

class User {
  static const bloodPerMass = 0.067;

  String name;
  Gender gender;
  int age;
  int height; // In centimeters
  int weight; // In kilograms
  BodyComposition bodyComposition;

  Goals goals;

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

  User copyWith({Goals? goals}) => User(
        name: name,
        gender: gender,
        age: age,
        height: height,
        weight: weight,
        bodyComposition: bodyComposition,
        goals: goals ?? this.goals,
      );
}
