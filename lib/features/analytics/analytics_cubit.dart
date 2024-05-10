import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/diary_repository.dart';
import '../../data/user_repository.dart';
import '../../domain/date.dart';
import '../../domain/diary/diary_entry.dart';
import '../../domain/user/user.dart';
import '../../domain/user/user_goals.dart';
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

    final diaryEntriesLastWeek =
        dateChanged.flatMap((date) => _diaryRepository.observeEntriesBetween(date.subtract(days: 7), date));
    final diaryEntries = dateChanged
        .flatMap((date) => _diaryRepository.observeEntriesBetween(state.firstDayOfWeek, state.lastDayOfWeek));

    final user = _userRepository.observeUser().whereNotNull();

    addSubscription(
      Rx.combineLatest3(diaryEntriesLastWeek, diaryEntries, user, _calculateState)
          .asyncMap((event) => event)
          .listen(emit),
    );
  }

  Future<AnalyticsCubitState> _calculateState(
    List<DiaryEntry> lastWeeksDiaryEntries,
    List<DiaryEntry> diaryEntries,
    User user,
  ) async {
    final alcoholByDayLastWeek = lastWeeksDiaryEntries.groupFoldBy((e) => e.date, (t, e) => e.gramsOfAlcohol);
    final alcoholByDayThisWeek = diaryEntries.groupFoldBy((e) => e.date, (t, e) => e.gramsOfAlcohol);

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
      alcoholByDay: _fillInMissingDays(alcoholByDayThisWeek),
      numberOfDrinks: diaryEntries.map((element) => element.drinks.length).sum,
      calories: diaryEntries.map((element) => element.calories).sum,
      goals: user.goals,
    );
  }

  Map<Date, double?> _fillInMissingDays(Map<Date, double> alcoholByDay) {
    final firstDay = state.firstDayOfWeek;
    final lastDay = state.lastDayOfWeek;

    final days = lastDay.difference(firstDay).inDays;
    final allDays = [for (var i = 0; i < days; i++) firstDay.add(days: i)];

    return Map.fromEntries(allDays.map((day) => MapEntry(day, alcoholByDay[day])));
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

  final UserGoals goals;

  AnalyticsCubitState({
    required Date date,
    this.changeOfAverageAlcohol = 0,
    this.averageAlcoholPerSession = 0,
    this.alcoholByDay = const {},
    this.numberOfDrinks = 0,
    this.calories = 0,
    this.goals = const UserGoals(),
  })  : firstDayOfWeek = date.floorToWeek(),
        lastDayOfWeek = date.floorToWeek().add(days: daysInOneWeek),
        totalAlcohol = _sum(alcoholByDay),
        drinkFreeDays = _mapAlcoholToDrinkFreeDays(alcoholByDay);

  static Map<Date, bool?> _mapAlcoholToDrinkFreeDays(Map<Date, double?> alcoholPerDay) =>
      alcoholPerDay.map((key, value) => MapEntry(key, value == null ? null : value == 0.0));

  static double _sum(Map<Date, double?> alcoholPerDay) => alcoholPerDay.values.whereNotNull().sum;
}
