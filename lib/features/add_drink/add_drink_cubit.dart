import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/consumed_drinks_repository.dart';
import '../../domain/alcohol/drinks.dart';
import '../../domain/diary/consumed_drink.dart';
import '../../infra/disposable.dart';

class AddDrinkCubit extends Cubit<AddDrinkCubitState> with Disposable {
  final ConsumedDrinksRepository _consumedDrinksRepository;

  AddDrinkCubit(this._consumedDrinksRepository) : super(AddDrinkCubitState()) {
    _fetchRecentDrinks();
  }

  void search(String term) {
    emit(state.copyWith(search: term));
  }

  void _fetchRecentDrinks() async {
    // TODO: This should be done differently
    addSubscription(_consumedDrinksRepository.observeLatestDrinks().listen((items) {
      final lastThreeDrinks = items.sublist(0, 3 > items.length ? items.length : 3);
      emit(state.copyWith(recentDrinks: lastThreeDrinks));
    }));
  }
}

class AddDrinkCubitState {
  final List<ConsumedDrink> commonDrinks = [
    Drinks.beer,
    Drinks.ale,
    Drinks.cider,
    Drinks.whiteWine,
    Drinks.redWine,
    Drinks.champagne,
    Drinks.whisky,
    Drinks.rum,
    Drinks.vodka
  ];

  final List<ConsumedDrink> recentDrinks;
  final String search;

  AddDrinkCubitState({this.recentDrinks = const [], this.search = ''});

  AddDrinkCubitState copyWith({
    List<ConsumedDrink>? recentDrinks,
    String? search,
  }) =>
      AddDrinkCubitState(
        recentDrinks: recentDrinks ?? this.recentDrinks,
        search: search ?? this.search,
      );
}
