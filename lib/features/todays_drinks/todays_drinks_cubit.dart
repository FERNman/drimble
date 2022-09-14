import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/consumed_drinks_repository.dart';
import '../../domain/drink/consumed_drink.dart';
import '../common/disposable.dart';

class TodaysDrinksCubit extends Cubit<TodaysDrinksCubitState> with Disposable {
  final ConsumedDrinksRepository _repository;

  TodaysDrinksCubit(this._repository) : super(const TodaysDrinksCubitState(drinks: [])) {
    _subscribeToRepository();
  }

  void removeDrink(ConsumedDrink drink) {
    _repository.removeDrink(drink);
  }

  void _subscribeToRepository() {
    addSubscription(_repository
        .observeDrinksOnDate(DateTime.now())
        .listen((value) => emit(TodaysDrinksCubitState(drinks: value))));
  }
}

class TodaysDrinksCubitState {
  final List<ConsumedDrink> drinks;

  const TodaysDrinksCubitState({required this.drinks});
}
