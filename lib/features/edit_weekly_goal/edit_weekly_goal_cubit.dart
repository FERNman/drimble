import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/user_repository.dart';
import '../../domain/user/goals.dart';
import '../../infra/disposable.dart';

class EditWeeklyGoalCubit extends Cubit<EditWeeklyGoalState> with Disposable {
  final UserRepository _userRepository;

  EditWeeklyGoalCubit(this._userRepository) : super(const EditWeeklyGoalState(goals: Goals())) {
    _loadUser();
  }

  void updateGramsOfAlcohol(int gramsOfAlcohol) {
    assert(gramsOfAlcohol >= 0);
    emit(state.copyWith(newGoals: state.newGoals.copyWith(weeklyGramsOfAlcohol: gramsOfAlcohol)));
  }

  void updateDrinkFreeDays(int drinkFreeDays) {
    assert(drinkFreeDays >= 0 && drinkFreeDays <= 7);
    emit(state.copyWith(newGoals: state.newGoals.copyWith(weeklyDrinkFreeDays: drinkFreeDays)));
  }

  Future<void> saveGoals() async {
    await _userRepository.setGoals(state.newGoals);
  }

  void _loadUser() {
    addSubscription(
        _userRepository.observeUser().whereNotNull().listen((user) => emit(EditWeeklyGoalState(goals: user.goals))));
  }
}

class EditWeeklyGoalState {
  final int defaultWeeklyGramsOfAlcohol = 100;
  final int defaultWeeklyDrinkFreeDays = 3;

  final Goals goals;
  final Goals newGoals;

  const EditWeeklyGoalState({required this.goals, Goals? newGoals}) : newGoals = newGoals ?? goals;

  EditWeeklyGoalState copyWith({Goals? goals, Goals? newGoals}) => EditWeeklyGoalState(
        goals: goals ?? this.goals,
        newGoals: newGoals ?? this.newGoals,
      );
}
