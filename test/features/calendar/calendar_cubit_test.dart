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
      final cubit = CalendarCubit(MockDiaryRepository(), initialDate: date);

      expect(cubit.state, isA<CalendarCubitLoadingState>());
    });

    test('should load the diary entries for all weeks of this month, including the days before and after', () async {
      final firstDayOfFirstWeek = month.floorToWeek();
      final lastDayOfLastWeek = month.add(months: 1).floorToWeek().add(days: 6);

      final diaryEntry = generateDiaryEntry();

      final mockDiaryRepository = MockDiaryRepository();
      when(mockDiaryRepository.observeEntriesBetween(firstDayOfFirstWeek, lastDayOfLastWeek))
          .thenAnswer((_) => Stream.value([diaryEntry]));

      final cubit = CalendarCubit(mockDiaryRepository, initialDate: date);
      await cubit.stream.first;

      verify(mockDiaryRepository.observeEntriesBetween(firstDayOfFirstWeek, lastDayOfLastWeek));

      expect(cubit.state, isA<CalendarCubitState>());

      final state = cubit.state as CalendarCubitState;
      expect(state.diaryEntries, {diaryEntry.date: diaryEntry});
    });

    group('changeVisibleMonth', () {
      final mockDiaryRepository = MockDiaryRepository();
      final diaryEntry = generateDiaryEntry();

      final newDate = faker.date.date();
      final newMonth = newDate.floorToMonth();

      setUp(() {
        final firstDayOfFirstWeek = month.floorToWeek();
        final lastDayOfLastWeek = month.add(months: 1).floorToWeek().add(days: 6);

        when(mockDiaryRepository.observeEntriesBetween(firstDayOfFirstWeek, lastDayOfLastWeek))
            .thenAnswer((_) => Stream.value([diaryEntry]));
      });

      test('should be in loading state when changing visible month', () async {
        final cubit = CalendarCubit(mockDiaryRepository, initialDate: date);
        await cubit.stream.first;

        expect(cubit.state, isA<CalendarCubitState>());

        cubit.changeVisibleMonth(newDate);

        expect(cubit.state, isA<CalendarCubitLoadingState>());
      });

      test('should load the diary entries for the given month', () async {
        final firstDayOfFirstWeek = newMonth.floorToWeek();
        final lastDayOfLastWeek = newMonth.add(months: 1).floorToWeek().add(days: 6);

        final cubit = CalendarCubit(mockDiaryRepository, initialDate: date);
        await cubit.stream.first;

        final newDiaryEntry = generateDiaryEntry();
        when(mockDiaryRepository.observeEntriesBetween(firstDayOfFirstWeek, lastDayOfLastWeek))
            .thenAnswer((_) => Stream.value([newDiaryEntry]));

        cubit.changeVisibleMonth(newDate);
        await cubit.stream.elementAt(0);

        verify(mockDiaryRepository.observeEntriesBetween(firstDayOfFirstWeek, lastDayOfLastWeek));

        expect(cubit.state, isA<CalendarCubitState>());

        final state = cubit.state as CalendarCubitState;
        expect(state.diaryEntries, {newDiaryEntry.date: newDiaryEntry});
      });
    });

    group('changeSelectedDate', () {
      test('should change the selected date while keeping the rest of the state as-is', () async {
        final mockDiaryRepository = MockDiaryRepository();
        final diaryEntry = generateDiaryEntry();

        final firstDayOfFirstWeek = month.floorToWeek();
        final lastDayOfLastWeek = month.add(months: 1).floorToWeek().add(days: 6);

        when(mockDiaryRepository.observeEntriesBetween(firstDayOfFirstWeek, lastDayOfLastWeek))
            .thenAnswer((_) => Stream.value([diaryEntry]));

        final cubit = CalendarCubit(mockDiaryRepository, initialDate: date);
        await cubit.stream.first;

        final state = cubit.state as CalendarCubitState;
        expect(state.selectedDate, date);

        final newDate = faker.date.date();
        cubit.changeSelectedDate(newDate);

        expect(cubit.state, isA<CalendarCubitState>());

        final newState = cubit.state as CalendarCubitState;
        expect(newState.selectedDate, newDate);
        expect(newState.diaryEntries, state.diaryEntries);
        expect(newState.visibleMonth, state.visibleMonth);
      });

      test('should also work if the state is currently loading', () {
        final cubit = CalendarCubit(MockDiaryRepository(), initialDate: date);

        expect(cubit.state, isA<CalendarCubitLoadingState>());

        final newDate = faker.date.date();
        cubit.changeSelectedDate(newDate);

        expect(cubit.state, isA<CalendarCubitLoadingState>());

        expect(cubit.state.selectedDate, newDate);
        expect(cubit.state.visibleMonth, month);
      });
    });
  });
}
