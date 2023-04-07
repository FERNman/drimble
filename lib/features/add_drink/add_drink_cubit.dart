import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/diary_repository.dart';
import '../../data/drinks_repository.dart';
import '../../domain/diary/consumed_drink.dart';
import '../../infra/disposable.dart';

class AddDrinkCubit extends Cubit<AddDrinkCubitState> with Disposable {
  final DrinksRepository _drinksRepository;
  final DiaryRepository _diaryRepository;

  AddDrinkCubit(this._diaryRepository, this._drinksRepository) : super(AddDrinkCubitState()) {
    _initState();
  }

  void search(String term) {
    emit(state.copyWith(search: term));
  }

  void _initState() async {
    addSubscription(
      Rx.combineLatest2(_loadRecentDrinks(), _drinksRepository.observeCommonDrinks(), _calculateState).listen(emit),
    );
  }

  AddDrinkCubitState _calculateState(List<ConsumedDrink> recentDrinks, List<ConsumedDrink> commonDrinks) {
    return state.copyWith(recentDrinks: recentDrinks, commonDrinks: commonDrinks);
  }

  Stream<List<ConsumedDrink>> _loadRecentDrinks() {
    // TODO: This should use the DrinksRepository as well
    return _diaryRepository.observeLatestDrinks().map((items) => items.sublist(0, 3 > items.length ? items.length : 3));
  }
}

class AddDrinkCubitState {
  final List<ConsumedDrink> commonDrinks;
  final List<ConsumedDrink> recentDrinks;
  final String search;

  AddDrinkCubitState({this.recentDrinks = const [], this.commonDrinks = const [], this.search = ''});

  AddDrinkCubitState copyWith({
    List<ConsumedDrink>? recentDrinks,
    List<ConsumedDrink>? commonDrinks,
    String? search,
  }) =>
      AddDrinkCubitState(
        recentDrinks: recentDrinks ?? this.recentDrinks,
        commonDrinks: commonDrinks ?? this.commonDrinks,
        search: search ?? this.search,
      );
}
