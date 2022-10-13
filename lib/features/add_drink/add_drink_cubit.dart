import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/beverages_repository.dart';
import '../../data/consumed_drinks_repository.dart';
import '../../domain/alcohol/beverage.dart';
import '../../domain/alcohol/beverages.dart';
import '../../domain/diary/consumed_drink.dart';

class AddDrinkCubit extends Cubit<AddDrinkCubitState> {
  final ConsumedDrinksRepository _consumedDrinksRepository;
  final BeveragesRepository _beveragesRepository;

  AddDrinkCubit(this._beveragesRepository, this._consumedDrinksRepository)
      : super(AddDrinkCubitState()) {
    _fetchRecentDrinks();
  }

  void search(String term) {
    emit(state.copyWith(search: term));
  }

  void _fetchRecentDrinks() async {
    final recentDrinks = await _consumedDrinksRepository.getDrinksOnDate(DateTime.now());

    final lastThreeDrinks = recentDrinks.sublist(0, 3 > recentDrinks.length ? recentDrinks.length : 3);
    emit(state.copyWith(recentlyAddedDrinks: lastThreeDrinks));
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

  AddDrinkCubitState copyWith({List<ConsumedDrink>? recentlyAddedDrinks, String? search}) => AddDrinkCubitState(
        recentlyAddedDrinks: recentlyAddedDrinks ?? this.recentlyAddedDrinks,
        search: search ?? this.search,
      );
}
