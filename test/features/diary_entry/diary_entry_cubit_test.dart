import 'package:drimble/data/diary_repository.dart';
import 'package:drimble/data/user_repository.dart';
import 'package:drimble/domain/bac/bac_calculation_results.dart';
import 'package:drimble/domain/diary/diary_entry.dart';
import 'package:drimble/features/diary_entry/diary_entry_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

import '../../generate_entities.dart';
import 'diary_entry_cubit_test.mocks.dart';

class FakeDiaryRepository extends Fake implements DiaryRepository {
  final BehaviorSubject<Map<String, DiaryEntry>> _entries;

  FakeDiaryRepository(DiaryEntry initial) : _entries = BehaviorSubject.seeded({initial.id!: initial});

  @override
  Future<void> saveDiaryEntry(DiaryEntry diaryEntry) async {
    // Firebase adds an ID for documents that don't have one
    final diaryEntryWithId = _addId(diaryEntry);
    _entries.add(_entries.value..addEntries([MapEntry(diaryEntryWithId.id!, diaryEntryWithId)]));
  }

  @override
  Stream<DiaryEntry> observeEntryById(String id) {
    return _entries.stream.map((entries) => entries[id]!);
  }

  DiaryEntry _addId(DiaryEntry diaryEntry) => DiaryEntry.withDrinks(
        DiaryEntry(
          id: diaryEntry.id ?? faker.guid.guid(),
          date: diaryEntry.date,
          glassesOfWater: diaryEntry.glassesOfWater,
        ),
        drinks: List.unmodifiable(diaryEntry.drinks),
      );
}

@GenerateNiceMocks([MockSpec<UserRepository>(), MockSpec<DiaryRepository>()])
void main() {
  group(DiaryEntryCubit, () {
    final mockUserRepository = MockUserRepository();

    final user = generateUser();

    setUp(() {
      reset(mockUserRepository);

      when(mockUserRepository.loadUser()).thenAnswer((_) => Future.value(user));
    });

    test('should work with empty calculation results', () async {
      final diaryEntry = generateDiaryEntry(id: faker.guid.guid());
      final mockDiaryRepository = FakeDiaryRepository(diaryEntry);

      final cubit = DiaryEntryCubit(mockUserRepository, mockDiaryRepository, diaryEntry);
      await cubit.stream.first;

      final emptyResults = BACCalculationResults.empty(
        startTime: diaryEntry.date.toDateTime(),
        endTime: diaryEntry.date.toDateTime().add(const Duration(hours: 24)),
      );

      expect(cubit.state.calculationResults, emptyResults);
    }, skip: 'Needs refactoring of empty BAC calculation results');

    test('should calculate the BAC', () async {
      final diaryEntry = generateDiaryEntry(id: faker.guid.guid(), drinks: [generateConsumedDrink()]);
      final mockDiaryRepository = FakeDiaryRepository(diaryEntry);

      final cubit = DiaryEntryCubit(mockUserRepository, mockDiaryRepository, diaryEntry);
      await cubit.stream.first;

      final emptyResults = BACCalculationResults.empty(
        startTime: diaryEntry.date.toDateTime(),
        endTime: diaryEntry.date.toDateTime().add(const Duration(hours: 24)),
      );

      expect(cubit.state.calculationResults, isNot(emptyResults));
    });

    group('addGlassOfWater', () {
      test('should add a glass of water to the diary entry', () async {
        final diaryEntry = generateDiaryEntry(id: faker.guid.guid());
        final mockDiaryRepository = FakeDiaryRepository(diaryEntry);

        final cubit = DiaryEntryCubit(mockUserRepository, mockDiaryRepository, diaryEntry);
        await cubit.stream.first;

        await cubit.addGlassOfWater();

        expect(cubit.state.diaryEntry.glassesOfWater, diaryEntry.glassesOfWater + 1);
      });
    });

    group('removeGlassOfWater', () {
      test('should remove a glass of water from the diary entry', () async {
        final diaryEntry = generateDiaryEntry(
          id: faker.guid.guid(),
          glassesOfWater: faker.randomGenerator.integer(10, min: 1),
        );
        final mockDiaryRepository = FakeDiaryRepository(diaryEntry);

        final cubit = DiaryEntryCubit(mockUserRepository, mockDiaryRepository, diaryEntry);
        await cubit.stream.first;

        await cubit.removeGlassOfWater();

        expect(cubit.state.diaryEntry.glassesOfWater, diaryEntry.glassesOfWater - 1);
      });

      test('should not remove a glass of water if there are none left', () async {
        final diaryEntry = generateDiaryEntry(id: faker.guid.guid(), glassesOfWater: 0);
        final mockDiaryRepository = FakeDiaryRepository(diaryEntry);

        final cubit = DiaryEntryCubit(mockUserRepository, mockDiaryRepository, diaryEntry);
        await cubit.stream.first;

        await cubit.removeGlassOfWater();

        expect(cubit.state.diaryEntry.glassesOfWater, 0);
      });
    });
  });
}
