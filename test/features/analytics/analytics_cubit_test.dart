import 'package:collection/collection.dart';
import 'package:drimble/data/diary_repository.dart';
import 'package:drimble/data/drinks_repository.dart';
import 'package:drimble/data/user_repository.dart';
import 'package:drimble/domain/diary/drink.dart';
import 'package:drimble/features/analytics/analytics_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

import '../../generate_entities.dart';
import 'analytics_cubit_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DrinksRepository>(), MockSpec<DiaryRepository>(), MockSpec<UserRepository>()])
void main() {
  const oneWeekInDays = 7;

  group(AnalyticsCubit, () {
    final date = faker.date.date().floorToWeek();
    final user = generateUser();

    final mockDrinksRepository = MockDrinksRepository();
    final mockDiaryRepository = MockDiaryRepository();
    final mockUserRepository = MockUserRepository();

    setUp(() {
      when(mockDrinksRepository.observeDrinksBetweenDays(any, any)).thenAnswer((_) => Stream.value([]));
      when(mockDiaryRepository.observeEntriesBetween(any, any)).thenAnswer((_) => Stream.value([]));
      when(mockUserRepository.observeUser()).thenAnswer((_) => Stream.value(user));
    });

    tearDown(() {
      resetMockitoState();
    });

    test('should set the correct date as the first day of the week', () {
      final date = faker.date.date();
      final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);

      final firstDayOfWeek = date.subtract(days: date.weekday - 1);
      expect(cubit.state.firstDayOfWeek, firstDayOfWeek);
      expect(cubit.state.firstDayOfWeek.weekday, 1);
    });

    test('should set the correct date as the last day of the week', () {
      final date = faker.date.date();
      final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);

      final firstDayOfWeek = date.subtract(days: date.weekday - 1);
      expect(cubit.state.lastDayOfWeek.weekday, 1); // Should be monday
      expect(cubit.state.lastDayOfWeek, firstDayOfWeek.add(days: oneWeekInDays));
    });

    group('state.alcoholPerDayThisWeek', () {
      test('should equal the grams of alcohol in the current week', () async {
        final drinksOnFirstDay = [generateDrinkOnDate(date: date), generateDrinkOnDate(date: date)];
        final drinksOnThirdDay = [generateDrinkOnDate(date: date.add(days: 2))];

        final drinks = [...drinksOnFirstDay, ...drinksOnThirdDay];
        when(mockDrinksRepository.observeDrinksBetweenDays(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(drinks));

        final diaryEntries = [
          generateDiaryEntry(date: date, isDrinkFreeDay: false),
          generateDiaryEntry(date: date.add(days: 1), isDrinkFreeDay: true), // day 2
          generateDiaryEntry(date: date.add(days: 2), isDrinkFreeDay: false), // day 3
          generateDiaryEntry(date: date.add(days: 3), isDrinkFreeDay: true), // day 4
          generateDiaryEntry(date: date.add(days: 4), isDrinkFreeDay: true), // day 5
        ];
        when(mockDiaryRepository.observeEntriesBetween(any, any)).thenAnswer((_) => Stream.value(diaryEntries));

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        final alcoholOnFirstDay = drinksOnFirstDay.fold<double>(0.0, (total, e) => total + e.gramsOfAlcohol);
        final alcoholOnThirdDay = drinksOnThirdDay.fold<double>(0.0, (total, e) => total + e.gramsOfAlcohol);

        expect(cubit.state.alcoholByDay.values.toList(), [
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
          generateDiaryEntry(date: date.add(days: 1), isDrinkFreeDay: true),
        ]);

        when(mockDrinksRepository.observeDrinksBetweenDays(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => drinksSubject);
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => diaryEntriesSubject);

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(
          cubit.state.alcoholByDay.values.toList(),
          [0, 0, null, null, null, null, null],
        );

        final drink = generateDrinkOnDate(date: date);
        drinksSubject.add([drink]);
        await cubit.stream.first;

        expect(
          cubit.state.alcoholByDay.values.toList(),
          [drink.gramsOfAlcohol, 0, null, null, null, null, null],
        );
      });
    });

    group('state.totalAlcoholThisWeek', () {
      test('should equal the total amount of alcohol consumed', () async {
        final drinks = [
          generateDrinkOnDate(date: date),
          generateDrinkOnDate(date: date),
          generateDrinkOnDate(date: date),
        ];

        final diaryEntries = [generateDiaryEntry(date: date, isDrinkFreeDay: false)];

        when(mockDrinksRepository.observeDrinksBetweenDays(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(drinks));
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(diaryEntries));

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        final expectedGramsOfAlcohol = drinks.fold<double>(0.0, (total, el) => total + el.gramsOfAlcohol);
        expect(cubit.state.totalAlcohol, expectedGramsOfAlcohol);
      });
    });

    group('state.calories', () {
      test('should be equal to the sum of the calories of all drinks consumed this week', () async {
        final drinks = [
          generateDrinkOnDate(date: date),
          generateDrinkOnDate(date: date),
          generateDrinkOnDate(date: date),
        ];

        final diaryEntries = [generateDiaryEntry(date: date, isDrinkFreeDay: false)];

        when(mockDrinksRepository.observeDrinksBetweenDays(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(drinks));
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(diaryEntries));

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        final expectedCalories = drinks.fold<int>(0, (total, el) => total + el.calories);
        expect(cubit.state.calories, expectedCalories);
      });
    });

    group('state.numberOfDrinks', () {
      test('should be equal to the number of drinks consumed this week', () async {
        final drinks = [
          generateDrinkOnDate(date: date),
          generateDrinkOnDate(date: date),
          generateDrinkOnDate(date: date),
          generateDrinkOnDate(date: date.add(days: 1)),
          generateDrinkOnDate(date: date.add(days: 1)),
          generateDrinkOnDate(date: date.add(days: 2)),
        ];

        final diaryEntries = [
          generateDiaryEntry(date: date, isDrinkFreeDay: false),
          generateDiaryEntry(date: date.add(days: 1), isDrinkFreeDay: false),
          generateDiaryEntry(date: date.add(days: 2), isDrinkFreeDay: false),
        ];

        when(mockDrinksRepository.observeDrinksBetweenDays(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(drinks));
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(diaryEntries));

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(cubit.state.numberOfDrinks, drinks.length);
      });
    });

    group('state.averageAlcoholPerSession', () {
      test('should be the average alcohol per drinking session', () async {
        final drinks = [
          generateDrinkOnDate(date: date, alcoholByVolume: 0.5, volume: 500),
          generateDrinkOnDate(date: date, alcoholByVolume: 0.5, volume: 500),
          generateDrinkOnDate(date: date, alcoholByVolume: 0.5, volume: 500),
          generateDrinkOnDate(date: date.add(days: 1), alcoholByVolume: 0.5, volume: 500),
          generateDrinkOnDate(date: date.add(days: 1), alcoholByVolume: 0.5, volume: 500),
          generateDrinkOnDate(date: date.add(days: 2), alcoholByVolume: 0.5, volume: 500),
        ];
        final diaryEntries = [
          generateDiaryEntry(date: date, isDrinkFreeDay: false),
          generateDiaryEntry(date: date.add(days: 1), isDrinkFreeDay: false),
          generateDiaryEntry(date: date.add(days: 2), isDrinkFreeDay: false),
        ];

        when(mockDrinksRepository.observeDrinksBetweenDays(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(drinks));
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(diaryEntries));

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        final totalAlcohol = drinks.fold<double>(0.0, (total, el) => total + el.gramsOfAlcohol);
        final expectedAverageAlcoholPerSession = totalAlcohol / diaryEntries.length;
        expect(cubit.state.averageAlcoholPerSession, expectedAverageAlcoholPerSession);
      });
    });

    group('state.changeOfAverageAlcohol', () {
      test('should be the relative change in the average alcohol consumed compared to last week', () async {
        final lastWeeksDrinks = [
          generateDrinkOnDate(date: date.subtract(days: oneWeekInDays), alcoholByVolume: 0.5, volume: 500),
          generateDrinkOnDate(date: date.subtract(days: oneWeekInDays), alcoholByVolume: 0.5, volume: 500),
        ];
        final drinks = [
          generateDrinkOnDate(date: date, alcoholByVolume: 0.5, volume: 500),
          generateDrinkOnDate(date: date, alcoholByVolume: 0.5, volume: 500),
          generateDrinkOnDate(date: date, alcoholByVolume: 0.5, volume: 500),
        ];
        final diaryEntries = [generateDiaryEntry(date: date, isDrinkFreeDay: false)];

        when(mockDrinksRepository.observeDrinksBetweenDays(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(drinks));
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(diaryEntries));
        when(mockDrinksRepository.observeDrinksBetweenDays(date.subtract(days: oneWeekInDays), date))
            .thenAnswer((_) => Stream.value(lastWeeksDrinks));

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(cubit.state.changeOfAverageAlcohol, 0.5); // On average, we drank 50% more compared to last week
      });

      test('should be 0 if on average as much alcohol per session was consumed as last week', () async {
        final lastWeek = date.subtract(days: oneWeekInDays);
        final lastWeeksDrinks = [
          generateDrinkOnDate(date: lastWeek, alcoholByVolume: 0.5, volume: 500),
          generateDrinkOnDate(date: lastWeek.add(days: 1), alcoholByVolume: 0.5, volume: 500),
        ];
        final drinks = [
          generateDrinkOnDate(date: date, alcoholByVolume: 0.5, volume: 500),
          generateDrinkOnDate(date: date.add(days: 1), alcoholByVolume: 0.5, volume: 500),
          generateDrinkOnDate(date: date.add(days: 2), alcoholByVolume: 0.5, volume: 500),
        ];
        final diaryEntries = [
          generateDiaryEntry(date: date, isDrinkFreeDay: false),
          generateDiaryEntry(date: date.add(days: 1), isDrinkFreeDay: false),
          generateDiaryEntry(date: date.add(days: 2), isDrinkFreeDay: false),
        ];

        when(mockDrinksRepository.observeDrinksBetweenDays(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(drinks));
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(diaryEntries));
        when(mockDrinksRepository.observeDrinksBetweenDays(lastWeek, date))
            .thenAnswer((_) => Stream.value(lastWeeksDrinks));

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(cubit.state.changeOfAverageAlcohol, 0); // On average, we drank the same as last week
      });

      test('should be 1 if there was no alcohol consumed last week, but this week', () async {
        final drinks = [generateDrinkOnDate(date: date)];
        final diaryEntries = [generateDiaryEntry(date: date, isDrinkFreeDay: false)];
        when(mockDrinksRepository.observeDrinksBetweenDays(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(drinks));
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(diaryEntries));
        when(mockDrinksRepository.observeDrinksBetweenDays(date.subtract(days: oneWeekInDays), date))
            .thenAnswer((_) => Stream.value([]));

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(cubit.state.changeOfAverageAlcohol, 1);
      });

      test('should be -1 if there was no alcohol consumed this week, but last week', () async {
        final diaryEntries = [generateDiaryEntry(date: date, isDrinkFreeDay: false)];
        when(mockDrinksRepository.observeDrinksBetweenDays(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value([]));
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(diaryEntries));

        final lastWeeksDrinks = [generateDrinkOnDate(date: date)];
        when(mockDrinksRepository.observeDrinksBetweenDays(date.subtract(days: oneWeekInDays), date))
            .thenAnswer((_) => Stream.value(lastWeeksDrinks));

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(cubit.state.changeOfAverageAlcohol, -1);
      });

      test('should be 0 if there was neither alcohol consumed this week nor last week', () async {
        final diaryEntries = [generateDiaryEntry(date: date, isDrinkFreeDay: true)];
        when(mockDrinksRepository.observeDrinksBetweenDays(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value([]));
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(diaryEntries));
        when(mockDrinksRepository.observeDrinksBetweenDays(date.subtract(days: oneWeekInDays), date))
            .thenAnswer((_) => Stream.value([]));

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(cubit.state.changeOfAverageAlcohol, 0);
      });
    });

    group('state.drinkFreeDays', () {
      test('should equal the diary entries and corresponding drinks', () async {
        final diaryEntries = [
          generateDiaryEntry(date: date, isDrinkFreeDay: true),
          generateDiaryEntry(date: date.add(days: 1), isDrinkFreeDay: false),
          generateDiaryEntry(date: date.add(days: 2), isDrinkFreeDay: true),
          generateDiaryEntry(date: date.add(days: 3), isDrinkFreeDay: true),
          generateDiaryEntry(date: date.add(days: 4), isDrinkFreeDay: true),
          generateDiaryEntry(date: date.add(days: 5), isDrinkFreeDay: true),
          generateDiaryEntry(date: date.add(days: 6), isDrinkFreeDay: true),
        ];
        final drinks = diaryEntries
            .map((e) => e.isDrinkFreeDay ? null : generateDrinkOnDate(date: e.date))
            .whereNotNull()
            .toList();

        when(mockDrinksRepository.observeDrinksBetweenDays(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(drinks));
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(diaryEntries));

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(cubit.state.drinkFreeDays, diaryEntries.groupFoldBy((el) => el.date, (_, el) => el.isDrinkFreeDay));
      });

      test('should not count days without a diary entry', () async {
        final diaryEntries = [
          generateDiaryEntry(date: date, isDrinkFreeDay: true),
          generateDiaryEntry(date: date.add(days: 1), isDrinkFreeDay: false),
          generateDiaryEntry(date: date.add(days: 2), isDrinkFreeDay: true),
          generateDiaryEntry(date: date.add(days: 5), isDrinkFreeDay: true),
        ];
        final drinks = [
          generateDrinkOnDate(date: date.add(days: 1)),
        ];

        when(mockDrinksRepository.observeDrinksBetweenDays(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(drinks));
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(diaryEntries));

        final cubit = AnalyticsCubit(mockDrinksRepository, mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(cubit.state.drinkFreeDays.values.toList(), [
          true, // Mo
          false, // Tu
          true, // We
          null, // Th
          null, // Fr
          true, // Sa
          null, // Su
        ]);
      });
    });
  });
}
