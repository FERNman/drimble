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

  void switchDate(DateTime date) async {
    if (!DateUtils.isSameDay(date, state.date)) {
      final drinks = await _consumedDrinksRepository.getDrinksOnDate(date);
      final diaryEntry = await _diaryRepository.getEntryOnDate(date);

      emit(DiaryCubitState.initial(date: date, drinks: drinks, diaryEntry: diaryEntry));
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
  final DateTime date;
  final DiaryEntry? diaryEntry;
  final List<ConsumedDrink> drinks;
  final BACCalculationResults calculationResults;

  final double unitsOfAlcohol;
  final int calories;

  DiaryCubitState({
    required this.date,
    required this.diaryEntry,
    required this.drinks,
    required this.calculationResults,
  })  : unitsOfAlcohol = drinks.fold(0.0, (total, it) => total + it.unitsOfAlcohol),
        calories = drinks.fold(0, (calories, it) => calories + it.calories);

  DiaryCubitState.initial({
    required this.date,
    this.diaryEntry,
    this.drinks = const [],
  })  : calculationResults = BACCalculationResults.empty(
          startTime: date.floorToDay(hour: 6),
          endTime: date.floorToDay(hour: 6).add(const Duration(days: 1)),
          timestep: const Duration(minutes: 10),
        ),
        unitsOfAlcohol = 0,
        calories = 0;

  DiaryCubitState updateDiaryEntry(DiaryEntry? diaryEntry) => DiaryCubitState(
        date: date,
        diaryEntry: diaryEntry,
        drinks: drinks,
        calculationResults: calculationResults,
      );

  DiaryCubitState updateDrinks(List<ConsumedDrink> drinks) => DiaryCubitState(
        date: date,
        diaryEntry: diaryEntry,
        drinks: drinks,
        calculationResults: calculationResults,
      );

  DiaryCubitState updateBAC(BACCalculationResults calculationResults) => DiaryCubitState(
        date: date,
        diaryEntry: diaryEntry,
        drinks: drinks,
        calculationResults: calculationResults,
      );
}
