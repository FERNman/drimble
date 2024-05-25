import 'package:drimble/data/diary_repository.dart';
import 'package:drimble/domain/date.dart';
import 'package:drimble/features/calendar/calendar_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../generate_entities.dart';
import 'calendar_cubit_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DiaryRepository>()])
void main() {
  group(CalendarCubit, () {
    final date = faker.date.date();
    final month = date.floorToMonth();

    tearDown(() {
      resetMockitoState();
    });

    test('should be in loading state initially', () async {
      final cubit = CalendarCubit(MockDiaryRepository(), initiallyVisibleDate: date);

      expect(cubit.state, isA<CalendarCubitLoadingState>());
    });

    test('should load the diary entries for half a year', () async {
      final firstDayOfPreviousMonth = month.subtract(months: 3);
      final firstDayOfNextMonth = month.add(months: 2);

      final diaryEntry = generateDiaryEntry();

      final mockDiaryRepository = MockDiaryRepository();
      when(mockDiaryRepository.loadEntriesBetween(firstDayOfPreviousMonth, firstDayOfNextMonth))
          .thenAnswer((_) async => [diaryEntry]);

      final cubit = CalendarCubit(mockDiaryRepository, initiallyVisibleDate: date);
      await cubit.stream.first;

      expect(cubit.state, isA<CalendarCubitState>());

      final state = cubit.state as CalendarCubitState;
      expect(state.diaryEntries, {diaryEntry.date: diaryEntry});
    });

    test('should keep previously loaded diary entries if loading more', () async {
      final diaryEntry = generateDiaryEntry();

      final mockDiaryRepository = MockDiaryRepository();
      when(mockDiaryRepository.loadEntriesBetween(month.subtract(months: 3), month.add(months: 2)))
          .thenAnswer((_) async => [diaryEntry]);

      final cubit = CalendarCubit(mockDiaryRepository, initiallyVisibleDate: date);
      await cubit.stream.first;

      final anotherMonth = date.subtract(months: 4);
      final anotherDiaryEntry = generateDiaryEntry(date: anotherMonth.add(days: 1));
      when(mockDiaryRepository.loadEntriesBetween(anotherMonth.subtract(months: 3), anotherMonth.add(months: 2)))
          .thenAnswer((_) async => [anotherDiaryEntry]);

      await cubit.loadEntriesForMonth(anotherMonth);

      expect(cubit.state, isA<CalendarCubitState>());

      final state = cubit.state as CalendarCubitState;
      expect(state.diaryEntries, {diaryEntry.date: diaryEntry, anotherDiaryEntry.date: anotherDiaryEntry});
    });

    test('should not load the same month twice', () async {
      final mockDiaryRepository = MockDiaryRepository();
      when(mockDiaryRepository.loadEntriesBetween(any, any)).thenAnswer((_) async => []);

      final cubit = CalendarCubit(mockDiaryRepository, initiallyVisibleDate: date);
      await cubit.stream.first;

      verify(mockDiaryRepository.loadEntriesBetween(any, any));

      await cubit.loadEntriesForMonth(month);

      verifyNever(mockDiaryRepository.loadEntriesBetween(any, any));
    });

    test('should not load a month that has already been loaded', () async {
      final mockDiaryRepository = MockDiaryRepository();
      when(mockDiaryRepository.loadEntriesBetween(any, any)).thenAnswer((_) async => []);

      final cubit = CalendarCubit(mockDiaryRepository, initiallyVisibleDate: date);
      await cubit.stream.first;

      verify(mockDiaryRepository.loadEntriesBetween(any, any));

      final anotherMonth = date.subtract(months: 4);
      await cubit.loadEntriesForMonth(anotherMonth);

      verify(mockDiaryRepository.loadEntriesBetween(any, any));

      final monthBetween = anotherMonth.add(months: 1);
      await cubit.loadEntriesForMonth(monthBetween);

      verifyNever(mockDiaryRepository.loadEntriesBetween(any, any));
    });

    test('should keep track of the loaded months', () async {
      final mockDiaryRepository = MockDiaryRepository();
      when(mockDiaryRepository.loadEntriesBetween(any, any)).thenAnswer((_) async => []);

      final cubit = CalendarCubit(mockDiaryRepository, initiallyVisibleDate: date);
      await cubit.stream.first;

      final anotherMonth = date.subtract(months: 4);
      await cubit.loadEntriesForMonth(anotherMonth);

      expect(cubit.state, isA<CalendarCubitState>());

      final state = cubit.state as CalendarCubitState;
      expect(state.earliestLoadedDate, anotherMonth.subtract(months: 3));
      expect(state.latestLoadedDate, month.add(months: 2));
    });
  });
}
