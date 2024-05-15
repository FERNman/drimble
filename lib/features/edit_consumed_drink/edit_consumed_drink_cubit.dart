import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/diary_repository.dart';
import '../../data/drinks_repository.dart';
import '../../domain/alcohol/alcohol.dart';
import '../../domain/alcohol/drink.dart';
import '../../domain/date.dart';
import '../../domain/diary/consumed_cocktail.dart';
import '../../domain/diary/consumed_drink.dart';
import '../../domain/diary/diary_entry.dart';
import '../../infra/l10n/l10n.dart';
import '../../infra/push_notifications_service.dart';

class EditConsumedDrinkCubit extends Cubit<EditDrinkCubitState> {
  final DiaryRepository _diaryRepository;

  final PushNotificationsService _pushNotificationsService;
  final AppLocalizations _localizations;

  EditConsumedDrinkCubit(
    this._diaryRepository,
    this._pushNotificationsService,
    this._localizations,
    DrinksRepository drinksRepository, {
    required DiaryEntry diaryEntry,
    required ConsumedDrink consumedDrink,
  }) : super(EditDrinkCubitState(diaryEntry, drinksRepository.findDrinkByName(consumedDrink.name), consumedDrink));

  void updateVolume(Milliliter volume) {
    emit(state.copyWith(state.consumedDrink.copyWith(volume: volume)));
  }

  void updateABV(Percentage abv) {
    assert(state.consumedDrink is! ConsumedCocktail);
    emit(state.copyWith(state.consumedDrink.copyWith(alcoholByVolume: abv)));
  }

  void updateStartTime(DateTime startTime) {
    // Drinks that were consumed before 0600 count to the previous day
    final shiftedTime = _shiftDate(startTime, state.consumedDrink.startTime);

    emit(state.copyWith(state.consumedDrink.copyWith(startTime: shiftedTime)));
  }

  void updateDuration(Duration duration) {
    emit(state.copyWith(state.consumedDrink.copyWith(duration: duration)));
  }

  Future<void> save() async {
    await _diaryRepository.saveDiaryEntry(state.diaryEntry);

    if (state.diaryEntry.date == Date.today()) {
      _pushNotificationsService.scheduleNotification(
        0,
        title: _localizations.pushNotification_trackHangoverSeverity_title,
        description: _localizations.pushNotification_trackHangoverSeverity_description,
        at: DateTime.now().add(const Duration(seconds: 10)),
      );
    }
  }

  DateTime _shiftDate(DateTime newTime, DateTime previousTime) {
    if (newTime.hour < 6) {
      if (previousTime.hour >= 6) {
        return newTime.add(const Duration(days: 1));
      }
    } else {
      if (previousTime.hour < 6) {
        return newTime.subtract(const Duration(days: 1));
      }
    }

    return newTime;
  }
}

class EditDrinkCubitState {
  final DiaryEntry _diaryEntry;
  DiaryEntry get diaryEntry => _diaryEntry.upsertDrink(consumedDrink.id, consumedDrink);

  final ConsumedDrink consumedDrink;

  final Drink _drink;
  List<Milliliter> get defaultServings => _drink.defaultServings;

  EditDrinkCubitState(this._diaryEntry, this._drink, this.consumedDrink);

  EditDrinkCubitState copyWith(ConsumedDrink consumedDrink) => EditDrinkCubitState(_diaryEntry, _drink, consumedDrink);
}
