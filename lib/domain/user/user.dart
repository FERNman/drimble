import 'body_composition.dart';
import 'gender.dart';

class User {
  String name;
  Gender gender;
  int age;
  int height; // In centimeters
  int weight; // In kilograms
  BodyComposition bodyComposition;

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
  });

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        gender = Gender.values.firstWhere((el) => el.name == json['gender']),
        age = json['age'],
        height = json['height'],
        weight = json['weight'],
        bodyComposition = BodyComposition.values.firstWhere((el) => el.name == json['bodyComposition']);

  Map<String, dynamic> toJson() => {
        'name': name,
        'gender': gender.name,
        'age': age,
        'height': height,
        'weight': weight,
        'bodyComposition': bodyComposition.name
      };
}
