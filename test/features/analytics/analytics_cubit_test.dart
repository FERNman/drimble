import 'package:drimble/data/diary_repository.dart';
import 'package:drimble/data/drinks_repository.dart';
import 'package:drimble/features/analytics/analytics_cubit.dart';
import 'package:drimble/infra/extensions/floor_date_time.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../generate_entities.dart';
import 'analytics_cubit_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DrinksRepository>(), MockSpec<DiaryRepository>()])
void main() {
  group('AnalyticsCubit', () {
    test('should set the correct date as the start of the week', () {
      final mockDrinksRepository = MockDrinksRepository();
      when(mockDrinksRepository.findDrinksBetween(any, any)).thenAnswer((_) async => []);

      final mockDiaryRepository = MockDiaryRepository();
      when(mockDiaryRepository.findEntriesBetween(any, any)).thenAnswer((_) async => []);

      final date = faker.date.dateTime();
      final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, date: date);

      final weekStartDate = date.subtract(Duration(days: date.weekday - 1)).floorToDay(hour: 6);
      expect(cubit.state.startDate, weekStartDate);
      expect(cubit.state.endDate, weekStartDate.add(const Duration(days: 7)));
    });

    test('should calculate the grams of alcohol for the week', () async {
      final mockDrinksRepository = MockDrinksRepository();
      final mockDiaryRepository = MockDiaryRepository();

      final date = faker.date.dateTime().floorToWeek();

      final drinksOnFirstDay = [generateDrink(startTime: date), generateDrink(startTime: date)];
      final drinksOnThirdDay = [generateDrink(startTime: date.add(const Duration(days: 2)))];

      final drinks = [...drinksOnFirstDay, ...drinksOnThirdDay];
      when(mockDrinksRepository.findDrinksBetween(any, any)).thenAnswer((_) async => drinks);

      final diaryEntries = [
        generateDiaryEntry(date: date, isDrinkFreeDay: false),
        generateDiaryEntry(date: date.add(const Duration(days: 1)), isDrinkFreeDay: true), // day 2
        generateDiaryEntry(date: date.add(const Duration(days: 2)), isDrinkFreeDay: false), // day 3
        generateDiaryEntry(date: date.add(const Duration(days: 3)), isDrinkFreeDay: true), // day 4
        generateDiaryEntry(date: date.add(const Duration(days: 4)), isDrinkFreeDay: true), // day 5
      ];
      when(mockDiaryRepository.findEntriesBetween(any, any)).thenAnswer((_) async => diaryEntries);

      final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, date: date);

      final alcoholOnFirstDay = drinksOnFirstDay.fold<double>(0, (total, e) => total + e.gramsOfAlcohol);
      final alcoholOnThirdDay = drinksOnThirdDay.fold<double>(0, (total, e) => total + e.gramsOfAlcohol);

      await cubit.stream.first;
      expect(cubit.state.gramsOfAlcoholPerDay, [
        alcoholOnFirstDay, // 2 drinks
        0, // drink-free
        alcoholOnThirdDay, // 1 drink
        0, // drink-free
        0, // drink-free
        null, // untracked
        null, // untracked
      ]);
    });
  });
}
