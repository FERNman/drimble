import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/user_repository.dart';
import '../../domain/user/user.dart';
import '../../domain/user/user_goals.dart';
import '../../infra/disposable.dart';

class EditWeeklyGoalCubit extends Cubit<BaseEditWeeklyGoalState> with Disposable {
  final UserRepository _userRepository;

  EditWeeklyGoalCubit(this._userRepository, {required UserGoals initialGoals})
      : super(EditWeeklyGoalStateLoading(
          weeklyDrinkFreeDays: initialGoals.weeklyDrinkFreeDays,
          weeklyGramsOfAlcohol: initialGoals.weeklyGramsOfAlcohol,
        )) {
    _loadUser();
  }

  void updateGramsOfAlcohol(int gramsOfAlcohol) {
    assert(gramsOfAlcohol >= 0);
    emit(state.copyWith(weeklyGramsOfAlcohol: gramsOfAlcohol));
  }

  void updateDrinkFreeDays(int drinkFreeDays) {
    assert(drinkFreeDays >= 0 && drinkFreeDays <= 7);
    emit(state.copyWith(weeklyDrinkFreeDays: drinkFreeDays));
  }

  Future<void> saveGoals() async {
    await _userRepository.update((state as EditWeeklyGoalState).user.copyWith(goals: state.goals));
  }

  void _loadUser() {
    addSubscription(_userRepository.observeUser().whereNotNull().listen((user) => emit(EditWeeklyGoalState(
          user: user,
          weeklyDrinkFreeDays: user.goals.weeklyDrinkFreeDays ?? state.weeklyDrinkFreeDays,
          weeklyGramsOfAlcohol: user.goals.weeklyGramsOfAlcohol ?? state.weeklyGramsOfAlcohol,
        ))));
  }
}

abstract class BaseEditWeeklyGoalState {
  final int? weeklyDrinkFreeDays;
  final int? weeklyGramsOfAlcohol;

  const BaseEditWeeklyGoalState({this.weeklyDrinkFreeDays, this.weeklyGramsOfAlcohol});

  BaseEditWeeklyGoalState copyWith({int? weeklyDrinkFreeDays, int? weeklyGramsOfAlcohol});

  UserGoals get goals => UserGoals(
        weeklyDrinkFreeDays: weeklyDrinkFreeDays,
        weeklyGramsOfAlcohol: weeklyGramsOfAlcohol,
      );
}

class EditWeeklyGoalStateLoading extends BaseEditWeeklyGoalState {
  const EditWeeklyGoalStateLoading({super.weeklyDrinkFreeDays, super.weeklyGramsOfAlcohol});

  @override
  BaseEditWeeklyGoalState copyWith({int? weeklyDrinkFreeDays, int? weeklyGramsOfAlcohol}) => EditWeeklyGoalStateLoading(
        weeklyGramsOfAlcohol: weeklyGramsOfAlcohol ?? this.weeklyGramsOfAlcohol,
        weeklyDrinkFreeDays: weeklyDrinkFreeDays ?? this.weeklyDrinkFreeDays,
      );
}

class EditWeeklyGoalState extends BaseEditWeeklyGoalState {
  static const int defaultWeeklyGramsOfAlcohol = 100;
  static const int defaultWeeklyDrinkFreeDays = 3;

  final User user;

  const EditWeeklyGoalState({required this.user, super.weeklyDrinkFreeDays, super.weeklyGramsOfAlcohol});

  @override
  EditWeeklyGoalState copyWith({int? weeklyDrinkFreeDays, int? weeklyGramsOfAlcohol}) => EditWeeklyGoalState(
        user: user,
        weeklyGramsOfAlcohol: weeklyGramsOfAlcohol ?? this.weeklyGramsOfAlcohol,
        weeklyDrinkFreeDays: weeklyDrinkFreeDays ?? this.weeklyDrinkFreeDays,
      );
}
