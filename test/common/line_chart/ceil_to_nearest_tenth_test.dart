import 'package:drimble/features/common/line_chart/ceil_to_nearest_tenth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CeilToNearestTenth', () {
    test('should return 0.1 if the number is between 0 and 0.05', () {
      final nice = 0.032.ceilToNearestTenth();
      expect(nice, 0.1);
    });

    test('should return 0.2 if the number is between 0.1 and 0.15', () {
      final nice = 0.127.ceilToNearestTenth();
      expect(nice, 0.2);
    });

    test('should always round away from 0', () {
      final nice = 0.201.ceilToNearestTenth();
      expect(nice, 0.3);
    });
  });
}
