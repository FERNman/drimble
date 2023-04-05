import 'package:drimble/domain/date.dart';
import 'package:drimble/infra/extensions/set_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(Date, () {
    group('add', () {
      test('should add the specified days to the date', () {
        const date = Date(2021, 1, 1);
        expect(date.add(days: 1), const Date(2021, 1, 2));
      });

      test('should keep the date valid when adding days', () {
        const date = Date(2020, 12, 31);
        expect(date.add(days: 1), const Date(2021, 1, 1));
      });
    });

    group('subtract', () {
      test('should subtract the specified days from the date', () {
        const date = Date(2021, 1, 2);
        expect(date.subtract(days: 1), const Date(2021, 1, 1));
      });

      test('should keep the date valid when subtracting days', () {
        const date = Date(2021, 1, 1);
        expect(date.subtract(days: 1), const Date(2020, 12, 31));
      });
    });

    group('Timezones', () {
      test('should not shift a DateTime setDate is called with a timezone difference', () {
        final date = DateTime(2021, 1, 1).setDate(DateTime.utc(2021, 1, 2));
        expect(date, DateTime(2021, 1, 2));
      });
    });
  });

  group('DateTime.toDate', () {
    test('should shift the date to the previous day if is before 6am', () {
      final date = DateTime(2021, 1, 1, 5, 59, 59);
      expect(date.toDate(), const Date(2020, 12, 31));
    });

    test('should not shift the date if it is after 6am', () {
      final date = DateTime(2021, 1, 1, 6, 0, 0);
      expect(date.toDate(), const Date(2021, 1, 1));
    });
  });
}
