import 'dart:math';

extension StringExtensions on double {
  String toStringAsFloat(int maximumDecimalPlaces) {
    final scaling = pow(10, maximumDecimalPlaces);
    if ((this * scaling) % scaling == 0) {
      return toStringAsFixed(0);
    }

    return toStringAsFixed(maximumDecimalPlaces);
  }
}
