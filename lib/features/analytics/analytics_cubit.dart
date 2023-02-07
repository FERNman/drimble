import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/diary_repository.dart';
import '../../data/drinks_repository.dart';
import '../../data/user_repository.dart';
import '../../domain/bac_calculator.dart';
import '../../domain/diary/diary_entry.dart';
import '../../domain/diary/drink.dart';
import '../../infra/disposable.dart';
import '../../infra/extensions/floor_date_time.dart';

class AnalyticsCubit extends Cubit<AnalyticsCubitState> with Disposable {
  final DrinksRepository _drinksRepository;
  final DiaryRepository _diaryRepository;
  final UserRepository _userRepository;

  AnalyticsCubit(this._drinksRepository, this._diaryRepository, this._userRepository, {DateTime? date})
      : super(AnalyticsCubitState(
          date: date ?? DateTime.now(),
          gramsOfAlcoholPerDay: [],
          gramsOfAlcoholLastWeek: 0,
          maxBAC: 0,
        )) {
    _initState();
  }

  void _initState() {
    addSubscription(_observeMaxBAC().listen((value) => emit(state.copyWith(maxBAC: value))));
    addSubscription(
        _observeGramsOfAlcoholPerDay().listen((value) => emit(state.copyWith(gramsOfAlcoholPerDay: value))));
    addSubscription(
        _observeGramsOfAlcoholForLastWeek().listen((value) => emit(state.copyWith(gramsOfAlcoholLastWeek: value))));
  }

  Stream<double> _observeGramsOfAlcoholForLastWeek() {
    final firstDayOfLastWeek = state.firstDayOfWeek.subtract(AnalyticsCubitState.oneWeek);
    return _drinksRepository
        .observeDrinksBetween(firstDayOfLastWeek, state.firstDayOfWeek)
        .map((results) => results.fold<double>(0, (sum, el) => sum + el.gramsOfAlcohol));
  }

  Stream<List<double?>> _observeGramsOfAlcoholPerDay() {
    final diaryEntries = _diaryRepository
        .observeEntriesBetween(state.firstDayOfWeek, state.lastDayOfWeek)
        .map((results) => results.groupFoldBy((el) => el.date.floorToDay(), (_, el) => el)); // Only one entry per day

    final gramsOfAlcoholByDay = _drinksRepository
        .observeDrinksBetween(state.firstDayOfWeek, state.lastDayOfWeek)
        .map((results) => results.groupFoldBy<DateTime, double>(
              (el) => el.date.floorToDay(),
              (sum, el) => (sum ?? 0.0) + el.gramsOfAlcohol,
            ));

    return Rx.combineLatest2(diaryEntries, gramsOfAlcoholByDay, _calculateGramsOfAlcoholPerDay);
  }

  List<double?> _calculateGramsOfAlcoholPerDay(
    Map<DateTime, DiaryEntry> diaryEntries,
    Map<DateTime, double> gramsOfAlcoholByDay,
  ) {
    final results = List<double?>.filled(state.timespan.inDays, null);
    for (int i = 0; i < state.timespan.inDays; i++) {
      final date = state.firstDayOfWeek.add(Duration(days: i)).floorToDay();
      final diaryEntry = diaryEntries[date];
      if (diaryEntry?.isDrinkFreeDay == true) {
        results[i] = 0;
      } else if (diaryEntry?.isDrinkFreeDay == false) {
        // Technically, gramsOfAlcoholByDate[date] must not be bull here. However, if the diary entries stream emits
        // before the alcohol stream, we might be in an invalid state (and gramsOfAlcoholByDate[date] == null).
        // Since this doesn't really matter because it will be fixed immediately, we'll accept it for now.
        results[i] = gramsOfAlcoholByDay[date];
      }
    }

    return results;
  }

  Stream<double> _observeMaxBAC() {
    return _drinksRepository.observeDrinksBetween(state.firstDayOfWeek, state.lastDayOfWeek).asyncMap(_calculateMaxBAC);
  }

  Future<double> _calculateMaxBAC(List<Drink> drinks) async {
    final user = await _userRepository.user;
    if (user == null) {
      return 0;
    }

    final calculator = BACCalculator(user);

    final startTime = state.firstDayOfWeek;
    final args = BACCalculationArgs(
      drinks: drinks,
      startTime: startTime,
      endTime: state.lastDayOfWeek,
    );

    final results = await compute(calculator.calculate, args);

    return results.maxBAC.value;
  }
}

class AnalyticsCubitState {
  static const oneWeek = Duration(days: 7);

  final DateTime firstDayOfWeek;
  final DateTime lastDayOfWeek;
  final List<double?> gramsOfAlcoholPerDay;
  final double gramsOfAlcoholLastWeek;
  final double maxBAC;

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
    required this.maxBAC,
  })  : firstDayOfWeek = date.floorToWeek().floorToDay(hour: 6),
        lastDayOfWeek = date.floorToWeek().floorToDay(hour: 6).add(oneWeek);

  AnalyticsCubitState._({
    required this.firstDayOfWeek,
    required this.lastDayOfWeek,
    required this.gramsOfAlcoholPerDay,
    required this.gramsOfAlcoholLastWeek,
    required this.maxBAC,
  });

  AnalyticsCubitState copyWith({
    List<double?>? gramsOfAlcoholPerDay,
    double? gramsOfAlcoholLastWeek,
    double? maxBAC,
  }) =>
      AnalyticsCubitState._(
        firstDayOfWeek: firstDayOfWeek,
        lastDayOfWeek: lastDayOfWeek,
        gramsOfAlcoholPerDay: gramsOfAlcoholPerDay ?? this.gramsOfAlcoholPerDay,
        gramsOfAlcoholLastWeek: gramsOfAlcoholLastWeek ?? this.gramsOfAlcoholLastWeek,
        maxBAC: maxBAC ?? this.maxBAC,
      );
}

extension Week on DateTime {
  DateTime floorToWeek() => subtract(Duration(days: weekday - 1));
}
