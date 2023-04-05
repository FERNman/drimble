import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/diary_repository.dart';
import '../../data/drinks_repository.dart';
import '../../data/user_repository.dart';
import '../../domain/bac_calculator.dart';
import '../../domain/bac_calulation_results.dart';
import '../../domain/date.dart';
import '../../domain/diary/diary_entry.dart';
import '../../domain/diary/drink.dart';
import '../../infra/disposable.dart';

class DiaryCubit extends Cubit<DiaryCubitState> with Disposable {
  final UserRepository _userRepository;
  final DrinksRepository _consumedDrinksRepository;
  final DiaryRepository _diaryRepository;

  DiaryCubit(this._userRepository, this._diaryRepository, this._consumedDrinksRepository)
      : super(DiaryCubitState.initial(date: Date.today())) {
    _subscribeToRepository();
  }

  void switchDate(Date date) async {
    if (date != state.date) {
      final drinks = _consumedDrinksRepository.findDrinksOnDate(date);
      final diaryEntry = _diaryRepository.findEntryOnDate(date);

      emit(DiaryCubitState.initial(date: date, drinks: drinks, diaryEntry: diaryEntry));
    }
  }

  void markAsDrinkFreeDay() {
    _diaryRepository.markAsDrinkFree(state.date);
  }

  void deleteDrink(Drink drink) {
    _consumedDrinksRepository.removeDrink(drink);
  }

  void _subscribeToRepository() {
    final dateChangedStream = stream.distinct((previous, next) => previous.date == next.date).startWith(state);

    addSubscription(dateChangedStream
        .flatMap((value) => _diaryRepository.observeEntryOnDate(value.date))
        .listen((item) => emit(state.updateDiaryEntry(item))));

    addSubscription(dateChangedStream
        .flatMap((value) => _consumedDrinksRepository.observeDrinksOnDate(value.date))
        .listen((drinks) => emit(state.updateDrinks(drinks))));

    addSubscription(dateChangedStream
        .flatMap((value) => _consumedDrinksRepository.observeDrinksBetweenDays(
              value.date.subtract(days: 1),
              value.date.add(days: 1),
            ))
        .listen(_calculateBAC));
  }

  void _calculateBAC(List<Drink> drinks) async {
    final user = await _userRepository.user;
    if (user == null) {
      return;
    }

    final calculator = BACCalculator(user);

    final startTime = state.date.toShiftedDateTime();
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
  final Date date;
  final DiaryEntry? diaryEntry;
  final List<Drink> drinks;
  final BACCalculationResults calculationResults;

  final double gramsOfAlcohol;
  final int calories;

  DiaryCubitState({
    required this.date,
    required this.diaryEntry,
    required this.drinks,
    required this.calculationResults,
  })  : gramsOfAlcohol = drinks.fold(0.0, (total, it) => total + it.gramsOfAlcohol),
        calories = drinks.fold(0, (calories, it) => calories + it.calories);

  DiaryCubitState.initial({
    required this.date,
    this.diaryEntry,
    this.drinks = const [],
  })  : calculationResults = BACCalculationResults.empty(
          startTime: date.toShiftedDateTime(),
          endTime: date.add(days: 1).toShiftedDateTime(),
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

  DiaryCubitState updateDrinks(List<Drink> drinks) => DiaryCubitState(
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
