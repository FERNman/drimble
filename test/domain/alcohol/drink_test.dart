import 'package:drimble/domain/alcohol/drink.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../generate_entities.dart';

void main() {
  group(Drink, () {
    test('should use the first default serving as the volume', () {
      final drink = generateDrink();

      expect(drink.volume, drink.defaultServings.first);
    });
  });
}
