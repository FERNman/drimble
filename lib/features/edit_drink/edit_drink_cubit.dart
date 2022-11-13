import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/drinks_repository.dart';
import '../../domain/alcohol/milliliter.dart';
import '../../domain/alcohol/percentage.dart';
import '../../domain/diary/drink.dart';
import '../../domain/diary/stomach_fullness.dart';

class EditDrinkCubit extends Cubit<EditDrinkCubitState> {
  final DrinksRepository repository;

  EditDrinkCubit.createDrink(this.repository, {required Drink drink})
      : super(EditDrinkCubitState.create(drink));

  EditDrinkCubit.editDrink(this.repository, {required Drink drink})
      : super(EditDrinkCubitState.edit(drink));

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

class EditDrinkCubitState {
  final bool isEditing;

  Drink drink;

  EditDrinkCubitState.create(this.drink) : isEditing = false;

  EditDrinkCubitState.edit(this.drink) : isEditing = true;

  EditDrinkCubitState._({required this.isEditing, required this.drink});

  EditDrinkCubitState copyWith({required Drink drink}) =>
      EditDrinkCubitState._(isEditing: isEditing, drink: drink);
}
