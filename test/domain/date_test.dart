import 'package:drimble/domain/date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(Date, () {
    test('should not shift the date when converting to and from DateTime', () {
      const date = Date(2021, 1, 1);
      expect(Date.fromDateTime(date.toDateTime()), date);
    });

    test('should set the hour to 6am when converting to DateTime', () {
      const date = Date(2021, 1, 1);
      expect(date.toDateTime().hour, 6);
    });

    test('should shift the date if created from a DateTime that is before 6am', () {
      final date = DateTime(2021, 1, 1, 5, 59, 59);
      expect(Date.fromDateTime(date), const Date(2020, 12, 31));
    });

    test('should not shift the date if created from a DateTime after 6am', () {
      final date = DateTime(2021, 1, 1, 6, 0, 0);
      expect(Date.fromDateTime(date), const Date(2021, 1, 1));
    });

    group('add', () {
      test('should add the specified days to the date', () {
        const date = Date(2021, 1, 1);
        expect(date.add(days: 1), const Date(2021, 1, 2));
      });

      test('should keep the date valid when adding days', () {
        const date = Date(2020, 12, 31);
        expect(date.add(days: 1), const Date(2021, 1, 1));
      });

      test('should handle leap years correctly', () {
        const date = Date(2020, 1, 1);
        expect(date.add(days: 366), const Date(2021, 1, 1));
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
