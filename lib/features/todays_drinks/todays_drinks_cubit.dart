import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/drinks_repository.dart';
import '../../domain/date.dart';
import '../../domain/diary/drink.dart';
import '../../infra/disposable.dart';

class TodaysDrinksCubit extends Cubit<TodaysDrinksCubitState> with Disposable {
  final DrinksRepository _repository;

  TodaysDrinksCubit(this._repository, {required Date date})
      : super(TodaysDrinksCubitState(date: date, drinks: [])) {
    _subscribeToRepository();
  }

  void removeDrink(Drink drink) {
    _repository.removeDrink(drink);
  }

  void _subscribeToRepository() {
    addSubscription(_repository.observeDrinksOnDate(state.date).listen((value) => emit(state.copyWith(drinks: value))));
  }
}

class TodaysDrinksCubitState {
  final Date date;
  final List<Drink> drinks;

  const TodaysDrinksCubitState({required this.date, required this.drinks});

  TodaysDrinksCubitState copyWith({List<Drink>? drinks}) =>
      TodaysDrinksCubitState(date: date, drinks: drinks ?? this.drinks);
}
