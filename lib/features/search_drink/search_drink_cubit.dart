import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/drinks_repository.dart';
import '../../domain/alcohol/drink.dart';
import '../../infra/disposable.dart';

class SearchDrinkCubit extends Cubit<SearchDrinkState> with Disposable {
  final DrinksRepository _drinksRepository;

  final Subject<String> _searchSubject = BehaviorSubject<String>();

  SearchDrinkCubit(this._drinksRepository)
      : super(SearchDrinkState(
          results: _drinksRepository.searchDrinksByName(''),
        )) {
    _initializeSearch();
  }

  void setSearch(String search) {
    _searchSubject.add(search);
  }

  void _initializeSearch() {
    addSubscription(
      _searchSubject
          .debounceTime(const Duration(milliseconds: 200))
          .map(_drinksRepository.searchDrinksByName)
          .map((results) => SearchDrinkState(results: results))
          .listen(emit),
    );
  }
}

class SearchDrinkState {
  final List<Drink> results;

  const SearchDrinkState({required this.results});
}
