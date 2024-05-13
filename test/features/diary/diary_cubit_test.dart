import 'package:drimble/data/diary_repository.dart';
import 'package:drimble/domain/date.dart';
import 'package:drimble/features/diary/diary_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../generate_entities.dart';
import 'diary_cubit_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DiaryRepository>()])
void main() {
  group(DiaryCubit, () {
    final diaryRepository = MockDiaryRepository();

    final initialDate = faker.date.date().floorToWeek().add(days: 4); // friday
    final weekStartDate = initialDate.floorToWeek();
    final weekEndDate = weekStartDate.add(days: 6);

    setUp(() {
      reset(diaryRepository);
    });

    test('should load the diary entries', () async {
      final diaryEntries = [
        generateDiaryEntry(date: initialDate.subtract(days: 1)),
        generateDiaryEntry(date: initialDate),
        generateDiaryEntry(date: initialDate.add(days: 2)),
      ];
      when(diaryRepository.observeEntriesBetween(any, any)).thenAnswer((_) => Stream.value(diaryEntries));

      final cubit = DiaryCubit(diaryRepository, initialDate);
      await cubit.stream.first;

      expect(cubit.state.selectedDate, initialDate);
      expect(cubit.state.diaryEntries, Map.fromEntries(diaryEntries.map((entry) => MapEntry(entry.date, entry))));
      expect(cubit.state.selectedDiaryEntry, diaryEntries[1]);
    });

    test('should not throw an exception for a state with no diary entries', () async {
      when(diaryRepository.observeEntriesBetween(any, any)).thenAnswer((_) => Stream.value([]));

      final cubit = DiaryCubit(diaryRepository, initialDate);
      await cubit.stream.first;

      expect(cubit.state.selectedDate, initialDate);
      expect(cubit.state.diaryEntries, isEmpty);
      expect(cubit.state.selectedDiaryEntry, isNull);
    });

    test('should only load the diary entries once', () async {
      final diaryEntries = [
        generateDiaryEntry(date: initialDate.subtract(days: 1)),
        generateDiaryEntry(date: initialDate),
        generateDiaryEntry(date: initialDate.add(days: 2)),
      ];
      when(diaryRepository.observeEntriesBetween(weekStartDate, weekEndDate))
          .thenAnswer((_) => Stream.value(diaryEntries));

      final cubit = DiaryCubit(diaryRepository, initialDate);
      await cubit.stream.first;

      verify(diaryRepository.observeEntriesBetween(weekStartDate, weekEndDate)).called(1);
    });

    group('switchDate', () {
      test('should switch the selected date', () async {
        final diaryEntries = [
          generateDiaryEntry(date: initialDate),
          generateDiaryEntry(date: initialDate.add(days: 1)),
        ];
        when(diaryRepository.observeEntriesBetween(any, any)).thenAnswer((_) => Stream.value(diaryEntries));

        final cubit = DiaryCubit(diaryRepository, initialDate);
        await cubit.stream.first;

        final newDate = initialDate.add(days: 1);
        await cubit.switchDate(newDate);

        expect(cubit.state.selectedDate, newDate);
        expect(cubit.state.selectedDiaryEntry, diaryEntries[1]);
      });

      test('should allow switching to a date with no diary entry', () async {
        final diaryEntries = [
          generateDiaryEntry(date: initialDate),
        ];
        when(diaryRepository.observeEntriesBetween(any, any)).thenAnswer((_) => Stream.value(diaryEntries));

        final cubit = DiaryCubit(diaryRepository, initialDate);
        await cubit.stream.first;

        final newDate = initialDate.add(days: 1);
        await cubit.switchDate(newDate);

        expect(cubit.state.selectedDate, newDate);
        expect(cubit.state.selectedDiaryEntry, isNull);
      });

      test('should not reload the diary entries if the new date is in the same week', () async {
        final diaryEntries = [
          generateDiaryEntry(date: initialDate.subtract(days: 1)),
          generateDiaryEntry(date: initialDate),
          generateDiaryEntry(date: initialDate.add(days: 2)),
        ];
        when(diaryRepository.observeEntriesBetween(any, any)).thenAnswer((_) => Stream.value(diaryEntries));

        final cubit = DiaryCubit(diaryRepository, initialDate);
        await cubit.stream.first;

        verify(diaryRepository.observeEntriesBetween(weekStartDate, weekEndDate));

        final newDate = initialDate.add(days: 1);
        await cubit.switchDate(newDate);

        expect(cubit.state.weekStartDate, initialDate.floorToWeek());
        expect(cubit.state.weekEndDate, initialDate.floorToWeek().add(days: 6));
        verifyNever(diaryRepository.observeEntriesBetween(any, any));
      });

      test('should reload the diary entries if the new date is in a different week', () async {
        final diaryEntries = [
          generateDiaryEntry(date: initialDate.subtract(days: 1)),
          generateDiaryEntry(date: initialDate),
          generateDiaryEntry(date: initialDate.add(days: 2)),
        ];
        when(diaryRepository.observeEntriesBetween(any, any)).thenAnswer((_) => Stream.value(diaryEntries));

        final cubit = DiaryCubit(diaryRepository, initialDate);
        await cubit.stream.first;

        final newDate = initialDate.add(days: 8);
        await cubit.switchDate(newDate);

        verify(diaryRepository.observeEntriesBetween(newDate.floorToWeek(), newDate.floorToWeek().add(days: 6)));
      });
    });
  });
}
