import 'package:drimble/features/common/line_chart/nice_double.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NiceDouble', () {
    test('should return 0.5 if the number is between 0 and 0.5', () {
      final nice = 0.32.ceilToNiceDouble();
      expect(nice, 0.5);
    });

    test('should return 1.5 if the number is between 1 and 1.5', () {
      final nice = 1.27.ceilToNiceDouble();
      expect(nice, 1.5);
    });

    test('should always round away from 0', () {
      final nice = 2.01.ceilToNiceDouble();
      expect(nice, 2.5);
    });
  });
}
