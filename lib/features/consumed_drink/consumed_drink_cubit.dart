import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/consumed_drinks_repository.dart';
import '../../domain/drink/beverage.dart';
import '../../domain/drink/consumed_drink.dart';

class ConsumedDrinkCubit extends Cubit<ConsumedDrinkCubitState> {
  final ConsumedDrinksRepository repository;

  ConsumedDrinkCubit.createDrink(this.repository, {required ConsumedDrink drink})
      : super(ConsumedDrinkCubitState.create(drink));

  ConsumedDrinkCubit.editDrink(this.repository, {required ConsumedDrink drink})
      : super(ConsumedDrinkCubitState.edit(drink));

  void update(ConsumedDrink drink) {
    emit(state.copyWith(drink: drink));
  }

  void save() {
    repository.save(state.drink);
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
