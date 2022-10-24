import 'package:drimble/data/consumed_drinks_repository.dart';
import 'package:drimble/domain/alcohol/beverages.dart';
import 'package:drimble/domain/diary/consumed_drink.dart';
import 'package:drimble/features/consumed_drink/consumed_drink_cubit.dart';
import 'package:drimble/infra/extensions/copy_date_time.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'consumed_drink_cubit_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ConsumedDrinksRepository>()])
void main() {
  group('ConsumedDrinkCubit', () {
    final date = DateTime(2000, 1, 2);

    test('should correctly update the date if the time is before 6am', () {
      final at10Am = date.copyWith(hour: 10);
      final drink = ConsumedDrink.fromBeverage(Beverages.beer).copyWith(startTime: at10Am);
      final cubit = ConsumedDrinkCubit.createDrink(MockConsumedDrinksRepository(), drink: drink);

      final copyWith = date.copyWith(hour: 3);
      final updatedDrink = drink.copyWith(startTime: copyWith);
      cubit.update(updatedDrink);

      expect(cubit.state.drink.startTime.day, at10Am.day + 1);
    });

    test('should not update the date if the start time was already before 6am', () {
      final at5Am = date.copyWith(hour: 5);
      final drink = ConsumedDrink.fromBeverage(Beverages.beer).copyWith(startTime: at5Am);
      final cubit = ConsumedDrinkCubit.createDrink(MockConsumedDrinksRepository(), drink: drink);

      final at3am = date.copyWith(hour: 3);
      final updatedDrink = drink.copyWith(startTime: at3am);
      cubit.update(updatedDrink);

      expect(cubit.state.drink.startTime.day, at5Am.day);
    });

    test('should reset the date if it was before 6am but is changed to after 6am', () {
      final at5Am = date.copyWith(hour: 5);
      final drink = ConsumedDrink.fromBeverage(Beverages.beer).copyWith(startTime: at5Am);
      final cubit = ConsumedDrinkCubit.createDrink(MockConsumedDrinksRepository(), drink: drink);

      final at12pm = date.copyWith(hour: 12);
      final updatedDrink = drink.copyWith(startTime: at12pm);
      cubit.update(updatedDrink);

      expect(cubit.state.drink.startTime.day, at5Am.day - 1);
    });
  });
}
