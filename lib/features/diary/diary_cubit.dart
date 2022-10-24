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
      : super(DiaryCubitState.initial(time: DateTime.now())) {
    _subscribeToRepository();
  }

  void switchDate(DateTime date) {
    if (!DateUtils.isSameDay(date, state.date)) {
      emit(DiaryCubitState.initial(time: date));
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
        .flatMap((value) => _diaryRepository.overserveEntryOnDate(value.date))
        .listen((item) => emit(state.updateDiaryEntry(item))));

    addSubscription(dateChangedStream
        .flatMap((value) => _consumedDrinksRepository.observeDrinksOnDate(value.date))
        .listen((drinks) => emit(state.updateDrinks(drinks))));

    addSubscription(dateChangedStream
        .flatMap((value) => _consumedDrinksRepository.observeDrinksBetween(
            value.date.floorToDay(hour: 6).subtract(const Duration(days: 1)),
            value.date.floorToDay(hour: 6).add(const Duration(days: 1))))
        .listen(_calculateBAC));
  }

  void _calculateBAC(List<ConsumedDrink> drinks) async {
    final user = await _userRepository.user;

    final calculator = BACCalculator(user!);

    final startTime = state.date.floorToDay(hour: 6);
    final args = BACCalculationArgs(
      drinks: drinks,
      startTime: startTime,
      endTime: startTime.add(const Duration(days: 1)),
    );

    final results = await compute(calculator.calculate, args);

    emit(state.updateBAC(results));
  }
}

class DiaryCubitState {
  final DateTime time;
  final DiaryEntry? diaryEntry;
  final List<ConsumedDrink> drinks;
  final BACCalculationResults calculationResults;

  final bool shouldShowCurrentBACIndicator;
  final double unitsOfAlcohol;
  final int calories;

  DateTime get date => time.floorToDay();

  DiaryCubitState({
    required this.time,
    required this.diaryEntry,
    required this.drinks,
    required this.calculationResults,
  })  : shouldShowCurrentBACIndicator = DateUtils.isSameDay(DateTime.now(), time),
        unitsOfAlcohol = drinks.fold(0.0, (total, it) => total + it.unitsOfAlcohol),
        calories = drinks.fold(0, (calories, it) => calories + it.calories);

  DiaryCubitState.initial({required this.time})
      : shouldShowCurrentBACIndicator = DateUtils.isSameDay(DateTime.now(), time),
        diaryEntry = null,
        drinks = [],
        calculationResults = BACCalculationResults([]),
        unitsOfAlcohol = 0,
        calories = 0;

  DiaryCubitState updateDiaryEntry(DiaryEntry? diaryEntry) => DiaryCubitState(
        time: time,
        diaryEntry: diaryEntry,
        drinks: drinks,
        calculationResults: calculationResults,
      );

  DiaryCubitState updateDrinks(List<ConsumedDrink> drinks) => DiaryCubitState(
        time: time,
        diaryEntry: diaryEntry,
        drinks: drinks,
        calculationResults: calculationResults,
      );

  DiaryCubitState updateBAC(BACCalculationResults calculationResults) => DiaryCubitState(
        time: time,
        diaryEntry: diaryEntry,
        drinks: drinks,
        calculationResults: calculationResults,
      );
}
