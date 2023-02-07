import 'package:drimble/data/diary_repository.dart';
import 'package:drimble/data/drinks_repository.dart';
import 'package:drimble/data/user_repository.dart';
import 'package:drimble/domain/diary/drink.dart';
import 'package:drimble/features/analytics/analytics_cubit.dart';
import 'package:drimble/infra/extensions/floor_date_time.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

import '../../generate_entities.dart';
import 'analytics_cubit_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DrinksRepository>(), MockSpec<DiaryRepository>(), MockSpec<UserRepository>()])
void main() {
  const oneWeek = Duration(days: 7);

  group('AnalyticsCubit', () {
    final date = faker.date.dateTime().floorToWeek().floorToDay(hour: 6);
    final user = generateUser();

    final mockDrinksRepository = MockDrinksRepository();
    final mockDiaryRepository = MockDiaryRepository();
    final mockUserRepository = MockUserRepository();

    setUp(() {
      when(mockDrinksRepository.observeDrinksBetween(any, any)).thenAnswer((_) => Stream.value([]));
      when(mockDiaryRepository.observeEntriesBetween(any, any)).thenAnswer((_) => Stream.value([]));
      when(mockUserRepository.user).thenAnswer((_) async => user);
    });

    tearDown(() {
      resetMockitoState();
    });

    test('should set the correct date as the first day of the week', () {
      final date = faker.date.dateTime();
      final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);

      final firstDayOfWeek = date.subtract(Duration(days: date.weekday - 1)).floorToDay(hour: 6);
      expect(cubit.state.firstDayOfWeek, firstDayOfWeek);
      expect(cubit.state.firstDayOfWeek.weekday, 1);
    });

    test('should set the correct date as the last day of the week', () {
      final date = faker.date.dateTime();
      final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);

      final firstDayOfWeek = date.subtract(Duration(days: date.weekday - 1)).floorToDay(hour: 6);
      expect(cubit.state.lastDayOfWeek.weekday, 1); // Should be monday 6am again
      expect(cubit.state.lastDayOfWeek, firstDayOfWeek.add(oneWeek));
    });

    group('state.gramsOfAlcoholPerDay', () {
      test('should equal the grams of alcohol in the current week', () async {
        final drinksOnFirstDay = [generateDrink(startTime: date), generateDrink(startTime: date)];
        final drinksOnThirdDay = [generateDrink(startTime: date.add(const Duration(days: 2)))];

        final drinks = [...drinksOnFirstDay, ...drinksOnThirdDay];
        when(mockDrinksRepository.observeDrinksBetween(date, date.add(oneWeek)))
            .thenAnswer((_) => Stream.value(drinks));

        final diaryEntries = [
          generateDiaryEntry(date: date, isDrinkFreeDay: false),
          generateDiaryEntry(date: date.add(const Duration(days: 1)), isDrinkFreeDay: true), // day 2
          generateDiaryEntry(date: date.add(const Duration(days: 2)), isDrinkFreeDay: false), // day 3
          generateDiaryEntry(date: date.add(const Duration(days: 3)), isDrinkFreeDay: true), // day 4
          generateDiaryEntry(date: date.add(const Duration(days: 4)), isDrinkFreeDay: true), // day 5
        ];
        when(mockDiaryRepository.observeEntriesBetween(any, any)).thenAnswer((_) => Stream.value(diaryEntries));

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        final alcoholOnFirstDay = drinksOnFirstDay.fold<double>(0, (total, e) => total + e.gramsOfAlcohol);
        final alcoholOnThirdDay = drinksOnThirdDay.fold<double>(0, (total, e) => total + e.gramsOfAlcohol);

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

      // Needed because the streams in RxDart emit one-by-one, so we cannot expect the two streams to always be in sync
      test('should not throw if diary entries and drinks are out of sync', () async {
        final drinksSubject = BehaviorSubject.seeded(<Drink>[]);
        final diaryEntriesSubject = BehaviorSubject.seeded([
          generateDiaryEntry(date: date, isDrinkFreeDay: false),
          generateDiaryEntry(date: date.add(const Duration(days: 1)), isDrinkFreeDay: true),
        ]);

        when(mockDrinksRepository.observeDrinksBetween(date, date.add(oneWeek))).thenAnswer((_) => drinksSubject);
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(oneWeek))).thenAnswer((_) => diaryEntriesSubject);

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(cubit.state.didDrink, false);

        drinksSubject.add([generateDrink(startTime: date)]);
        await cubit.stream.elementAt(1);

        expect(cubit.state.didDrink, true);
      });
    });

    group('state.totalGramsOfAlcohol', () {
      test('should equal the total amount of alcohol consumed', () async {
        final drinks = [
          generateDrink(startTime: date),
          generateDrink(startTime: date),
          generateDrink(startTime: date),
        ];

        final diaryEntries = [generateDiaryEntry(date: date, isDrinkFreeDay: false)];

        when(mockDrinksRepository.observeDrinksBetween(date, date.add(oneWeek)))
            .thenAnswer((_) => Stream.value(drinks));
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(oneWeek)))
            .thenAnswer((_) => Stream.value(diaryEntries));

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        final expectedGramsOfAlcohol = drinks.fold<double>(0.0, (total, el) => total + el.gramsOfAlcohol);
        expect(cubit.state.totalGramsOfAlcohol, expectedGramsOfAlcohol);
      });
    });

    group('state.gramsOfAlcoholLastWeek', () {
      test('should calculate the amount of alcohol for last week', () async {
        final lastWeeksDrinks = [
          generateDrink(startTime: date.subtract(oneWeek)),
          generateDrink(startTime: date.subtract(oneWeek)),
          generateDrink(startTime: date.subtract(oneWeek)),
        ];

        when(mockDrinksRepository.observeDrinksBetween(date.subtract(oneWeek), date))
            .thenAnswer((_) => Stream.value(lastWeeksDrinks));

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        final expectedGramsOfAlcohol = lastWeeksDrinks.fold<double>(0.0, (total, el) => total + el.gramsOfAlcohol);
        expect(cubit.state.gramsOfAlcoholLastWeek, expectedGramsOfAlcohol);
      });
    });

    group('state.changeToLastWeek', () {
      test('should be the relative change in alcohol consumption compared to last week', () async {
        final lastWeeksDrinks = [
          generateDrink(startTime: date.subtract(oneWeek), alcoholByVolume: 0.5, volume: 500),
          generateDrink(startTime: date.subtract(oneWeek), alcoholByVolume: 0.5, volume: 500),
        ];
        final drinks = [
          generateDrink(startTime: date, alcoholByVolume: 0.5, volume: 500),
          generateDrink(startTime: date, alcoholByVolume: 0.5, volume: 500),
          generateDrink(startTime: date, alcoholByVolume: 0.5, volume: 500),
        ];
        final diaryEntries = [generateDiaryEntry(date: date, isDrinkFreeDay: false)];

        when(mockDrinksRepository.observeDrinksBetween(date, date.add(oneWeek)))
            .thenAnswer((_) => Stream.value(drinks));
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(oneWeek)))
            .thenAnswer((_) => Stream.value(diaryEntries));
        when(mockDrinksRepository.observeDrinksBetween(date.subtract(oneWeek), date))
            .thenAnswer((_) => Stream.value(lastWeeksDrinks));

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(cubit.state.changeToLastWeek, 0.5); // We drank 50% more this week
      });

      test('should be 1 if there was no alcohol consumed last week, but this week', () async {
        final drinks = [generateDrink(startTime: date)];
        final diaryEntries = [generateDiaryEntry(date: date, isDrinkFreeDay: false)];
        when(mockDrinksRepository.observeDrinksBetween(date, date.add(oneWeek)))
            .thenAnswer((_) => Stream.value(drinks));
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(oneWeek)))
            .thenAnswer((_) => Stream.value(diaryEntries));
        when(mockDrinksRepository.observeDrinksBetween(date.subtract(oneWeek), date))
            .thenAnswer((_) => Stream.value([]));

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(cubit.state.changeToLastWeek, 1);
      });

      test('should be -1 if there was no alcohol consumed this week, but last week', () async {
        final diaryEntries = [generateDiaryEntry(date: date, isDrinkFreeDay: false)];
        when(mockDrinksRepository.observeDrinksBetween(date, date.add(oneWeek))).thenAnswer((_) => Stream.value([]));
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(oneWeek)))
            .thenAnswer((_) => Stream.value(diaryEntries));

        final lastWeeksDrinks = [generateDrink(startTime: date)];
        when(mockDrinksRepository.observeDrinksBetween(date.subtract(oneWeek), date))
            .thenAnswer((_) => Stream.value(lastWeeksDrinks));

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(cubit.state.changeToLastWeek, -1);
      });

      test('should be 0 if there was neither alcohol consumed this week nor last week', () async {
        final diaryEntries = [generateDiaryEntry(date: date, isDrinkFreeDay: true)];
        when(mockDrinksRepository.observeDrinksBetween(date, date.add(oneWeek))).thenAnswer((_) => Stream.value([]));
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(oneWeek)))
            .thenAnswer((_) => Stream.value(diaryEntries));
        when(mockDrinksRepository.observeDrinksBetween(date.subtract(oneWeek), date))
            .thenAnswer((_) => Stream.value([]));

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(cubit.state.changeToLastWeek, 0);
      });
    });

    group('state.didDrink', () {
      test('should correctly indicate if the user drank no alcohol', () async {
        final diaryEntries = [generateDiaryEntry(date: date, isDrinkFreeDay: true)];

        when(mockDrinksRepository.observeDrinksBetween(date, date.add(oneWeek))).thenAnswer((_) => Stream.value([]));
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(oneWeek)))
            .thenAnswer((_) => Stream.value(diaryEntries));

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(cubit.state.didDrink, false);
      });

      test('should correclty indicate if the user drank alcohol', () async {
        final drinks = [generateDrink(startTime: date)];

        final diaryEntries = [
          generateDiaryEntry(date: date, isDrinkFreeDay: false),
          generateDiaryEntry(date: date.add(const Duration(days: 1)), isDrinkFreeDay: true),
        ];

        when(mockDrinksRepository.observeDrinksBetween(date, date.add(oneWeek)))
            .thenAnswer((_) => Stream.value(drinks));
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(oneWeek)))
            .thenAnswer((_) => Stream.value(diaryEntries));

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(cubit.state.didDrink, true);
      });
    });
  });
}
