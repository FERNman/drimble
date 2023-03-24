import 'package:drimble/features/common/bac_format/bac_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(BacFormat, () {
    test('should format the number according to the given locale', () async {
      final bacFormat = BacFormat('en_US');
      expect(bacFormat.format(0.1234), '0.12%');
    });

    test('should remove the symbol if withSymbol is false', () async {
      final bacFormat = BacFormat('en_US');
      expect(bacFormat.format(0.1234, withSymbol: false), '0.12');
    });

    test('should round the last decimal place', () async {
      final bacFormat = BacFormat('en_US');
      expect(bacFormat.format(0.129), '0.13%');
    });

    test('should fall back to the language-level locale if the country postfix is given', () async {
      final bacFormat = BacFormat('de_DE');
      expect(bacFormat.format(0.1234), '1,23‰');
    });

    test('should use a default locale if none is given', () async {
      final bacFormat = BacFormat();
      expect(bacFormat.format(0.1), '0.1%');
    });
  });
}
