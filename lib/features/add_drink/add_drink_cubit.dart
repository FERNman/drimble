import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/consumed_drinks_repository.dart';
import '../../domain/alcohol/beverage.dart';
import '../../domain/alcohol/beverages.dart';
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
      emit(state.copyWith(recentlyAddedDrinks: lastThreeDrinks));
    }));
  }
}

class AddDrinkCubitState {
  final List<Beverage> commonBeverages = [
    Beverages.beer,
    Beverages.ale,
    Beverages.cider,
    Beverages.whiteWine,
    Beverages.redWine,
    Beverages.champagne,
    Beverages.whisky,
    Beverages.rum,
    Beverages.vodka
  ];

  final List<ConsumedDrink> recentlyAddedDrinks;
  final String search;

  AddDrinkCubitState({this.recentlyAddedDrinks = const [], this.search = ''});

  AddDrinkCubitState copyWith({
    List<ConsumedDrink>? recentlyAddedDrinks,
    String? search,
  }) =>
      AddDrinkCubitState(
        recentlyAddedDrinks: recentlyAddedDrinks ?? this.recentlyAddedDrinks,
        search: search ?? this.search,
      );
}
