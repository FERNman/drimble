import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/diary_repository.dart';
import '../../data/user_repository.dart';
import '../../domain/bac/bac_calculation_results.dart';
import '../../domain/bac/bac_calculator.dart';
import '../../domain/diary/consumed_drink.dart';
import '../../domain/diary/diary_entry.dart';
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

  Future<void> removeDrink(ConsumedDrink drink) async {
    await _diaryRepository.saveDiaryEntry(state.diaryEntry.removeDrink(drink.id));
  }

  void _subscribeToDiaryEntryChanges(DiaryEntry diaryEntry) {
    addSubscription(_diaryRepository
        .observeEntryById(state.diaryEntry.id!)
        .doOnData((data) => emit(state.copyWith(diaryEntry: data)))
        .startWith(diaryEntry)
        .distinct() // TODO: Only recalculate if the drinks have changed
        .where((el) => el.drinks.isNotEmpty)
        .listen((diaryEntry) async {
      final results = await _calculateBAC(diaryEntry);
      emit(state.copyWith(diaryEntry: diaryEntry, calculationResults: results));
    }));
  }

  Future<BACCalculationResults> _calculateBAC(DiaryEntry diaryEntry) async {
    final user = await _userRepository.loadUser();

    final calculator = BACCalculator(user!, diaryEntry.stomachFullness!);
    return compute(calculator.calculate, diaryEntry.drinks);
  }
}

class DiaryEntryCubitState {
  final DiaryEntry diaryEntry;
  final BACCalculationResults calculationResults;

  final List<ConsumedDrink> drinks;
  final double gramsOfAlcohol;
  final int calories;
  final int glassesOfWater;

  DiaryEntryCubitState._({required this.diaryEntry, required this.calculationResults})
      : drinks = diaryEntry.drinks,
        gramsOfAlcohol = diaryEntry.gramsOfAlcohol,
        calories = diaryEntry.calories,
        glassesOfWater = diaryEntry.glassesOfWater;

  factory DiaryEntryCubitState.initial(DiaryEntry diaryEntry) => DiaryEntryCubitState._(
        diaryEntry: diaryEntry,
        calculationResults: BACCalculationResults.empty(
          startTime: diaryEntry.date.toDateTime(),
          endTime: diaryEntry.date.toDateTime().add(const Duration(hours: 24)),
        ),
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
