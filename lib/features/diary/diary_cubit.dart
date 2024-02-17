import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/diary_repository.dart';
import '../../data/user_repository.dart';
import '../../domain/bac/bac_calculator.dart';
import '../../domain/bac/bac_calulation_results.dart';
import '../../domain/date.dart';
import '../../domain/diary/consumed_drink.dart';
import '../../domain/diary/diary_entry.dart';
import '../../domain/diary/stomach_fullness.dart';
import '../../infra/disposable.dart';

class DiaryCubit extends Cubit<DiaryCubitState> with Disposable {
  final UserRepository _userRepository;
  final DiaryRepository _diaryRepository;

  DiaryCubit(this._userRepository, this._diaryRepository) : super(DiaryCubitState.initial(date: Date.today())) {
    _subscribeToRepository();
  }

  void switchDate(Date date) async {
    if (date != state.date) {
      final drinks = _diaryRepository.findDrinksOnDate(date);
      final diaryEntry = _diaryRepository.findEntryOnDate(date);

      emit(DiaryCubitState.initial(date: date, drinks: drinks, diaryEntry: diaryEntry));
    }
  }

  void markAsDrinkFreeDay() {
    _diaryRepository.markAsDrinkFree(state.date);
  }

  void deleteDrink(ConsumedDrink drink) {
    _diaryRepository.removeDrink(drink);
  }

  void _subscribeToRepository() {
    final dateChangedStream = stream.map((value) => value.date).distinct().startWith(state.date);

    addSubscription(dateChangedStream
        .flatMap((date) => _diaryRepository.observeEntryOnDate(date))
        .listen((item) => emit(state.updateDiaryEntry(item))));

    addSubscription(dateChangedStream
        .flatMap((date) => _diaryRepository.observeDrinksOnDate(date))
        .listen((drinks) => emit(state.updateDrinks(drinks))));

    addSubscription(dateChangedStream
        .flatMap((date) => _diaryRepository.observeDrinksBetweenDays(
              date.subtract(days: 1),
              date.add(days: 1),
            ))
        .listen(_calculateBAC));
  }

  void _calculateBAC(List<ConsumedDrink> drinks) async {
    final user = await _userRepository.user;
    if (user == null) {
      return;
    }

    // TODO: Move stomach fullness to diary entry
    final calculator = BACCalculator(user, StomachFullness.normal);

    final results = await compute(calculator.calculate, drinks);

    emit(state.updateBAC(results));
  }
}

class DiaryCubitState {
  final Date date;
  final DiaryEntry? diaryEntry;
  final List<ConsumedDrink> drinks;
  final BACCalculationResults calculationResults;

  final double gramsOfAlcohol;
  final int calories;

  DiaryCubitState({
    required this.date,
    required this.diaryEntry,
    required this.drinks,
    required this.calculationResults,
  })  : gramsOfAlcohol = drinks.map((drink) => drink.gramsOfAlcohol).sum,
        calories = drinks.map((drink) => drink.calories).sum;

  DiaryCubitState.initial({
    required this.date,
    this.diaryEntry,
    this.drinks = const [],
  })  : calculationResults = BACCalculationResults.empty(
          startTime: date.toDateTime(),
          endTime: date.add(days: 1).toDateTime(),
          timestep: const Duration(minutes: 10),
        ),
        gramsOfAlcohol = 0,
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
