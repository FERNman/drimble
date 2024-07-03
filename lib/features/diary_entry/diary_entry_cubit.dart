import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/diary_repository.dart';
import '../../data/user_repository.dart';
import '../../domain/bac/bac_calculator.dart';
import '../../domain/bac/bac_time_series.dart';
import '../../domain/diary/consumed_drink.dart';
import '../../domain/diary/diary_entry.dart';
import '../../domain/diary/hangover_severity.dart';
import '../../domain/hangover_predictor.dart';
import '../../domain/user/user.dart';
import '../../infra/disposable.dart';
import '../../infra/extensions/set_date.dart';

class DiaryEntryCubit extends Cubit<DiaryEntryCubitState> with Disposable {
  final UserRepository _userRepository;
  final DiaryRepository _diaryRepository;
  final HangoverSeverityPredictor _hangoverSeverityPredictor;

  DiaryEntryCubit(this._userRepository, this._diaryRepository, this._hangoverSeverityPredictor, DiaryEntry diaryEntry)
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
    final copiedDrink = ConsumedDrink.deepCopy(drink, startTime: DateTime.now().setDate(state.diaryEntry.date));
    await _diaryRepository.saveDiaryEntry(state.diaryEntry.addDrink(copiedDrink));
  }

  Future<void> removeDrink(ConsumedDrink drink) async {
    await _diaryRepository.saveDiaryEntry(state.diaryEntry.removeDrink(drink.id));
  }

  Future<void> setHangoverSeverity(HangoverSeverity severity) async {
    await _diaryRepository.saveDiaryEntry(state.diaryEntry.setHangoverSeverity(severity));

    await _hangoverSeverityPredictor.updatePrediction(state.diaryEntry, state.bacEntries.maxBAC, severity);
  }

  void _subscribeToDiaryEntryChanges(DiaryEntry diaryEntry) async {
    final user = await _userRepository.loadUser();

    addSubscription(_diaryRepository
        .observeEntryById(state.diaryEntry.id!)
        .doOnData((data) => emit(state.copyWith(diaryEntry: data)))
        .startWith(diaryEntry)
        .distinct()
        .asyncMap((diaryEntry) => _calculateBAC(user, diaryEntry))
        .listen((bac) => emit(state.copyWith(bacEntries: bac))));

    addSubscription(stream
        .distinctUnique(equals: (e1, e2) => e1.bacEntries == e2.bacEntries)
        .where((e) => e.diaryEntry.hangoverSeverity == null && !e.diaryEntry.isDrinkFreeDay)
        .map((e) => _hangoverSeverityPredictor.predict(e.diaryEntry, e.bacEntries.maxBAC))
        .listen((prediction) => emit(state.copyWith(predictedHangoverSeverity: prediction))));
  }

  Future<BACTimeSeries> _calculateBAC(User? user, DiaryEntry diaryEntry) async {
    return Isolate.run(() => BACCalculator.calculate(user!, diaryEntry));
  }
}

class DiaryEntryCubitState {
  final DiaryEntry diaryEntry;

  final BACTimeSeries bacEntries;
  final HangoverSeverity? predictedHangoverSeverity;

  final List<ConsumedDrink> drinks;
  final List<ConsumedDrink> recentDrinks;

  final double gramsOfAlcohol;
  final int calories;
  final int glassesOfWater;

  DiaryEntryCubitState._({
    required this.diaryEntry,
    required this.bacEntries,
    this.predictedHangoverSeverity,
  })  : drinks = diaryEntry.drinks.sortedByCompare((el) => el.startTime, (lhs, rhs) => rhs.compareTo(lhs)),
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
        bacEntries: BACTimeSeries.empty(diaryEntry.date.toDateTime()),
      );

  DiaryEntryCubitState copyWith({
    DiaryEntry? diaryEntry,
    BACTimeSeries? bacEntries,
    HangoverSeverity? predictedHangoverSeverity,
  }) =>
      DiaryEntryCubitState._(
        diaryEntry: diaryEntry ?? this.diaryEntry,
        bacEntries: bacEntries ?? this.bacEntries,
        predictedHangoverSeverity: predictedHangoverSeverity ?? this.predictedHangoverSeverity,
      );
}
