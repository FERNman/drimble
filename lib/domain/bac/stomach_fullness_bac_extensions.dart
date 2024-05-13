import '../diary/stomach_fullness.dart';

extension StomachFullnessBAC on StomachFullness {
  double get absorptionFactor {
    switch (this) {
      case StomachFullness.empty:
        return -0.6;
      case StomachFullness.litte:
        return 0.2;
      case StomachFullness.normal:
        return 0.42;
      case StomachFullness.full:
        return 0.8;
    }
  }
}