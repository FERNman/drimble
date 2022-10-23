import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/consumed_drinks_repository.dart';
import '../../data/diary_repository.dart';
import '../../data/user_repository.dart';
import '../../domain/bac_calculator.dart';
import '../../domain/bac_calulation_results.dart';
import '../../domain/diary/consumed_drink.dart';
import '../../domain/diary/diary_entry.dart';
import '../../infra/disposable.dart';
import '../../infra/extensions/floor_date_time.dart';

class DiaryCubit extends Cubit<DiaryCubitState> with Disposable {
  final UserRepository _userRepository;
  final ConsumedDrinksRepository _consumedDrinksRepository;
  final DiaryRepository _diaryRepository;

  DiaryCubit(this._userRepository, this._diaryRepository, this._consumedDrinksRepository)
      : super(DiaryCubitState.initial(date: DateTime.now())) {
    _subscribeToRepository();
  }

  void switchDate(DateTime date) {
    if (!DateUtils.isSameDay(date.floorToDay(), state.date)) {
      emit(DiaryCubitState.initial(date: date.floorToDay()));
    }
  }

  void markAsDrinkFreeDay() {
    _diaryRepository.markAsDrinkFree(state.date);
  }

  void deleteDrink(ConsumedDrink drink) {
    _consumedDrinksRepository.removeDrink(drink);
  }

  void _subscribeToRepository() {
    final dateChangedStream =
        stream.distinct((previous, next) => previous.date.isAtSameMomentAs(next.date)).startWith(state);

    addSubscription(dateChangedStream
        .flatMap((value) => _consumedDrinksRepository.observeDrinksOnDate(value.date))
        .listen(_calculateBAC));

    addSubscription(dateChangedStream
        .flatMap((value) => _diaryRepository.overserveEntryOnDate(value.date))
        .listen((item) => emit(state.updateDiaryEntry(item))));
  }

  void _calculateBAC(List<ConsumedDrink> drinks) async {
    final user = await _userRepository.user;

    if (drinks.isNotEmpty) {
      final calculator = BACCalculator(user!);
      final results = await compute(calculator.calculate, drinks);

      emit(state.copyWith(drinks: drinks, calculationResults: results));
    } else {
      emit(state.copyWith(drinks: drinks, calculationResults: BACCalculationResults([])));
    }
  }
}

class DiaryCubitState {
  final DateTime date;
  final DiaryEntry? diaryEntry;
  final List<ConsumedDrink> drinks;
  final BACCalculationResults calculationResults;

  final bool shouldShowChart;
  final double unitsOfAlcohol;
  final int calories;

  DiaryCubitState({
    required this.date,
    required this.diaryEntry,
    required this.drinks,
    required this.calculationResults,
  })  : shouldShowChart = DateUtils.isSameDay(DateTime.now(), date),
        unitsOfAlcohol = drinks.fold(0.0, (total, it) => total + it.unitsOfAlcohol),
        calories = drinks.fold(0, (calories, it) => calories + it.calories);

  DiaryCubitState.initial({required DateTime date})
      : date = date.floorToDay(),
        shouldShowChart = DateUtils.isSameDay(DateTime.now(), date),
        diaryEntry = null,
        drinks = [],
        calculationResults = BACCalculationResults([]),
        unitsOfAlcohol = 0,
        calories = 0;

  DiaryCubitState copyWith({
    List<ConsumedDrink>? drinks,
    BACCalculationResults? calculationResults,
  }) =>
      DiaryCubitState(
        date: date,
        diaryEntry: diaryEntry,
        drinks: drinks ?? this.drinks,
        calculationResults: calculationResults ?? this.calculationResults,
      );

  DiaryCubitState updateDiaryEntry(DiaryEntry? entry) => DiaryCubitState(
        date: date,
        diaryEntry: entry,
        drinks: drinks,
        calculationResults: calculationResults,
      );
}
