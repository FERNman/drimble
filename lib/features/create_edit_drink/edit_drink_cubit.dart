import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/diary_repository.dart';
import '../../data/drinks_repository.dart';
import '../../domain/alcohol/alcohol.dart';
import '../../domain/alcohol/drink.dart';
import '../../domain/date.dart';
import '../../domain/diary/consumed_cocktail.dart';
import '../../domain/diary/consumed_drink.dart';
import '../../domain/diary/stomach_fullness.dart';
import '../../infra/extensions/set_date.dart';

class EditDrinkCubit extends Cubit<EditDrinkCubitState> {
  final DiaryRepository _diaryRepository;

  EditDrinkCubit.createConsumedDrink(
    this._diaryRepository, {
    required Date date,
    required Drink drink,
  }) : super(EditDrinkCubitState(drink, ConsumedDrink.fromDrink(drink, startTime: DateTime.now().setDate(date))));

  EditDrinkCubit.editConsumedDrink(
    this._diaryRepository,
    DrinksRepository drinksRepository, {
    required ConsumedDrink consumedDrink,
  }) : super(EditDrinkCubitState(drinksRepository.findDrinkByName(consumedDrink.name), consumedDrink));

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

  void updateStomachFullness(StomachFullness value) {
    emit(state.copyWith(state.consumedDrink.copyWith(stomachFullness: value)));
  }

  void save() {
    _diaryRepository.saveDrink(state.consumedDrink);
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
  final Drink drink;
  final ConsumedDrink consumedDrink;

  const EditDrinkCubitState(this.drink, this.consumedDrink);

  EditDrinkCubitState copyWith(ConsumedDrink consumedDrink) => EditDrinkCubitState(drink, consumedDrink);
}
