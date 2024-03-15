import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/drinks_repository.dart';
import '../../domain/alcohol/drink.dart';
import '../../infra/disposable.dart';

class AddConsumedDrinkCubit extends Cubit<AddDrinkCubitState> with Disposable {
  final DrinksRepository _drinksRepository;

  AddConsumedDrinkCubit(this._drinksRepository) : super(AddDrinkCubitState()) {
    _initState();
  }

  void search(String term) {
    emit(state.copyWith(search: term));
  }

  void _initState() {
    final commonDrinks = _drinksRepository.getCommonDrinks();
    emit(state.copyWith(commonDrinks: commonDrinks));
  }
}

class AddDrinkCubitState {
  final List<Drink> commonDrinks;
  final String search;

  AddDrinkCubitState({this.commonDrinks = const [], this.search = ''});

  AddDrinkCubitState copyWith({
    List<Drink>? commonDrinks,
    String? search,
  }) =>
      AddDrinkCubitState(
        commonDrinks: commonDrinks ?? this.commonDrinks,
        search: search ?? this.search,
      );
}
