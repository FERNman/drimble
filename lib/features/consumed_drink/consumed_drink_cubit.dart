import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/consumed_drinks_repository.dart';
import '../../domain/alcohol/beverage.dart';
import '../../domain/diary/consumed_drink.dart';

class ConsumedDrinkCubit extends Cubit<ConsumedDrinkCubitState> {
  final ConsumedDrinksRepository repository;

  ConsumedDrinkCubit.createDrink(this.repository, {required ConsumedDrink drink})
      : super(ConsumedDrinkCubitState.create(drink));

  ConsumedDrinkCubit.editDrink(this.repository, {required ConsumedDrink drink})
      : super(ConsumedDrinkCubitState.edit(drink));

  void update(ConsumedDrink drink) {
    // Drinks that were consumed before 0600 count to the previous day
    drink = _shiftDate(drink);

    emit(state.copyWith(drink: drink));
  }

  void save() {
    repository.save(state.drink);
  }

  ConsumedDrink _shiftDate(ConsumedDrink drink) {
    if (drink.startTime.hour < 6) {
      if (state.drink.startTime.hour >= 6) {
        drink.startTime = drink.startTime.add(const Duration(days: 1));
      }
    } else {
      if (state.drink.startTime.hour < 6) {
        drink.startTime = drink.startTime.subtract(const Duration(days: 1));
      }
    }

    return drink;
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
