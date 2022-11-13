import 'package:drimble/data/drinks_repository.dart';
import 'package:drimble/domain/alcohol/drink_category.dart';
import 'package:drimble/domain/diary/drink.dart';
import 'package:drimble/domain/diary/stomach_fullness.dart';
import 'package:drimble/features/edit_drink/edit_drink_cubit.dart';
import 'package:drimble/infra/extensions/copy_date_time.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'edit_drink_cubit_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DrinksRepository>()])
void main() {
  group('EditDrinkCubit', () {
    final date = DateTime(2000, 1, 2);

    test('should correctly update the date if the time is before 6am', () {
      final at10Am = date.copyWith(hour: 10);
      final drink = Drink(
        id: 1,
        name: 'Beer',
        icon: 'test',
        category: DrinkCategory.beer,
        volume: 500,
        alcoholByVolume: 0.05,
        startTime: at10Am,
        duration: const Duration(hours: 1),
        stomachFullness: StomachFullness.full,
      );
      final cubit = EditDrinkCubit.createDrink(MockDrinksRepository(), drink: drink);

      final at3am = date.copyWith(hour: 3);
      cubit.updateStartTime(at3am);

      expect(cubit.state.drink.startTime.day, at10Am.day + 1);
    });

    test('should not update the date if the start time was already before 6am', () {
      final at5Am = date.copyWith(hour: 5);
      final drink = Drink(
        id: 1,
        name: 'Beer',
        icon: 'test',
        category: DrinkCategory.beer,
        volume: 500,
        alcoholByVolume: 0.05,
        startTime: at5Am,
        duration: const Duration(hours: 1),
        stomachFullness: StomachFullness.full,
      );
      final cubit = EditDrinkCubit.createDrink(MockDrinksRepository(), drink: drink);

      final at3am = date.copyWith(hour: 3);
      cubit.updateStartTime(at3am);

      expect(cubit.state.drink.startTime.day, at5Am.day);
    });

    test('should reset the date if it was before 6am but is changed to after 6am', () {
      final at5Am = date.copyWith(hour: 5);
      final drink = Drink(
        id: 1,
        name: 'Beer',
        icon: 'test',
        category: DrinkCategory.beer,
        volume: 500,
        alcoholByVolume: 0.05,
        startTime: at5Am,
        duration: const Duration(hours: 1),
        stomachFullness: StomachFullness.full,
      );
      final cubit = EditDrinkCubit.createDrink(MockDrinksRepository(), drink: drink);

      final at12pm = date.copyWith(hour: 12);
      cubit.updateStartTime(at12pm);

      expect(cubit.state.drink.startTime.day, at5Am.day - 1);
    });
  });
}
