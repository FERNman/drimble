import 'package:drimble/infra/extensions/to_string_as_float.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('double.ToStringAsFloat', () {
    test('should return the number without decimal places if its a full number', () {
      const value = 5.0;
      final formatted = value.toStringAsFloat(2);

      expect(formatted, value.toStringAsFixed(0));
    });

    test('should return the number with the given number of decimal places', () {
      const value = 5.1234;
      final formatted = value.toStringAsFloat(2);

      expect(formatted, value.toStringAsFixed(2));
    });

    test('should return the number with all the decimal places it contains', () {
      const value = 5.12;
      final formatted = value.toStringAsFloat(3);

      expect(formatted, value.toStringAsFixed(2));
    }, skip: true);
  });
}
