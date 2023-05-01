import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/diary_repository.dart';
import '../../data/drinks_repository.dart';
import '../../domain/alcohol/drink.dart';
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
      _diaryRepository.observeLatestDrinks().map(_calculateState).asyncMap((event) => event).listen(emit),
    );
  }

  Future<AddDrinkCubitState> _calculateState(List<ConsumedDrink> recentlyConsumedDrinks) async {
    final commonDrinks = _drinksRepository.getCommonDrinks();
    // This is ugly, but recentlyConsumedDrinks only contains up to 3 elements, so we should be fine performance-wise
    final recentDrinks = recentlyConsumedDrinks.map((e) => _drinksRepository.findDrinkByName(e.name)).toList();

    return state.copyWith(recentDrinks: recentDrinks, commonDrinks: commonDrinks);
  }
}

class AddDrinkCubitState {
  final List<Drink> commonDrinks;
  final List<Drink> recentDrinks;
  final String search;

  AddDrinkCubitState({this.recentDrinks = const [], this.commonDrinks = const [], this.search = ''});

  AddDrinkCubitState copyWith({
    List<Drink>? recentDrinks,
    List<Drink>? commonDrinks,
    String? search,
  }) =>
      AddDrinkCubitState(
        recentDrinks: recentDrinks ?? this.recentDrinks,
        commonDrinks: commonDrinks ?? this.commonDrinks,
        search: search ?? this.search,
      );
}
