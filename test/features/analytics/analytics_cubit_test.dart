import 'package:collection/collection.dart';
import 'package:drimble/data/diary_repository.dart';
import 'package:drimble/data/user_repository.dart';
import 'package:drimble/domain/date.dart';
import 'package:drimble/features/analytics/analytics_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../generate_entities.dart';
import 'analytics_cubit_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DiaryRepository>(), MockSpec<UserRepository>()])
void main() {
  const oneWeekInDays = 7;

  group(AnalyticsCubit, () {
    final date = faker.date.date().floorToWeek();
    final user = generateUser();

    final mockDiaryRepository = MockDiaryRepository();
    final mockUserRepository = MockUserRepository();

    setUp(() {
      when(mockDiaryRepository.observeEntriesBetween(any, any)).thenAnswer((_) => Stream.value([]));
      when(mockUserRepository.observeUser()).thenAnswer((_) => Stream.value(user));
    });

    tearDown(() {
      resetMockitoState();
    });

    test('should set the correct date as the first day of the week', () {
      final date = faker.date.date();
      final cubit = AnalyticsCubit(mockDiaryRepository, mockUserRepository, date: date);

      final firstDayOfWeek = date.subtract(days: date.weekday - 1);
      expect(cubit.state.firstDayOfWeek, firstDayOfWeek);
      expect(cubit.state.firstDayOfWeek.weekday, 1);
    });

    test('should set the correct date as the last day of the week', () {
      final date = faker.date.date();
      final cubit = AnalyticsCubit(mockDiaryRepository, mockUserRepository, date: date);

      final firstDayOfWeek = date.subtract(days: date.weekday - 1);
      expect(cubit.state.lastDayOfWeek.weekday, 1); // Should be monday
      expect(cubit.state.lastDayOfWeek, firstDayOfWeek.add(days: oneWeekInDays));
    });

    group('setDate', () {
      test('should set the correct date as the first day of the week', () async {
        final cubit = AnalyticsCubit(mockDiaryRepository, mockUserRepository, date: date);

        final newDate = faker.date.date();
        cubit.setDate(newDate);

        await cubit.stream.first;

        final firstDayOfWeek = newDate.subtract(days: newDate.weekday - 1);
        expect(cubit.state.firstDayOfWeek, firstDayOfWeek);
        expect(cubit.state.firstDayOfWeek.weekday, 1);
      });

      test('should reset the state but keep the goals', () async {
        final cubit = AnalyticsCubit(mockDiaryRepository, mockUserRepository, date: date);

        final newDate = faker.date.date();
        cubit.setDate(newDate);

        await cubit.stream.first;

        expect(cubit.state.goals, user.goals);
        expect(cubit.state.averageAlcoholPerSession, 0);
      });

      test('should reload the diary entries', () async {
        final cubit = AnalyticsCubit(mockDiaryRepository, mockUserRepository, date: date);

        final newDate = faker.date.date();
        cubit.setDate(newDate);

        await cubit.stream.first;

        final firstDayOfWeek = newDate.floorToWeek();
        final lastDayOfWeek = firstDayOfWeek.add(days: oneWeekInDays);
        verify(mockDiaryRepository.observeEntriesBetween(firstDayOfWeek, lastDayOfWeek));
      });
    });

    group('state.alcoholPerDayThisWeek', () {
      test('should equal the grams of alcohol in the current week', () async {
        final drinksOnFirstDay = [generateConsumedDrinkOnDate(date: date), generateConsumedDrinkOnDate(date: date)];
        final drinksOnThirdDay = [generateConsumedDrinkOnDate(date: date.add(days: 2))];

        final diaryEntries = [
          generateDiaryEntry(date: date, drinks: drinksOnFirstDay),
          generateDiaryEntry(date: date.add(days: 1), drinks: []), // day 2
          generateDiaryEntry(date: date.add(days: 2), drinks: drinksOnThirdDay), // day 3
          generateDiaryEntry(date: date.add(days: 3), drinks: []), // day 4
          generateDiaryEntry(date: date.add(days: 4), drinks: []), // day 5
        ];
        when(mockDiaryRepository.observeEntriesBetween(any, any)).thenAnswer((_) => Stream.value(diaryEntries));

        final cubit = AnalyticsCubit(mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        final alcoholOnFirstDay = drinksOnFirstDay.map((drink) => drink.gramsOfAlcohol).sum;
        final alcoholOnThirdDay = drinksOnThirdDay.map((drink) => drink.gramsOfAlcohol).sum;

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
    });

    group('state.totalAlcoholThisWeek', () {
      test('should equal the total amount of alcohol consumed', () async {
        final drinks = [
          generateConsumedDrinkOnDate(date: date),
          generateConsumedDrinkOnDate(date: date),
          generateConsumedDrinkOnDate(date: date),
        ];

        final diaryEntries = [generateDiaryEntry(date: date, drinks: drinks)];

        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(diaryEntries));

        final cubit = AnalyticsCubit(mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        final expectedGramsOfAlcohol = drinks.map((drink) => drink.gramsOfAlcohol).sum;
        expect(cubit.state.totalAlcohol, expectedGramsOfAlcohol);
      });
    });

    group('state.calories', () {
      test('should be equal to the sum of the calories of all drinks consumed this week', () async {
        final drinks = [
          generateConsumedDrinkOnDate(date: date),
          generateConsumedDrinkOnDate(date: date),
          generateConsumedDrinkOnDate(date: date),
        ];

        final diaryEntries = [generateDiaryEntry(date: date, drinks: drinks)];

        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(diaryEntries));

        final cubit = AnalyticsCubit(mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        final expectedCalories = drinks.map((drink) => drink.calories).sum;
        expect(cubit.state.calories, expectedCalories);
      });
    });

    group('state.numberOfDrinks', () {
      test('should be equal to the number of drinks consumed this week', () async {
        final drinksDayOne = [
          generateConsumedDrinkOnDate(date: date),
          generateConsumedDrinkOnDate(date: date),
          generateConsumedDrinkOnDate(date: date),
        ];

        final drinksDayTwo = [
          generateConsumedDrinkOnDate(date: date.add(days: 1)),
          generateConsumedDrinkOnDate(date: date.add(days: 1)),
        ];

        final drinksDayThree = [
          generateConsumedDrinkOnDate(date: date.add(days: 2)),
        ];

        final diaryEntries = [
          generateDiaryEntry(date: date, drinks: drinksDayOne),
          generateDiaryEntry(date: date.add(days: 1), drinks: drinksDayTwo),
          generateDiaryEntry(date: date.add(days: 2), drinks: drinksDayThree),
        ];

        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(diaryEntries));

        final cubit = AnalyticsCubit(mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(cubit.state.numberOfDrinks, drinksDayOne.length + drinksDayTwo.length + drinksDayThree.length);
      });
    });

    group('state.averageAlcoholPerSession', () {
      test('should be the average alcohol per drinking session', () async {
        final drinksDayOne = [
          generateConsumedDrinkOnDate(date: date, alcoholByVolume: 0.5, volume: 500),
          generateConsumedDrinkOnDate(date: date, alcoholByVolume: 0.5, volume: 500),
          generateConsumedDrinkOnDate(date: date, alcoholByVolume: 0.5, volume: 500),
        ];
        final drinksDayTwo = [
          generateConsumedDrinkOnDate(date: date.add(days: 1), alcoholByVolume: 0.5, volume: 500),
          generateConsumedDrinkOnDate(date: date.add(days: 1), alcoholByVolume: 0.5, volume: 500),
        ];
        final drinksDayThree = [
          generateConsumedDrinkOnDate(date: date.add(days: 2), alcoholByVolume: 0.5, volume: 500),
        ];

        final diaryEntries = [
          generateDiaryEntry(date: date, drinks: drinksDayOne),
          generateDiaryEntry(date: date.add(days: 1), drinks: drinksDayTwo),
          generateDiaryEntry(date: date.add(days: 2), drinks: drinksDayThree),
        ];

        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(diaryEntries));

        final cubit = AnalyticsCubit(mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        final totalAlcohol =
            [...drinksDayOne, ...drinksDayTwo, ...drinksDayThree].map((drink) => drink.gramsOfAlcohol).sum;
        final expectedAverageAlcoholPerSession = totalAlcohol / diaryEntries.length;
        expect(cubit.state.averageAlcoholPerSession, expectedAverageAlcoholPerSession);
      });
    });

    group('state.changeOfAverageAlcohol', () {
      test('should be the relative change in the average alcohol consumed compared to last week', () async {
        final lastWeeksDrinks = [
          generateConsumedDrinkOnDate(date: date.subtract(days: oneWeekInDays), alcoholByVolume: 0.5, volume: 500),
          generateConsumedDrinkOnDate(date: date.subtract(days: oneWeekInDays), alcoholByVolume: 0.5, volume: 500),
        ];
        final lastWeeksDiaryEntries = [
          generateDiaryEntry(date: date.subtract(days: oneWeekInDays), drinks: lastWeeksDrinks),
        ];

        final drinks = [
          generateConsumedDrinkOnDate(date: date, alcoholByVolume: 0.5, volume: 500),
          generateConsumedDrinkOnDate(date: date, alcoholByVolume: 0.5, volume: 500),
          generateConsumedDrinkOnDate(date: date, alcoholByVolume: 0.5, volume: 500),
        ];
        final diaryEntries = [generateDiaryEntry(date: date, drinks: drinks)];

        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(diaryEntries));
        when(mockDiaryRepository.observeEntriesBetween(date.subtract(days: oneWeekInDays), date))
            .thenAnswer((_) => Stream.value(lastWeeksDiaryEntries));

        final cubit = AnalyticsCubit(mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(cubit.state.changeOfAverageAlcohol, 0.5); // On average, we drank 50% more compared to last week
      });

      test('should be 0 if on average as much alcohol per session was consumed as last week', () async {
        final lastWeek = date.subtract(days: oneWeekInDays);
        final lastWeeksDiaryEntries = [
          generateDiaryEntry(
            date: lastWeek,
            drinks: [generateConsumedDrinkOnDate(date: lastWeek, alcoholByVolume: 0.5, volume: 500)],
          ),
          generateDiaryEntry(
            date: lastWeek.add(days: 1),
            drinks: [generateConsumedDrinkOnDate(date: lastWeek.add(days: 1), alcoholByVolume: 0.5, volume: 500)],
          ),
        ];

        final diaryEntries = [
          generateDiaryEntry(
            date: date,
            drinks: [generateConsumedDrinkOnDate(date: date, alcoholByVolume: 0.5, volume: 500)],
          ),
          generateDiaryEntry(
            date: date.add(days: 1),
            drinks: [generateConsumedDrinkOnDate(date: date.add(days: 1), alcoholByVolume: 0.5, volume: 500)],
          ),
          generateDiaryEntry(
            date: date.add(days: 2),
            drinks: [generateConsumedDrinkOnDate(date: date.add(days: 2), alcoholByVolume: 0.5, volume: 500)],
          ),
        ];

        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(diaryEntries));
        when(mockDiaryRepository.observeEntriesBetween(lastWeek, date))
            .thenAnswer((_) => Stream.value(lastWeeksDiaryEntries));

        final cubit = AnalyticsCubit(mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(cubit.state.changeOfAverageAlcohol, 0); // On average, we drank the same as last week
      });

      test('should be 1 if there was no alcohol consumed last week, but this week', () async {
        final diaryEntries = [
          generateDiaryEntry(date: date, drinks: [generateConsumedDrinkOnDate(date: date)])
        ];
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(diaryEntries));
        when(mockDiaryRepository.observeEntriesBetween(date.subtract(days: oneWeekInDays), date))
            .thenAnswer((_) => Stream.value([]));

        final cubit = AnalyticsCubit(mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(cubit.state.changeOfAverageAlcohol, 1);
      });

      test('should be -1 if there was no alcohol consumed this week, but last week', () async {
        final diaryEntries = [generateDiaryEntry(date: date, drinks: [])];
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(diaryEntries));

        final lastWeeksDiaryEntries = [
          generateDiaryEntry(
            date: date.subtract(days: oneWeekInDays),
            drinks: [generateConsumedDrinkOnDate(date: date.subtract(days: oneWeekInDays))],
          )
        ];
        when(mockDiaryRepository.observeEntriesBetween(date.subtract(days: oneWeekInDays), date))
            .thenAnswer((_) => Stream.value(lastWeeksDiaryEntries));

        final cubit = AnalyticsCubit(mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(cubit.state.changeOfAverageAlcohol, -1);
      });

      test('should be 0 if there was neither alcohol consumed this week nor last week', () async {
        final diaryEntries = [generateDiaryEntry(date: date, drinks: [])];
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(diaryEntries));

        final lastWeeksDiaryEntries = [generateDiaryEntry(date: date.subtract(days: oneWeekInDays), drinks: [])];
        when(mockDiaryRepository.observeEntriesBetween(date.subtract(days: oneWeekInDays), date))
            .thenAnswer((_) => Stream.value(lastWeeksDiaryEntries));

        final cubit = AnalyticsCubit(mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(cubit.state.changeOfAverageAlcohol, 0);
      });
    });

    group('state.drinkFreeDays', () {
      test('should equal the diary entries and corresponding drinks', () async {
        final diaryEntries = [
          generateDiaryEntry(date: date, drinks: []),
          generateDiaryEntry(date: date.add(days: 1), drinks: [generateConsumedDrinkOnDate(date: date.add(days: 1))]),
          generateDiaryEntry(date: date.add(days: 2), drinks: []),
          generateDiaryEntry(date: date.add(days: 3), drinks: []),
          generateDiaryEntry(date: date.add(days: 4), drinks: []),
          generateDiaryEntry(date: date.add(days: 5), drinks: []),
          generateDiaryEntry(date: date.add(days: 6), drinks: []),
        ];

        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(diaryEntries));

        final cubit = AnalyticsCubit(mockDiaryRepository, mockUserRepository, date: date);
        await cubit.stream.first;

        expect(cubit.state.drinkFreeDays, diaryEntries.groupFoldBy((el) => el.date, (_, el) => el.isDrinkFreeDay));
      });

      test('should not count days without a diary entry', () async {
        final diaryEntries = [
          generateDiaryEntry(date: date, drinks: []),
          generateDiaryEntry(date: date.add(days: 1), drinks: [generateConsumedDrinkOnDate(date: date.add(days: 1))]),
          generateDiaryEntry(date: date.add(days: 2), drinks: []),
          generateDiaryEntry(date: date.add(days: 5), drinks: []),
        ];
        when(mockDiaryRepository.observeEntriesBetween(date, date.add(days: oneWeekInDays)))
            .thenAnswer((_) => Stream.value(diaryEntries));

        final cubit = AnalyticsCubit(mockDiaryRepository, mockUserRepository, date: date);
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
