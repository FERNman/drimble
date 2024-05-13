import 'package:drimble/data/diary_repository.dart';
import 'package:drimble/data/user_repository.dart';
import 'package:drimble/domain/diary/diary_entry.dart';
import 'package:drimble/features/diary/diary_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../generate_entities.dart';
import 'diary_cubit_test.mocks.dart';

@GenerateNiceMocks([MockSpec<UserRepository>(), MockSpec<DiaryRepository>()])
void main() {
  group(DiaryCubit, () {
    final user = generateUser();

    final userRepository = MockUserRepository();
    final diaryRepository = MockDiaryRepository();

    setUp(() {
      when(userRepository.loadUser()).thenAnswer((_) => Future.value(user));
    });

    test('should not throw an exception for a state with no diary entry', () async {
      when(diaryRepository.observeEntryOnDate(any)).thenAnswer((_) => Stream.value(null));

      // TOOD: This potentially throws an exception,
      // but since the exception is thrown on a different isolate, the test doesn't catch it
      final cubit = DiaryCubit(userRepository, diaryRepository);
      await cubit.stream.first;

      expect(cubit.state.drinks, isEmpty);
    }, timeout: const Timeout(Duration(milliseconds: 500)));

    group('setGlassesOfWater', () {
      test('should update the glasses of water to the specified amount if a diary entry exists already', () async {
        final diaryEntry = generateDiaryEntry();
        when(diaryRepository.observeEntryOnDate(any)).thenAnswer((_) => Stream.value(diaryEntry));

        final cubit = DiaryCubit(userRepository, diaryRepository);
        await cubit.stream.first;

        const glassesOfWater = 5;
        await cubit.setGlassesOfWater(glassesOfWater);

        final capturedDiaryEntry = verify(diaryRepository.saveDiaryEntry(captureAny)).captured.single as DiaryEntry;
        expect(capturedDiaryEntry.date, diaryEntry.date);
        expect(capturedDiaryEntry.glassesOfWater, glassesOfWater);
      });

      test('should create a new diary entry with the given amount of glasses of water if no diary entry exists',
          () async {
        when(diaryRepository.observeEntryOnDate(any)).thenAnswer((_) => Stream.value(null));

        final cubit = DiaryCubit(userRepository, diaryRepository);
        await cubit.stream.first;

        const glassesOfWater = 5;
        await cubit.setGlassesOfWater(glassesOfWater);

        final capturedDiaryEntry = verify(diaryRepository.saveDiaryEntry(captureAny)).captured.single as DiaryEntry;
        expect(capturedDiaryEntry.date, cubit.state.date);
        expect(capturedDiaryEntry.glassesOfWater, glassesOfWater);
      });
    });
  });
}
