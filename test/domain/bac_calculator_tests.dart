import 'package:drinkaware/domain/bac_calculator.dart';
import 'package:drinkaware/domain/drink/alcohol.dart';
import 'package:drinkaware/domain/drink/beverage.dart';
import 'package:drinkaware/domain/drink/consumed_drink.dart';
import 'package:drinkaware/domain/user/body_composition.dart';
import 'package:drinkaware/domain/user/gender.dart';
import 'package:drinkaware/domain/user/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BAC Calculator', () {
    final DateTime timestamp = DateTime.now().subtract(const Duration(minutes: 60));
    final user = User(
      age: 22,
      gender: Gender.male,
      bodyComposition: BodyComposition.average,
      height: 178,
      name: 'Test',
      weight: 88,
    );

    group('for a sole beverage', () {
      final beer = ConsumedDrink.fromBeverage(Beverage.beer);

      test('should be zero initially', () {
        final drinks = [beer.copyWith(startTime: timestamp)];

        final bac = BacCalculator.calculateBACAt(user, drinks, timestamp);
        expect(bac, 0.0);
      });

      test('should have ingested the full amount after the duration of the drink', () {
        final drinks = [beer.copyWith(startTime: timestamp.subtract(beer.duration))];

        final bac = BacCalculator.calculateBACAt(user, drinks, timestamp);
        expect(bac, beer.alcoholByVolume * beer.volume * Alcohol.density);
      });
    });
  });
}
