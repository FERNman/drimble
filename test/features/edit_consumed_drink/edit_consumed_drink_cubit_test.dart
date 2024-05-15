import 'package:drimble/data/diary_repository.dart';
import 'package:drimble/data/drinks_repository.dart';
import 'package:drimble/domain/date.dart';
import 'package:drimble/domain/diary/consumed_cocktail.dart';
import 'package:drimble/domain/diary/diary_entry.dart';
import 'package:drimble/features/edit_consumed_drink/edit_consumed_drink_cubit.dart';
import 'package:drimble/infra/extensions/copy_date_time.dart';
import 'package:drimble/infra/l10n/l10n.dart';
import 'package:drimble/infra/push_notifications_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../generate_entities.dart';
import 'edit_consumed_drink_cubit_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<DiaryRepository>(),
  MockSpec<DrinksRepository>(),
  MockSpec<PushNotificationsService>(),
  MockSpec<AppLocalizations>(),
])
void main() {
  group(EditConsumedDrinkCubit, () {
    final date = faker.date.dateTime();

    test('should schedule a push notification to track tomorrows hangover if the drink was consumed today', () async {
      final diaryRepository = MockDiaryRepository();
      final drinksRepository = MockDrinksRepository();
      final mockPushNotificationsService = MockPushNotificationsService();

      final today = Date.today();

      final consumedDrink = generateConsumedDrink(startTime: today.toDateTime().add(const Duration(hours: 1)));
      final diaryEntry = generateDiaryEntry(drinks: [consumedDrink], date: today);

      final cubit = EditConsumedDrinkCubit(
        diaryRepository,
        mockPushNotificationsService,
        MockAppLocalizations(),
        drinksRepository,
        diaryEntry: diaryEntry,
        consumedDrink: consumedDrink,
      );

      cubit.updateStartTime(today.toDateTime().add(const Duration(hours: 2)));
      await cubit.save();

      verify(mockPushNotificationsService.scheduleNotification(
        any,
        title: anyNamed('title'),
        description: anyNamed('description'),
        at: anyNamed('at'),
      ));
    });

    group('save', () {
      test('should save the diary entry with the original drink if no properties were changed', () async {
        final diaryRepository = MockDiaryRepository();
        final drinksRepository = MockDrinksRepository();

        final consumedDrink = generateConsumedDrink();
        final diaryEntry = generateDiaryEntry(drinks: [consumedDrink]);

        final cubit = EditConsumedDrinkCubit(
          diaryRepository,
          MockPushNotificationsService(),
          MockAppLocalizations(),
          drinksRepository,
          diaryEntry: diaryEntry,
          consumedDrink: consumedDrink,
        );

        await cubit.save();

        final updatedDiaryEntry = verify(diaryRepository.saveDiaryEntry(captureAny)).captured.first as DiaryEntry;
        expect(updatedDiaryEntry.drinks, hasLength(1));
        expect(updatedDiaryEntry.drinks.first, consumedDrink);
      });

      test('should save the diary entry with the updated drinks after changing a property', () async {
        final diaryRepository = MockDiaryRepository();
        final drinksRepository = MockDrinksRepository();

        final consumedDrink = generateConsumedDrink(volume: 200);
        final diaryEntry = generateDiaryEntry(drinks: [consumedDrink]);

        final cubit = EditConsumedDrinkCubit(
          diaryRepository,
          MockPushNotificationsService(),
          MockAppLocalizations(),
          drinksRepository,
          diaryEntry: diaryEntry,
          consumedDrink: consumedDrink,
        );

        const volume = 100;
        cubit.updateVolume(volume);
        await cubit.save();

        final updatedDiaryEntry = verify(diaryRepository.saveDiaryEntry(captureAny)).captured.first as DiaryEntry;
        expect(updatedDiaryEntry.drinks, hasLength(1));
        expect(updatedDiaryEntry.drinks.first.volume, volume);
      });
    });

    group('updateStartTime', () {
      test('should correctly update the date if the time is before 6am', () {
        final at10Am = date.copyWith(hour: 10);
        final drink = generateConsumedDrink(startTime: at10Am);
        final cubit = EditConsumedDrinkCubit(
          MockDiaryRepository(),
          MockPushNotificationsService(),
          MockAppLocalizations(),
          MockDrinksRepository(),
          diaryEntry: generateDiaryEntry(drinks: [drink]),
          consumedDrink: drink,
        );

        final at3am = date.copyWith(hour: 3);
        cubit.updateStartTime(at3am);

        expect(cubit.state.consumedDrink.startTime.day, at10Am.add(const Duration(days: 1)).day);
      });

      test('should not update the date if the start time was already before 6am', () {
        final at5Am = date.copyWith(hour: 5);
        final drink = generateConsumedDrink(startTime: at5Am);
        final cubit = EditConsumedDrinkCubit(
          MockDiaryRepository(),
          MockPushNotificationsService(),
          MockAppLocalizations(),
          MockDrinksRepository(),
          diaryEntry: generateDiaryEntry(drinks: [drink]),
          consumedDrink: drink,
        );

        final at3am = date.copyWith(hour: 3);
        cubit.updateStartTime(at3am);

        expect(cubit.state.consumedDrink.startTime.day, at5Am.day);
      });

      test('should reset the date if it was before 6am but is changed to after 6am', () {
        final at5Am = date.copyWith(hour: 5);
        final drink = generateConsumedDrink(startTime: at5Am);
        final cubit = EditConsumedDrinkCubit(
          MockDiaryRepository(),
          MockPushNotificationsService(),
          MockAppLocalizations(),
          MockDrinksRepository(),
          diaryEntry: generateDiaryEntry(drinks: [drink]),
          consumedDrink: drink,
        );

        final at12pm = date.copyWith(hour: 12);
        cubit.updateStartTime(at12pm);

        expect(cubit.state.consumedDrink.startTime.day, at5Am.subtract(const Duration(days: 1)).day);
      });
    });

    group('Cocktails', () {
      final cocktail = generateCocktail();
      final consumedCocktail = generateConsumedCocktailFromCocktail(cocktail);

      final mockDrinksRepository = MockDrinksRepository();

      setUp(() {
        when(mockDrinksRepository.findDrinkByName(consumedCocktail.name)).thenAnswer((_) => cocktail);
      });

      test('should still be a cocktail after changing the amount', () {
        final cubit = EditConsumedDrinkCubit(
          MockDiaryRepository(),
          MockPushNotificationsService(),
          MockAppLocalizations(),
          mockDrinksRepository,
          diaryEntry: generateDiaryEntry(drinks: [consumedCocktail]),
          consumedDrink: consumedCocktail,
        );

        cubit.updateVolume(100);

        expect(cubit.state.consumedDrink, isA<ConsumedCocktail>());
      });

      test('should throw an exception when trying to change the ABV directly', () {
        final cubit = EditConsumedDrinkCubit(
          MockDiaryRepository(),
          MockPushNotificationsService(),
          MockAppLocalizations(),
          mockDrinksRepository,
          diaryEntry: generateDiaryEntry(drinks: [consumedCocktail]),
          consumedDrink: consumedCocktail,
        );

        expect(() => cubit.updateABV(50), throwsA(isA<AssertionError>()));
      });
    });
  });
}
