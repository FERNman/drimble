import 'package:drimble/data/drinks_repository.dart';
import 'package:drimble/features/search_drink/search_drink_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../generate_entities.dart';
import 'search_drink_cubit_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DrinksRepository>()])
void main() {
  group(SearchDrinkState, () {
    test('should initially emit a list of results', () {
      final mockDrinksRepository = MockDrinksRepository();

      final drinks = [generateDrink(), generateDrink(), generateDrink()];

      when(mockDrinksRepository.searchDrinksByName(any)).thenReturn(drinks);

      final cubit = SearchDrinkCubit(mockDrinksRepository);

      expect(cubit.state.results, drinks);
    });

    group('setSearch', () {
      test('should search for drinks', () async {
        final mockDrinksRepository = MockDrinksRepository();
        final drinks = [generateDrink(), generateDrink(), generateDrink()];

        const searchString = 'search';
        when(mockDrinksRepository.searchDrinksByName(searchString)).thenReturn(drinks);

        final cubit = SearchDrinkCubit(mockDrinksRepository);

        cubit.setSearch(searchString);
        await cubit.stream.first;

        await expectLater(cubit.state.results, drinks);
      });
    });
  });
}
