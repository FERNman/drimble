import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/diary_repository.dart';
import '../../data/user_repository.dart';
import '../../domain/bac/bac_calculation_results.dart';
import '../../domain/bac/bac_calculator.dart';
import '../../domain/diary/consumed_drink.dart';
import '../../domain/diary/diary_entry.dart';
import '../../domain/diary/hangover_severity.dart';
import '../../infra/disposable.dart';

class DiaryEntryCubit extends Cubit<DiaryEntryCubitState> with Disposable {
  final UserRepository _userRepository;
  final DiaryRepository _diaryRepository;

  DiaryEntryCubit(this._userRepository, this._diaryRepository, DiaryEntry diaryEntry)
      : super(DiaryEntryCubitState.initial(diaryEntry)) {
    _subscribeToDiaryEntryChanges(diaryEntry);
  }

  Future<void> addGlassOfWater() async {
    await _diaryRepository.saveDiaryEntry(state.diaryEntry.addGlassOfWater());
  }

  Future<void> removeGlassOfWater() async {
    await _diaryRepository.saveDiaryEntry(state.diaryEntry.removeGlassOfWater());
  }

  Future<void> addDrinkFromRecent(ConsumedDrink drink) async {
    final copiedDrink = ConsumedDrink.deepCopy(drink, startTime: DateTime.now());
    await _diaryRepository.saveDiaryEntry(state.diaryEntry.addDrink(copiedDrink));
  }

  Future<void> removeDrink(ConsumedDrink drink) async {
    await _diaryRepository.saveDiaryEntry(state.diaryEntry.removeDrink(drink.id));
  }

  Future<void> setHangoverSeverity(HangoverSeverity severity) async {
    await _diaryRepository.saveDiaryEntry(state.diaryEntry.setHangoverSeverity(severity));
  }

  void _subscribeToDiaryEntryChanges(DiaryEntry diaryEntry) {
    addSubscription(_diaryRepository
        .observeEntryById(state.diaryEntry.id!)
        .doOnData((data) => emit(state.copyWith(diaryEntry: data)))
        .startWith(diaryEntry)
        .distinct()
        .listen((diaryEntry) async {
      final results = await _calculateBAC(diaryEntry);
      emit(state.copyWith(diaryEntry: diaryEntry, calculationResults: results));
    }));
  }

  Future<BACCalculationResults> _calculateBAC(DiaryEntry diaryEntry) async {
    final user = await _userRepository.loadUser();

    final calculator = BACCalculator(user!);
    return compute(calculator.calculate, diaryEntry);
  }
}

class DiaryEntryCubitState {
  final DiaryEntry diaryEntry;
  final BACCalculationResults calculationResults;

  final List<ConsumedDrink> drinks;
  final double gramsOfAlcohol;
  final int calories;
  final int glassesOfWater;

  final List<ConsumedDrink> recentDrinks;

  DiaryEntryCubitState._({required this.diaryEntry, required this.calculationResults})
      : drinks = diaryEntry.drinks.sortedByCompare((el) => el.startTime, (lhs, rhs) => rhs.compareTo(lhs)),
        recentDrinks = _distinctDrinksByName(diaryEntry),
        gramsOfAlcohol = diaryEntry.gramsOfAlcohol,
        calories = diaryEntry.calories,
        glassesOfWater = diaryEntry.glassesOfWater;

  static List<ConsumedDrink> _distinctDrinksByName(DiaryEntry diaryEntry) => diaryEntry.drinks
      .sortedByCompare((el) => el.startTime, (lhs, rhs) => rhs.compareTo(lhs))
      .groupFoldBy<String, ConsumedDrink>((el) => el.name, (p, el) => p ?? el) // Use p to retain order
      .values
      .toList();

  factory DiaryEntryCubitState.initial(DiaryEntry diaryEntry) => DiaryEntryCubitState._(
        diaryEntry: diaryEntry,
        calculationResults: BACCalculationResults.empty(diaryEntry.date.toDateTime()),
      );

  DiaryEntryCubitState copyWith({
    DiaryEntry? diaryEntry,
    BACCalculationResults? calculationResults,
  }) =>
      DiaryEntryCubitState._(
        diaryEntry: diaryEntry ?? this.diaryEntry,
        calculationResults: calculationResults ?? this.calculationResults,
      );
}
