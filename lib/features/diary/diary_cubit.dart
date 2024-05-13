import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/diary_repository.dart';
import '../../data/user_repository.dart';
import '../../domain/bac/bac_calculation_results.dart';
import '../../domain/bac/bac_calculator.dart';
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

  Future<void> switchDate(Date date) async {
    if (date != state.date) {
      final diaryEntry = await _diaryRepository.findEntryOnDate(date);

      emit(DiaryCubitState.initial(date: date, diaryEntry: diaryEntry));
    }
  }

  Future<void> markAsDrinkFreeDay() async {
    assert(state.diaryEntry == null);
    
    final diaryEntry = DiaryEntry(date: state.date);
    await _diaryRepository.saveDiaryEntry(diaryEntry);
  }

  Future<void> deleteDrink(ConsumedDrink drink) async {
    assert(state.diaryEntry != null);
    await _diaryRepository.removeDrinkFromDiaryEntry(state.diaryEntry!, drink);
  }

  Future<void> setGlassesOfWater(int glassesOfWater) async {
    final diaryEntry = state.diaryEntry?.copyWith(glassesOfWater: glassesOfWater) ??
        DiaryEntry(date: state.date, glassesOfWater: glassesOfWater);
    await _diaryRepository.saveDiaryEntry(diaryEntry);
  }

  void _subscribeToRepository() {
    final dateChangedStream = stream.map((value) => value.date).distinct().startWith(state.date);

    addSubscription(dateChangedStream
        .flatMap((date) => _diaryRepository.observeEntryOnDate(date))
        .listen((item) => emit(state.copyWith(diaryEntry: item))));

    addSubscription(stream.map((event) => event.diaryEntry).distinct().listen((diaryEntry) async {
      if (diaryEntry == null || diaryEntry.isDrinkFreeDay == true) {
        emit(state.copyWith(
          calculationResults: BACCalculationResults.empty(
            startTime: state.date.toDateTime(),
            endTime: state.date.add(days: 1).toDateTime(),
            timestep: const Duration(minutes: 10),
          ),
        ));
      } else {
        final results = await _calculateBAC(state.diaryEntry!);
        emit(state.copyWith(calculationResults: results));
      }
    }));
  }

  Future<BACCalculationResults> _calculateBAC(DiaryEntry diaryEntry) async {
    final user = await _userRepository.loadUser();

    // TODO: Integrate stomach fullness in diary entry
    final calculator = BACCalculator(user!, StomachFullness.normal);
    return compute(calculator.calculate, diaryEntry.drinks);
  }
}

class DiaryCubitState {
  final Date date;
  final DiaryEntry? diaryEntry;
  final List<ConsumedDrink> drinks;
  final BACCalculationResults calculationResults;

  final double gramsOfAlcohol;
  final int calories;
  final int glassesOfWater;

  DiaryCubitState({
    required this.date,
    required this.diaryEntry,
    required this.calculationResults,
  })  : gramsOfAlcohol = diaryEntry?.gramsOfAlcohol ?? 0,
        calories = diaryEntry?.calories ?? 0,
        glassesOfWater = diaryEntry?.glassesOfWater ?? 0,
        drinks = diaryEntry?.drinks ?? [];

  factory DiaryCubitState.initial({required Date date, DiaryEntry? diaryEntry}) => DiaryCubitState(
        date: date,
        diaryEntry: diaryEntry,
        calculationResults: BACCalculationResults.empty(
          startTime: date.toDateTime(),
          endTime: date.add(days: 1).toDateTime(),
          timestep: const Duration(minutes: 10),
        ),
      );

  DiaryCubitState copyWith({DiaryEntry? diaryEntry, BACCalculationResults? calculationResults}) => DiaryCubitState(
        date: date,
        diaryEntry: diaryEntry ?? this.diaryEntry,
        calculationResults: calculationResults ?? this.calculationResults,
      );

  DiaryEntry getOrCreateDiaryEntry() => diaryEntry ?? DiaryEntry(date: date);
}
