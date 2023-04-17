import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/diary_repository.dart';
import '../../domain/alcohol/alcohol.dart';
import '../../domain/diary/consumed_cocktail.dart';
import '../../domain/diary/consumed_drink.dart';
import '../../domain/diary/stomach_fullness.dart';

class EditDrinkCubit extends Cubit<EditDrinkCubitState> {
  final DiaryRepository _diaryRepository;

  EditDrinkCubit(this._diaryRepository, {required ConsumedDrink drink}) : super(EditDrinkCubitState(drink));

  void updateVolume(Milliliter volume) {
    emit(EditDrinkCubitState(state.drink.copyWith(volume: volume)));
  }

  void updatePercentage(Percentage abv) {
    assert(state.drink is! ConsumedCocktail);
    emit(EditDrinkCubitState(state.drink.copyWith(alcoholByVolume: abv)));
  }

  void updateStartTime(DateTime startTime) {
    // Drinks that were consumed before 0600 count to the previous day
    final shiftedTime = _shiftDate(startTime, state.drink.startTime);

    emit(EditDrinkCubitState(state.drink.copyWith(startTime: shiftedTime)));
  }

  void updateDuration(Duration duration) {
    emit(EditDrinkCubitState(state.drink.copyWith(duration: duration)));
  }

  void updateStomachFullness(StomachFullness value) {
    emit(EditDrinkCubitState(state.drink.copyWith(stomachFullness: value)));
  }

  void save() {
    _diaryRepository.addDrink(state.drink);
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
  ConsumedDrink drink;

  EditDrinkCubitState(this.drink);
}
