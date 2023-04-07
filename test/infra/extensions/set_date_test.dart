import 'package:drimble/infra/extensions/set_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('set_date_test', () {
    test('should not shift a DateTime setDate is called with a timezone difference', () {
      final date = DateTime(2021, 1, 1).setDate(DateTime.utc(2021, 1, 2));
      expect(date, DateTime(2021, 1, 2));
    });
  });
}
