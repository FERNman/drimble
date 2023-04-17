import 'package:drimble/data/diary_repository.dart';
import 'package:drimble/domain/diary/consumed_cocktail.dart';
import 'package:drimble/features/edit_drink/edit_drink_cubit.dart';
import 'package:drimble/infra/extensions/copy_date_time.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import '../../generate_entities.dart';
import 'edit_drink_cubit_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DiaryRepository>()])
void main() {
  group(EditDrinkCubit, () {
    final date = faker.date.dateTime();

    test('should correctly update the date if the time is before 6am', () {
      final at10Am = date.copyWith(hour: 10);
      final drink = generateDrink(startTime: at10Am);
      final cubit = EditDrinkCubit.createDrink(MockDiaryRepository(), drink: drink);

      final at3am = date.copyWith(hour: 3);
      cubit.updateStartTime(at3am);

      expect(cubit.state.drink.startTime.day, at10Am.add(const Duration(days: 1)).day);
    });

    test('should not update the date if the start time was already before 6am', () {
      final at5Am = date.copyWith(hour: 5);
      final drink = generateDrink(startTime: at5Am);
      final cubit = EditDrinkCubit.createDrink(MockDiaryRepository(), drink: drink);

      final at3am = date.copyWith(hour: 3);
      cubit.updateStartTime(at3am);

      expect(cubit.state.drink.startTime.day, at5Am.day);
    });

    test('should reset the date if it was before 6am but is changed to after 6am', () {
      final at5Am = date.copyWith(hour: 5);
      final drink = generateDrink(startTime: at5Am);
      final cubit = EditDrinkCubit.createDrink(MockDiaryRepository(), drink: drink);

      final at12pm = date.copyWith(hour: 12);
      cubit.updateStartTime(at12pm);

      expect(cubit.state.drink.startTime.day, at5Am.subtract(const Duration(days: 1)).day);
    });

    group('Cocktails', () {
      test('should still be a cocktail after changing the amount', () {
        final drink = generateCocktail();
        final cubit = EditDrinkCubit.createDrink(MockDiaryRepository(), drink: drink);

        cubit.updateVolume(100);

        expect(cubit.state.drink, isA<ConsumedCocktail>());
      });

      test('should throw an exception when trying to change the percentage', () {
        final drink = generateCocktail();
        final cubit = EditDrinkCubit.createDrink(MockDiaryRepository(), drink: drink);

        expect(() => cubit.updatePercentage(50), throwsA(isA<AssertionError>()));
      });
    });
  });
}
