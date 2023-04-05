import 'package:drimble/infra/extensions/shift_date_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShiftDateTime', () {
    test('should shift the date to the previous day if is before 6am', () {
      final date = DateTime(2021, 1, 1, 5, 59, 59);
      expect(date.shift(), DateTime(2020, 12, 31));
    });

    test('should not shift the date if it is after 6am', () {
      final date = DateTime(2021, 1, 1, 6, 0, 0);
      expect(date.shift(), DateTime(2021, 1, 1));
    });
  });
}
