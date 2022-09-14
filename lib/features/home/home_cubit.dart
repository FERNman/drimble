import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_repository.dart';
import '../../data/consumed_drinks_repository.dart';
import '../../domain/bac_calculator.dart';
import '../../domain/bac_calulation_results.dart';
import '../../domain/drink/consumed_drink.dart';
import '../common/disposable.dart';

class HomeCubit extends Cubit<HomeCubitState> with Disposable {
  final AuthRepository _authRepository;
  final ConsumedDrinksRepository _consumedDrinksRepository;

  HomeCubit(this._authRepository, this._consumedDrinksRepository)
      : super(HomeCubitState(todaysDrinks: [], calculationResults: BACCalculationResults([]))) {
    _subscribeToRepository();
  }

  void deleteDrink(ConsumedDrink drink) {
    _consumedDrinksRepository.removeDrink(drink);
  }

  void _subscribeToRepository() {
    addSubscription(_consumedDrinksRepository.observeDrinksOnDate(DateTime.now()).listen(_calculateBAC));
  }

  void _calculateBAC(List<ConsumedDrink> drinks) async {
    final user = await _authRepository.getUser();

    if (drinks.isNotEmpty) {
      final calculator = BACCalculator(user!);
      final results = await compute(calculator.calculate, drinks);

      emit(HomeCubitState(todaysDrinks: drinks, calculationResults: results));
    } else {
      emit(HomeCubitState(todaysDrinks: drinks, calculationResults: BACCalculationResults([])));
    }
  }
}

class HomeCubitState {
  final List<ConsumedDrink> todaysDrinks;
  final BACCalculationResults calculationResults;

  double get unitsOfAlcohol => todaysDrinks.fold(0.0, (total, it) => total + it.unitsOfAlcohol);
  int get calories => todaysDrinks.fold(0, (calories, it) => calories + it.calories);

  HomeCubitState({required this.todaysDrinks, required this.calculationResults});
}
