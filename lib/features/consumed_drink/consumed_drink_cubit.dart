import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/consumed_drinks_repository.dart';
import '../../domain/alcohol/beverage.dart';
import '../../domain/alcohol/milliliter.dart';
import '../../domain/alcohol/percentage.dart';
import '../../domain/diary/consumed_drink.dart';
import '../../domain/diary/stomach_fullness.dart';

class ConsumedDrinkCubit extends Cubit<ConsumedDrinkCubitState> {
  final ConsumedDrinksRepository repository;

  ConsumedDrinkCubit.createDrink(this.repository, {required ConsumedDrink drink})
      : super(ConsumedDrinkCubitState.create(drink));

  ConsumedDrinkCubit.editDrink(this.repository, {required ConsumedDrink drink})
      : super(ConsumedDrinkCubitState.edit(drink));

  void updateVolume(Milliliter volume) {
    emit(state.copyWith(drink: state.drink.copyWith(volume: volume)));
  }

  void updatePercentage(Percentage abv) {
    emit(state.copyWith(drink: state.drink.copyWith(alcoholByVolume: abv)));
  }

  void updateStartTime(DateTime startTime) {
    // Drinks that were consumed before 0600 count to the previous day
    final shiftedTime = _shiftDate(startTime, state.drink.startTime);

    emit(state.copyWith(drink: state.drink.copyWith(startTime: shiftedTime)));
  }

  void updateDuration(Duration duration) {
    emit(state.copyWith(drink: state.drink.copyWith(duration: duration)));
  }

  void updateStomachFullness(StomachFullness value) {
    emit(state.copyWith(drink: state.drink.copyWith(stomachFullness: value)));
  }

  void save() {
    repository.save(state.drink);
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

class ConsumedDrinkCubitState {
  final bool isEditing;

  ConsumedDrink drink;

  ConsumedDrinkCubitState.create(this.drink) : isEditing = false;

  ConsumedDrinkCubitState.edit(this.drink) : isEditing = true;

  ConsumedDrinkCubitState._({required this.isEditing, required this.drink});

  Beverage get beverage => drink.beverage;

  ConsumedDrinkCubitState copyWith({required ConsumedDrink drink}) =>
      ConsumedDrinkCubitState._(isEditing: isEditing, drink: drink);
}
