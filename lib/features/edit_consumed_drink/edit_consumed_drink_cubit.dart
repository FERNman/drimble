import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/diary_repository.dart';
import '../../data/drinks_repository.dart';
import '../../domain/alcohol/alcohol.dart';
import '../../domain/alcohol/drink.dart';
import '../../domain/diary/consumed_cocktail.dart';
import '../../domain/diary/consumed_drink.dart';
import '../../domain/diary/diary_entry.dart';

class EditConsumedDrinkCubit extends Cubit<EditDrinkCubitState> {
  final DiaryRepository _diaryRepository;

  EditConsumedDrinkCubit(
    this._diaryRepository,
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
    await _diaryRepository.saveDrinkToDiaryEntry(state.diaryEntry, state.consumedDrink);
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
  final DiaryEntry diaryEntry;
  final ConsumedDrink consumedDrink;
  final Drink _drink;

  List<Milliliter> get defaultServings => _drink.defaultServings;

  const EditDrinkCubitState(this.diaryEntry, this._drink, this.consumedDrink);

  EditDrinkCubitState copyWith(ConsumedDrink consumedDrink) => EditDrinkCubitState(diaryEntry, _drink, consumedDrink);
}
