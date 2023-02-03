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
  const oneWeek = Duration(days: 7);

  group('AnalyticsCubit', () {
    final date = faker.date.dateTime().floorToWeek().floorToDay(hour: 6);
    final mockDrinksRepository = MockDrinksRepository();
    final mockDiaryRepository = MockDiaryRepository();

    setUp(() {
      when(mockDrinksRepository.findDrinksBetween(any, any)).thenAnswer((_) async => []);
      when(mockDiaryRepository.findEntriesBetween(any, any)).thenAnswer((_) async => []);
    });

    tearDown(() {
      resetMockitoState();
    });

    test('should set the correct date as the first day of the week', () {
      final date = faker.date.dateTime();
      final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, date: date);

      final firstDayOfWeek = date.subtract(Duration(days: date.weekday - 1)).floorToDay(hour: 6);
      expect(cubit.state.firstDayOfWeek, firstDayOfWeek);
      expect(cubit.state.firstDayOfWeek.weekday, 1);
    });

    test('should set the correct date as the last day of the week', () {
      final date = faker.date.dateTime();
      final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, date: date);

      final firstDayOfWeek = date.subtract(Duration(days: date.weekday - 1)).floorToDay(hour: 6);
      expect(cubit.state.lastDayOfWeek.weekday, 1); // Should be monday 6am again
      expect(cubit.state.lastDayOfWeek, firstDayOfWeek.add(oneWeek));
    });

    test('should calculate the grams of alcohol for the week', () async {
      final drinksOnFirstDay = [generateDrink(startTime: date), generateDrink(startTime: date)];
      final drinksOnThirdDay = [generateDrink(startTime: date.add(const Duration(days: 2)))];

      final drinks = [...drinksOnFirstDay, ...drinksOnThirdDay];
      when(mockDrinksRepository.findDrinksBetween(date, date.add(oneWeek))).thenAnswer((_) async => drinks);

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

    test('should calculate the total amount of alcohol consumed', () async {
      final drinks = [
        generateDrink(startTime: date),
        generateDrink(startTime: date),
        generateDrink(startTime: date),
      ];

      final diaryEntries = [generateDiaryEntry(date: date, isDrinkFreeDay: false)];

      when(mockDrinksRepository.findDrinksBetween(date, date.add(oneWeek))).thenAnswer((_) async => drinks);
      when(mockDiaryRepository.findEntriesBetween(date, date.add(oneWeek))).thenAnswer((_) async => diaryEntries);

      final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, date: date);
      await cubit.stream.first;

      final expectedGramsOfAlcohol = drinks.fold<double>(0.0, (total, el) => total + el.gramsOfAlcohol);
      expect(cubit.state.totalGramsOfAlcohol, expectedGramsOfAlcohol);
    });

    test('should calculate the amount of alcohol for last week', () async {
      final lastWeeksDrinks = [
        generateDrink(startTime: date.subtract(oneWeek)),
        generateDrink(startTime: date.subtract(oneWeek)),
        generateDrink(startTime: date.subtract(oneWeek)),
      ];

      when(mockDrinksRepository.findDrinksBetween(date.subtract(oneWeek), date))
          .thenAnswer((_) async => lastWeeksDrinks);

      final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, date: date);
      await cubit.stream.first;

      final expectedGramsOfAlcohol = lastWeeksDrinks.fold<double>(0.0, (total, el) => total + el.gramsOfAlcohol);
      expect(cubit.state.gramsOfAlcoholLastWeek, expectedGramsOfAlcohol);
    });

    test('should calculate the relative change in alcohol consumption compared to last week', () async {
      final drinks = [
        generateDrink(startTime: date),
        generateDrink(startTime: date),
        generateDrink(startTime: date),
      ];
      final diaryEntries = [generateDiaryEntry(date: date, isDrinkFreeDay: false)];
      final lastWeeksDrinks = [
        generateDrink(startTime: date.subtract(oneWeek)),
        generateDrink(startTime: date.subtract(oneWeek)),
        generateDrink(startTime: date.subtract(oneWeek)),
      ];

      when(mockDrinksRepository.findDrinksBetween(date, date.add(oneWeek))).thenAnswer((_) async => drinks);
      when(mockDiaryRepository.findEntriesBetween(date, date.add(oneWeek))).thenAnswer((_) async => diaryEntries);
      when(mockDrinksRepository.findDrinksBetween(date.subtract(oneWeek), date))
          .thenAnswer((_) async => lastWeeksDrinks);

      final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, date: date);
      await cubit.stream.first;

      final gramsOfAlcoholLastWeek = lastWeeksDrinks.fold<double>(0.0, (sum, el) => sum + el.gramsOfAlcohol);
      final gramsOfAlcoholThisWeek = drinks.fold<double>(0.0, (sum, el) => sum + el.gramsOfAlcohol);
      expect(cubit.state.changeToLastWeek, gramsOfAlcoholThisWeek / gramsOfAlcoholLastWeek);
    });

    test('should calculate a 100% increase if there was no alcohol consumed last week', () async {
      final drinks = [generateDrink(startTime: date)];
      final diaryEntries = [generateDiaryEntry(date: date, isDrinkFreeDay: false)];
      when(mockDrinksRepository.findDrinksBetween(date, date.add(oneWeek))).thenAnswer((_) async => drinks);
      when(mockDiaryRepository.findEntriesBetween(date, date.add(oneWeek))).thenAnswer((_) async => diaryEntries);
      when(mockDrinksRepository.findDrinksBetween(date.subtract(oneWeek), date)).thenAnswer((_) async => []);

      final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, date: date);
      await cubit.stream.first;

      expect(cubit.state.changeToLastWeek, 2);
    });
  });
}
