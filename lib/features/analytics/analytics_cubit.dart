import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/diary_repository.dart';
import '../../data/user_repository.dart';
import '../../domain/date.dart';
import '../../domain/diary/consumed_drink.dart';
import '../../domain/diary/diary_entry.dart';
import '../../domain/user/goals.dart';
import '../../domain/user/user.dart';
import '../../infra/disposable.dart';

class AnalyticsCubit extends Cubit<AnalyticsCubitState> with Disposable {
  final DiaryRepository _diaryRepository;
  final UserRepository _userRepository;

  AnalyticsCubit(this._diaryRepository, this._userRepository, {Date? date})
      : super(AnalyticsCubitState(date: date ?? Date.today())) {
    _initState();
  }

  void setDate(Date date) {
    emit(AnalyticsCubitState(date: date, goals: state.goals));
  }

  void _initState() {
    final dateChanged = stream.map((event) => event.firstDayOfWeek).distinct().startWith(state.firstDayOfWeek);

    final drinksLastWeek =
        dateChanged.flatMap((date) => _diaryRepository.observeDrinksBetweenDays(date.subtract(days: 7), date));
    final drinksThisWeek = dateChanged
        .flatMap((date) => _diaryRepository.observeDrinksBetweenDays(state.firstDayOfWeek, state.lastDayOfWeek));
    final diaryEntries = dateChanged
        .flatMap((date) => _diaryRepository.observeEntriesBetween(state.firstDayOfWeek, state.lastDayOfWeek));

    final user = _userRepository.observeUser().whereNotNull();

    addSubscription(
      Rx.combineLatest4(drinksLastWeek, drinksThisWeek, diaryEntries, user, _calculateState)
          .asyncMap((event) => event)
          .listen(emit),
    );
  }

  Future<AnalyticsCubitState> _calculateState(
    List<ConsumedDrink> lastWeeksDrinks,
    List<ConsumedDrink> thisWeeksDrinks,
    List<DiaryEntry> diaryEntries,
    User user,
  ) async {
    final alcoholByDayLastWeek = _foldDrinksByDay(lastWeeksDrinks);
    final alcoholByDayThisWeek = _foldDrinksAndDiaryEntries(thisWeeksDrinks, diaryEntries);

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
      calories: thisWeeksDrinks.map((drink) => drink.calories).sum,
      goals: user.goals,
    );
  }

  static double _calculateAverageAlcoholPerSession(Map<Date, double?> alcoholByDay) {
    final asList = alcoholByDay.values.whereNotNull();
    final total = asList.sum;
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

  Map<Date, double?> _foldDrinksAndDiaryEntries(List<ConsumedDrink> drinks, List<DiaryEntry> diaryEntries) {
    // There is at most one diary entry per day
    final diaryEntriesByDay = diaryEntries.groupFoldBy((el) => el.date, (_, el) => el);
    final gramsOfAlcoholByDay = _foldDrinksByDay(drinks);

    final Map<Date, double?> results = {};

    for (int i = 0; i < AnalyticsCubitState.daysInOneWeek; i++) {
      final date = state.firstDayOfWeek.add(days: i);
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

  Map<Date, double> _foldDrinksByDay(List<ConsumedDrink> drinks) {
    return drinks.groupFoldBy(
      (el) => el.date,
      (sum, el) => (sum ?? 0.0) + el.gramsOfAlcohol,
    );
  }
}

class AnalyticsCubitState {
  static const daysInOneWeek = 7;

  final Date firstDayOfWeek;
  final Date lastDayOfWeek;

  final Map<Date, double?> alcoholByDay;
  final Map<Date, bool?> drinkFreeDays;
  final double totalAlcohol;
  final int calories;
  final int numberOfDrinks;

  final double averageAlcoholPerSession;

  /// The change in percent compared to last week, from -inf to +inf
  final double changeOfAverageAlcohol;

  final Goals goals;

  AnalyticsCubitState({
    required Date date,
    this.changeOfAverageAlcohol = 0,
    this.averageAlcoholPerSession = 0,
    this.alcoholByDay = const {},
    this.numberOfDrinks = 0,
    this.calories = 0,
    this.goals = const Goals(),
  })  : firstDayOfWeek = date.floorToWeek(),
        lastDayOfWeek = date.floorToWeek().add(days: daysInOneWeek),
        totalAlcohol = _sum(alcoholByDay),
        drinkFreeDays = _mapAlcoholToDrinkFreeDays(alcoholByDay);

  static Map<Date, bool?> _mapAlcoholToDrinkFreeDays(Map<Date, double?> alcoholPerDay) =>
      alcoholPerDay.map((key, value) => MapEntry(key, value == null ? null : value == 0.0));

  static double _sum(Map<Date, double?> alcoholPerDay) => alcoholPerDay.values.whereNotNull().sum;
}
