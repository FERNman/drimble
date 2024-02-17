import '../alcohol/alcohol.dart';
import '../user/gender.dart';
import '../user/user.dart';

extension UserBACExtensions on User {
  double get totalBodyWater {
    switch (gender) {
      case Gender.male:
        return 2.447 - (0.09516 * age) + (0.1074 * height) + (0.3352 * weight);
      case Gender.female:
        return -2.097 + (0.1069 * height) + (0.2466 * weight);
    }
  }

  /// The constant k1 describes the flux from the stomach to the small intestine
  /// 5.55 per hour for men, 4.96 per hour for women
  double get k1 {
    switch (gender) {
      case Gender.male:
        return 5.55;
      case Gender.female:
        return 4.96;
    }
  }

  /// The constant k2 describes the absorption of alcohol in the small intestine
  /// 7.05 per hour for men, 4.96 per hour for women
  double get k2 {
    switch (gender) {
      case Gender.male:
        return 7.05;
      case Gender.female:
        return 4.96;
    }
  }

  Percentage get _bloodWaterContent {
    switch (gender) {
      case Gender.male:
        return 0.825;
      case Gender.female:
        return 0.838;
    }
  }

  double get volumeOfDistribution => totalBodyWater;

  double rhoFactor() => totalBodyWater / weight / _bloodWaterContent;
}
