import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_repository.dart';
import '../../data/consumed_drinks_repository.dart';
import '../../domain/bac_calculator.dart';
import '../../domain/drink/consumed_drink.dart';
import '../common/disposable.dart';

class HomeCubit extends Cubit<HomeCubitState> with Disposable {
  final AuthRepository _authRepository;
  final ConsumedDrinksRepository _consumedDrinksRepository;

  HomeCubit(this._authRepository, this._consumedDrinksRepository)
      : super(HomeCubitState(todaysDrinks: [], bloodAlcoholContent: {}, currentBAC: 0)) {
    _subscribeToRepository();
  }

  void deleteDrink(ConsumedDrink drink) {
    _consumedDrinksRepository.removeDrink(drink);
  }

  void _subscribeToRepository() {
    addSubscription(_consumedDrinksRepository.getConsumedDrinksOnDate(DateTime.now()).listen(_calculateBAC));
  }

  void _calculateBAC(List<ConsumedDrink> drinks) async {
    final user = await _authRepository.getUser();

    final bloodAlcoholContent = BacCalculator.calculate(user!, drinks);
    final now = DateTime.now();
    final currentBAC = bloodAlcoholContent.entries
        .reduce((lhs, rhs) => lhs.key.difference(now) < rhs.key.difference(now) ? lhs : rhs)
        .value;

    emit(HomeCubitState(todaysDrinks: drinks, bloodAlcoholContent: bloodAlcoholContent, currentBAC: currentBAC));
  }
}

class HomeCubitState {
  final List<ConsumedDrink> todaysDrinks;
  final Map<DateTime, double> bloodAlcoholContent;
  final double currentBAC;

  double get unitsOfAlcohol => todaysDrinks.fold(0.0, (total, it) => total + it.unitsOfAlcohol);
  int get calories => todaysDrinks.fold(0, (calories, it) => calories + it.calories);

  HomeCubitState({required this.todaysDrinks, required this.bloodAlcoholContent, required this.currentBAC});
}
