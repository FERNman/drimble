import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/user_repository.dart';
import '../../domain/user/goals.dart';
import '../../infra/disposable.dart';

class EditWeeklyGoalCubit extends Cubit<EditWeeklyGoalState> with Disposable {
  final UserRepository _userRepository;

  EditWeeklyGoalCubit(this._userRepository, {required Goals initialGoals})
      : super(EditWeeklyGoalState(goals: const Goals(), newGoals: initialGoals)) {
    _loadUser();
  }

  void updateGramsOfAlcohol(int gramsOfAlcohol) {
    assert(gramsOfAlcohol >= 0);
    emit(state.updateNewGoals(weeklyGramsOfAlcohol: gramsOfAlcohol));
  }

  void updateDrinkFreeDays(int drinkFreeDays) {
    assert(drinkFreeDays >= 0 && drinkFreeDays <= 7);
    emit(state.updateNewGoals(weeklyDrinkFreeDays: drinkFreeDays));
  }

  Future<void> saveGoals() async {
    await _userRepository.setGoals(state.newGoals);
  }

  void _loadUser() {
    addSubscription(_userRepository.observeUser().whereNotNull().listen((user) => emit(state.fromUser(user.goals))));
  }
}

class EditWeeklyGoalState {
  static const int defaultWeeklyGramsOfAlcohol = 100;
  static const int defaultWeeklyDrinkFreeDays = 3;

  final Goals goals;
  final Goals newGoals;

  const EditWeeklyGoalState({required this.goals, required this.newGoals});

  EditWeeklyGoalState fromUser(Goals goals) => EditWeeklyGoalState(
      goals: goals,
      newGoals: newGoals.copyWith(
        weeklyGramsOfAlcohol: goals.weeklyGramsOfAlcohol,
        weeklyDrinkFreeDays: goals.weeklyDrinkFreeDays,
      ));

  EditWeeklyGoalState updateNewGoals({int? weeklyDrinkFreeDays, int? weeklyGramsOfAlcohol}) => EditWeeklyGoalState(
        goals: goals,
        newGoals: newGoals.copyWith(
          weeklyGramsOfAlcohol: weeklyGramsOfAlcohol,
          weeklyDrinkFreeDays: weeklyDrinkFreeDays,
        ),
      );
}
