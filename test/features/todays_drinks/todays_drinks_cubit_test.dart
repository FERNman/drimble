import 'package:drimble/domain/date.dart';
import 'package:drimble/features/todays_drinks/todays_drinks_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(TodaysDrinksCubitState, () {
    group('drinks', () {
      test('should be empty if there is no diary entry', () {
        final state = TodaysDrinksCubitState(date: Date.today(), diaryEntry: null);

        expect(state.drinks, isEmpty);
      });
    });
  });
}
