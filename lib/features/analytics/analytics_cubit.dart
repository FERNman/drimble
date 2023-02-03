import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/diary_repository.dart';
import '../../data/drinks_repository.dart';
import '../../infra/extensions/floor_date_time.dart';

class AnalyticsCubit extends Cubit<AnalyticsCubitState> {
  final DrinksRepository _drinksRepository;
  final DiaryRepository _diaryRepository;

  AnalyticsCubit(this._drinksRepository, this._diaryRepository, {DateTime? date})
      : super(AnalyticsCubitState(
          date: date ?? DateTime.now(),
          gramsOfAlcoholPerDay: [],
          gramsOfAlcoholLastWeek: 0,
        )) {
    _initState();
  }

  void _initState() async {
    final gramsOfAlcoholPerDay = await _loadGramsOfAlcoholPerDay();
    final lastWeeksAlcohol = await _loadGramsOfAlcoholForLastWeek();

    emit(state.copyWith(
      gramsOfAlcoholPerDay: gramsOfAlcoholPerDay,
      gramsOfAlcoholLastWeek: lastWeeksAlcohol,
    ));
  }

  Future<double> _loadGramsOfAlcoholForLastWeek() async {
    final firstDayOfLastWeek = state.firstDayOfWeek.subtract(AnalyticsCubitState.oneWeek);
    return _drinksRepository
        .findDrinksBetween(firstDayOfLastWeek, state.firstDayOfWeek)
        .then((results) => results.fold<double>(0, (sum, el) => sum + el.gramsOfAlcohol));
  }

  Future<List<double?>> _loadGramsOfAlcoholPerDay() async {
    final diaryEntries = await _diaryRepository
        .findEntriesBetween(state.firstDayOfWeek, state.lastDayOfWeek)
        .then((results) => results.groupFoldBy((el) => el.date.floorToDay(), (_, el) => el)); // Only one entry per day

    final gramsOfAlcoholByDay = await _drinksRepository
        .findDrinksBetween(state.firstDayOfWeek, state.lastDayOfWeek)
        .then((results) => results.groupFoldBy<DateTime, double>(
              (el) => el.date.floorToDay(),
              (sum, el) => (sum ?? 0.0) + el.gramsOfAlcohol,
            ));

    final results = List<double?>.filled(state.timespan.inDays, null);
    for (int i = 0; i < state.timespan.inDays; i++) {
      final date = state.firstDayOfWeek.add(Duration(days: i)).floorToDay();
      final diaryEntry = diaryEntries[date];
      if (diaryEntry?.isDrinkFreeDay == true) {
        results[i] = 0;
      } else if (diaryEntry?.isDrinkFreeDay == false) {
        // Must exist in this case, otherwise, we have a problem
        assert(gramsOfAlcoholByDay.containsKey(date));
        results[i] = gramsOfAlcoholByDay[date];
      }
    }

    return results;
  }
}

class AnalyticsCubitState {
  static const oneWeek = Duration(days: 7);

  final DateTime firstDayOfWeek;
  final DateTime lastDayOfWeek;
  final List<double?> gramsOfAlcoholPerDay;
  final double gramsOfAlcoholLastWeek;

  bool get didDrink => gramsOfAlcoholPerDay.whereNotNull().any((element) => element > 0.0);
  double get totalGramsOfAlcohol => gramsOfAlcoholPerDay.fold<double>(0, (total, el) => total + (el ?? 0));

  /// The change in percent compared to last week.
  /// If no alcohol was consumed last week, this will display 100%
  double get changeToLastWeek => gramsOfAlcoholLastWeek > 0 ? totalGramsOfAlcohol / gramsOfAlcoholLastWeek : 2;
  Duration get timespan => lastDayOfWeek.difference(firstDayOfWeek);

  AnalyticsCubitState({
    required DateTime date,
    required this.gramsOfAlcoholPerDay,
    required this.gramsOfAlcoholLastWeek,
  })  : firstDayOfWeek = date.floorToWeek().floorToDay(hour: 6),
        lastDayOfWeek = date.floorToWeek().floorToDay(hour: 6).add(oneWeek);

  AnalyticsCubitState._({
    required this.firstDayOfWeek,
    required this.lastDayOfWeek,
    required this.gramsOfAlcoholPerDay,
    required this.gramsOfAlcoholLastWeek,
  });

  AnalyticsCubitState copyWith({
    required List<double?> gramsOfAlcoholPerDay,
    required double gramsOfAlcoholLastWeek,
  }) =>
      AnalyticsCubitState._(
        firstDayOfWeek: firstDayOfWeek,
        lastDayOfWeek: lastDayOfWeek,
        gramsOfAlcoholPerDay: gramsOfAlcoholPerDay,
        gramsOfAlcoholLastWeek: gramsOfAlcoholLastWeek,
      );
}

extension Week on DateTime {
  DateTime floorToWeek() => subtract(Duration(days: weekday - 1));
}
