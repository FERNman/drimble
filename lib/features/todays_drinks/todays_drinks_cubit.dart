import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/diary_repository.dart';
import '../../domain/date.dart';
import '../../domain/diary/consumed_drink.dart';
import '../../infra/disposable.dart';

class TodaysDrinksCubit extends Cubit<TodaysDrinksCubitState> with Disposable {
  final DiaryRepository _repository;

  TodaysDrinksCubit(this._repository, {required Date date})
      : super(TodaysDrinksCubitState(date: date, drinks: [])) {
    _subscribeToRepository();
  }

  void removeDrink(ConsumedDrink drink) {
    _repository.removeDrink(drink);
  }

  void _subscribeToRepository() {
    addSubscription(_repository.observeDrinksOnDate(state.date).listen((value) => emit(state.copyWith(drinks: value))));
  }
}

class TodaysDrinksCubitState {
  final Date date;
  final List<ConsumedDrink> drinks;

  const TodaysDrinksCubitState({required this.date, required this.drinks});

  TodaysDrinksCubitState copyWith({List<ConsumedDrink>? drinks}) =>
      TodaysDrinksCubitState(date: date, drinks: drinks ?? this.drinks);
}
