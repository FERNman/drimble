import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/diary_repository.dart';
import '../../data/drinks_repository.dart';
import '../../infra/extensions/floor_date_time.dart';

class AnalyticsCubit extends Cubit<AnalyticsCubitState> {
  final DrinksRepository _drinksRepository;
  final DiaryRepository _diaryRepository;

  AnalyticsCubit(this._drinksRepository, this._diaryRepository, {DateTime? date})
      : super(AnalyticsCubitState(date: date ?? DateTime.now(), gramsOfAlcoholPerDay: [])) {
    loadGramsOfAlcohol();
  }

  void loadGramsOfAlcohol() async {
    final diaryEntries = await _diaryRepository
        .findEntriesBetween(state.startDate, state.endDate)
        .then((results) => results.groupFoldBy((el) => el.date.floorToDay(), (_, el) => el)); // Only one entry per day

    final gramsOfAlcoholByDay = await _drinksRepository
        .findDrinksBetween(state.startDate, state.endDate)
        .then((results) => results.groupFoldBy<DateTime, double>(
              (el) => el.date.floorToDay(),
              (total, el) => (total ?? 0.0) + el.gramsOfAlcohol,
            ));

    final results = List<double?>.filled(state.timespan.inDays, null);
    for (int i = 0; i < state.timespan.inDays; i++) {
      final date = state.startDate.add(Duration(days: i)).floorToDay();
      final diaryEntry = diaryEntries[date];
      if (diaryEntry?.isDrinkFreeDay == true) {
        results[i] = 0;
      } else if (diaryEntry?.isDrinkFreeDay == false) {
        // Must exist in this case, otherwise, we have a problem
        assert(gramsOfAlcoholByDay.containsKey(date));
        results[i] = gramsOfAlcoholByDay[date];
      }
    }

    emit(state.copyWith(gramsOfAlcoholPerDay: results));
  }
}

class AnalyticsCubitState {
  final DateTime startDate;
  final DateTime endDate;
  final List<double?> gramsOfAlcoholPerDay;
  final double maxBAC = 0.0;

  bool get isCurrentWeek {
    final now = DateTime.now();

    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get didDrink => gramsOfAlcoholPerDay.whereNotNull().any((element) => element > 0.0);

  Duration get timespan => endDate.difference(startDate);

  AnalyticsCubitState({
    required DateTime date,
    required this.gramsOfAlcoholPerDay,
  })  : startDate = date.floorToWeek().floorToDay(hour: 6),
        endDate = date.floorToWeek().floorToDay(hour: 6).add(const Duration(days: 7));

  AnalyticsCubitState._({required this.startDate, required this.endDate, required this.gramsOfAlcoholPerDay});

  AnalyticsCubitState copyWith({required List<double?> gramsOfAlcoholPerDay}) => AnalyticsCubitState._(
        startDate: startDate,
        endDate: endDate,
        gramsOfAlcoholPerDay: gramsOfAlcoholPerDay,
      );
}

extension Week on DateTime {
  DateTime floorToWeek() => subtract(Duration(days: weekday - 1));
}
