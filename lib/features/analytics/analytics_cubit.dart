import 'dart:math';

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
import '../../domain/user/goals.dart';
import '../../domain/user/user.dart';
import '../../infra/disposable.dart';
import '../../infra/extensions/floor_date_time.dart';

class AnalyticsCubit extends Cubit<AnalyticsCubitState> with Disposable {
  final DrinksRepository _drinksRepository;
  final DiaryRepository _diaryRepository;
  final UserRepository _userRepository;

  AnalyticsCubit(this._drinksRepository, this._diaryRepository, this._userRepository, {DateTime? date})
      : super(AnalyticsCubitState(
          date: date ?? DateTime.now(),
          averageAlcoholPerSession: 0,
          changeOfAverageAlcohol: 0,
          alcoholByDay: {},
          numberOfDrinks: 0,
          highestBAC: 0,
          calories: 0,
          goals: const Goals(),
        )) {
    _initState();
  }

  void _initState() {
    final firstDayOfLastWeek = state.firstDayOfWeek.subtract(AnalyticsCubitState.oneWeek);
    final drinksLastWeek = _drinksRepository.observeDrinksBetweenDays(firstDayOfLastWeek, state.firstDayOfWeek);
    final drinksThisWeek = _drinksRepository.observeDrinksBetweenDays(state.firstDayOfWeek, state.lastDayOfWeek);
    final diaryEntries = _diaryRepository.observeEntriesBetween(state.firstDayOfWeek, state.lastDayOfWeek);
    final user = _userRepository.observeUser().whereNotNull();

    addSubscription(
      Rx.combineLatest4(drinksLastWeek, drinksThisWeek, diaryEntries, user, _calculateState)
          .asyncMap((event) => event)
          .listen(emit),
    );
  }

  Future<AnalyticsCubitState> _calculateState(
    List<Drink> lastWeeksDrinks,
    List<Drink> thisWeeksDrinks,
    List<DiaryEntry> diaryEntries,
    User user,
  ) async {
    final alcoholByDayLastWeek = _foldDrinksByDay(lastWeeksDrinks);
    final alcoholByDayThisWeek = _foldDrinksAndDiaryEntries(thisWeeksDrinks, diaryEntries);

    final highestBAC = await _calculateHighestBAC(user, thisWeeksDrinks);

    final averageAlcoholPerSessionThisWeek = _calculateAverageAlcoholPerSession(alcoholByDayThisWeek);
    final averageAlcoholPerSessionLastWeek = _calculateAverageAlcoholPerSession(alcoholByDayLastWeek);

    final changeOfAverageAlcohol = _calculateChangeToLastWeek(
      alcoholThisWeek: averageAlcoholPerSessionThisWeek,
      alcoholLastWeek: averageAlcoholPerSessionLastWeek,
    );

    return AnalyticsCubitState(
      date: state.firstDayOfWeek,
      averageAlcoholPerSession: averageAlcoholPerSessionThisWeek,
      changeOfAverageAlcohol: changeOfAverageAlcohol,
      alcoholByDay: alcoholByDayThisWeek,
      numberOfDrinks: thisWeeksDrinks.length,
      calories: thisWeeksDrinks.fold(0, (sum, el) => sum + el.calories),
      highestBAC: highestBAC,
      goals: user.goals,
    );
  }

  static double _calculateAverageAlcoholPerSession(Map<DateTime, double?> alcoholByDay) {
    final asList = alcoholByDay.values.whereNotNull();
    final total = asList.fold<double>(0.0, (sum, el) => sum + el);
    final sessions = asList.length;
    return total / max(sessions, 1);
  }

  static double _calculateChangeToLastWeek({
    required double alcoholThisWeek,
    required double alcoholLastWeek,
  }) {
    if (alcoholLastWeek == 0) {
      if (alcoholThisWeek == 0) {
        return 0;
      }

      // Always +100% if no alcohol was conusmed last week (even though technically it's inf)
      return 1;
    }

    return (alcoholThisWeek / alcoholLastWeek) - 1;
  }

  Map<DateTime, double?> _foldDrinksAndDiaryEntries(List<Drink> drinks, List<DiaryEntry> diaryEntries) {
    // There is at most one diary entry per day
    final diaryEntriesByDay = diaryEntries.groupFoldBy((el) => el.date, (_, el) => el);
    final gramsOfAlcoholByDay = _foldDrinksByDay(drinks);

    final Map<DateTime, double?> results = {};

    for (int i = 0; i < AnalyticsCubitState.oneWeek.inDays; i++) {
      final date = state.firstDayOfWeek.add(Duration(days: i));
      final diaryEntry = diaryEntriesByDay[date];
      if (diaryEntry == null) {
        results[date] = null;
      } else if (diaryEntry.isDrinkFreeDay) {
        results[date] = 0;
      } else {
        // Technically, gramsOfAlcoholByDate[date] must not be null here. However, if the diary entries stream emits
        // before the alcohol stream, we might be in an invalid state (and gramsOfAlcoholByDate[date] == null).
        // Since this doesn't really matter because it will be "fixed" immediately, we'll accept it for now.
        results[date] = gramsOfAlcoholByDay[date] ?? 0.0;
      }
    }

    return results;
  }

  Map<DateTime, double> _foldDrinksByDay(List<Drink> drinks) {
    return drinks.groupFoldBy(
      (el) => el.date,
      (sum, el) => (sum ?? 0.0) + el.gramsOfAlcohol,
    );
  }

  Future<double> _calculateHighestBAC(User user, List<Drink> drinks) async {
    // This is a bad way of doing it since it requires a lot of computation.
    // However, it's the only way to do it without having to store the BAC for every day in the database.
    final calculator = BACCalculator(user);
    final args = BACCalculationArgs(
      drinks: drinks,
      startTime: state.firstDayOfWeek,
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

  final Map<DateTime, double?> alcoholByDay;
  final Map<DateTime, bool?> drinkFreeDays;
  final double totalAlcohol;
  final double highestBAC;
  final int calories;
  final int numberOfDrinks;

  final double averageAlcoholPerSession;

  /// The change in percent compared to last week, from -inf to +inf
  final double changeOfAverageAlcohol;

  final Goals goals;

  AnalyticsCubitState({
    required DateTime date,
    required this.changeOfAverageAlcohol,
    required this.averageAlcoholPerSession,
    required this.alcoholByDay,
    required this.numberOfDrinks,
    required this.highestBAC,
    required this.calories,
    required this.goals,
  })  : firstDayOfWeek = date.floorToWeek(),
        lastDayOfWeek = date.floorToWeek().add(oneWeek),
        totalAlcohol = _sum(alcoholByDay),
        drinkFreeDays = _mapAlcoholToDrinkFreeDays(alcoholByDay) {}

  static Map<DateTime, bool?> _mapAlcoholToDrinkFreeDays(Map<DateTime, double?> alcoholPerDay) =>
      alcoholPerDay.map((key, value) => MapEntry(key, value == null ? null : value == 0.0));

  static double _sum(Map<DateTime, double?> alcoholPerDay) =>
      alcoholPerDay.values.whereNotNull().fold(0.0, (total, el) => total + el);
}

extension Week on DateTime {
  DateTime floorToWeek() => subtract(Duration(days: weekday - 1)).floorToDay();
}
