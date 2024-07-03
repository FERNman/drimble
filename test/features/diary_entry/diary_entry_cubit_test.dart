import 'package:drimble/data/diary_repository.dart';
import 'package:drimble/data/user_repository.dart';
import 'package:drimble/domain/bac/bac_time_series.dart';
import 'package:drimble/domain/date.dart';
import 'package:drimble/domain/diary/hangover_severity.dart';
import 'package:drimble/domain/diary/stomach_fullness.dart';
import 'package:drimble/domain/hangover_predictor.dart';
import 'package:drimble/features/diary_entry/diary_entry_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../generate_entities.dart';
import 'diary_entry_cubit_test.mocks.dart';
import 'fake_diary_repository.dart';

@GenerateNiceMocks([MockSpec<UserRepository>(), MockSpec<DiaryRepository>(), MockSpec<HangoverSeverityPredictor>()])
void main() {
  group(DiaryEntryCubit, () {
    final mockUserRepository = MockUserRepository();
    final mockHangoverSeverityPredictor = MockHangoverSeverityPredictor();

    final user = generateUser();

    setUp(() {
      reset(mockUserRepository);
      reset(mockHangoverSeverityPredictor);

      when(mockUserRepository.loadUser()).thenAnswer((_) => Future.value(user));
    });

    test('should work with empty bac entries', () async {
      final diaryEntry = generateDiaryEntry(id: faker.guid.guid());
      final mockDiaryRepository = FakeDiaryRepository(diaryEntry);

      final cubit = DiaryEntryCubit(mockUserRepository, mockDiaryRepository, mockHangoverSeverityPredictor, diaryEntry);
      await cubit.stream.first;

      final emptyResults = BACTimeSeries.empty(diaryEntry.date.toDateTime());
      expect(cubit.state.bacEntries, emptyResults);
    });

    test('should calculate the BAC', () async {
      final diaryEntry = generateDiaryEntry(id: faker.guid.guid(), drinks: [generateConsumedDrink()]);
      final mockDiaryRepository = FakeDiaryRepository(diaryEntry);

      final cubit = DiaryEntryCubit(mockUserRepository, mockDiaryRepository, mockHangoverSeverityPredictor, diaryEntry);
      await cubit.stream.elementAt(4);

      final emptyResults = BACTimeSeries.empty(diaryEntry.date.toDateTime());
      expect(cubit.state.bacEntries, isNot(emptyResults));
    });

    group('addGlassOfWater', () {
      test('should add a glass of water to the diary entry', () async {
        final diaryEntry = generateDiaryEntry(id: faker.guid.guid());
        final mockDiaryRepository = FakeDiaryRepository(diaryEntry);

        final cubit = DiaryEntryCubit(
          mockUserRepository,
          mockDiaryRepository,
          mockHangoverSeverityPredictor,
          diaryEntry,
        );
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

        final cubit = DiaryEntryCubit(
          mockUserRepository,
          mockDiaryRepository,
          mockHangoverSeverityPredictor,
          diaryEntry,
        );
        await cubit.stream.first;

        await cubit.removeGlassOfWater();

        expect(cubit.state.diaryEntry.glassesOfWater, diaryEntry.glassesOfWater - 1);
      });
    });

    group('addDrinkFromRecent', () {
      test('should create a new drink from the consumed drink', () async {
        final consumedDrink = generateConsumedDrink();
        final diaryEntry = generateDiaryEntry(id: faker.guid.guid(), drinks: [consumedDrink]);
        final mockDiaryRepository = FakeDiaryRepository(diaryEntry);

        final cubit = DiaryEntryCubit(
          mockUserRepository,
          mockDiaryRepository,
          mockHangoverSeverityPredictor,
          diaryEntry,
        );
        await cubit.stream.first;

        await cubit.addDrinkFromRecent(consumedDrink);

        expect(cubit.state.diaryEntry.drinks.length, 2);
        expect(cubit.state.diaryEntry.drinks.last.id, isNot(consumedDrink.id));
      });

      test('should keep the same date', () async {
        final consumedDrink = generateConsumedDrink();
        final diaryEntry = generateDiaryEntry(id: faker.guid.guid(), drinks: [consumedDrink]);
        final mockDiaryRepository = FakeDiaryRepository(diaryEntry);

        final cubit = DiaryEntryCubit(
          mockUserRepository,
          mockDiaryRepository,
          mockHangoverSeverityPredictor,
          diaryEntry,
        );
        await cubit.stream.first;

        await cubit.addDrinkFromRecent(consumedDrink);

        expect(cubit.state.diaryEntry.drinks.length, 2);
        expect(cubit.state.diaryEntry.drinks.last.startTime.toDate(), diaryEntry.date);
      });
    });

    group('removeDrink', () {
      test('should remove the drink from the diary entry', () async {
        final consumedDrink = generateConsumedDrink();
        final diaryEntry = generateDiaryEntry(id: faker.guid.guid(), drinks: [consumedDrink]);
        final mockDiaryRepository = FakeDiaryRepository(diaryEntry);

        final cubit = DiaryEntryCubit(
          mockUserRepository,
          mockDiaryRepository,
          mockHangoverSeverityPredictor,
          diaryEntry,
        );
        await cubit.stream.first;

        await cubit.removeDrink(consumedDrink);

        expect(cubit.state.diaryEntry.drinks, isEmpty);
      });
    });

    group('setHangoverSeverity', () {
      test('should set the hangover severity', () async {
        final diaryEntry = generateDiaryEntry(
          id: faker.guid.guid(),
          drinks: [generateConsumedDrink()],
          stomachFullness: StomachFullness.full,
        );
        final mockDiaryRepository = FakeDiaryRepository(diaryEntry);

        final cubit = DiaryEntryCubit(
          mockUserRepository,
          mockDiaryRepository,
          mockHangoverSeverityPredictor,
          diaryEntry,
        );
        await cubit.stream.first;

        const severity = HangoverSeverity.mild;
        await cubit.setHangoverSeverity(severity);

        expect(cubit.state.diaryEntry.hangoverSeverity, severity);
      });
    });

    group('drinks', () {
      test('should contain the consumed drinks ordered by startTime descending', () async {
        final dateTime = faker.date.dateTime();
        final consumedDrinks = [
          generateConsumedDrink(startTime: dateTime.subtract(const Duration(hours: 1))),
          generateConsumedDrink(startTime: dateTime.add(const Duration(hours: 1))),
          generateConsumedDrink(startTime: dateTime),
        ];
        final diaryEntry = generateDiaryEntry(id: faker.guid.guid(), drinks: consumedDrinks);
        final mockDiaryRepository = FakeDiaryRepository(diaryEntry);

        final cubit = DiaryEntryCubit(
          mockUserRepository,
          mockDiaryRepository,
          mockHangoverSeverityPredictor,
          diaryEntry,
        );
        await cubit.stream.first;

        expect(cubit.state.drinks, [consumedDrinks[1], consumedDrinks[2], consumedDrinks[0]]);
      });
    });

    group('recentDrinks', () {
      test('should contain the consumed drinks that are distinct by name ordered by startTime descending', () async {
        final dateTime = faker.date.dateTime();
        final consumedDrinks = [
          generateConsumedDrink(name: 'test', startTime: dateTime),
          generateConsumedDrink(name: 'test', startTime: dateTime.subtract(const Duration(hours: 1))),
          generateConsumedDrink(name: 'not test', startTime: dateTime.add(const Duration(hours: 2))),
        ];
        final diaryEntry = generateDiaryEntry(id: faker.guid.guid(), drinks: consumedDrinks);
        final mockDiaryRepository = FakeDiaryRepository(diaryEntry);

        final cubit = DiaryEntryCubit(
          mockUserRepository,
          mockDiaryRepository,
          mockHangoverSeverityPredictor,
          diaryEntry,
        );
        await cubit.stream.first;

        expect(cubit.state.recentDrinks, [consumedDrinks[2], consumedDrinks[0]]);
      });
    });
  });
}
