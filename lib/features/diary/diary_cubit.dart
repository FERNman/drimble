import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/diary_repository.dart';
import '../../domain/date.dart';
import '../../domain/diary/diary_entry.dart';
import '../../infra/disposable.dart';

class DiaryCubit extends Cubit<DiaryCubitState> with Disposable {
  final DiaryRepository _diaryRepository;

  DiaryCubit(this._diaryRepository, Date initialDate) : super(DiaryCubitState.initial(initialDate)) {
    _subscribeToRepository();
  }

  Future<void> switchDate(Date date) async {
    if (date != state.selectedDate) {
      emit(state.copyWith(selectedDate: date));
    }
  }

  Future<void> markAsDrinkFreeDay() async {
    assert(state.selectedDiaryEntry == null);

    final diaryEntry = DiaryEntry(date: state.selectedDate);
    await _diaryRepository.saveDiaryEntry(diaryEntry);
  }

  void _subscribeToRepository() {
    final weekChangedStream = stream
        .map((state) => (state.weekStartDate, state.weekEndDate))
        .startWith((state.weekStartDate, state.weekEndDate)).distinct();

    addSubscription(weekChangedStream
        .switchMap((val) => _diaryRepository
            .observeEntriesBetween(val.$1, val.$2)
            .map((items) => Map.fromEntries(items.map((entry) => MapEntry(entry.date, entry)))))
        .listen((items) => emit(state.copyWith(diaryEntries: items))));
  }
}

class DiaryCubitState {
  final Date selectedDate;
  final Date weekStartDate;
  final Date weekEndDate;

  final Map<Date, DiaryEntry> diaryEntries;
  final DiaryEntry? selectedDiaryEntry;

  final double gramsOfAlcohol;

  DiaryCubitState._({
    required this.selectedDate,
    required this.diaryEntries,
  })  : weekStartDate = selectedDate.floorToWeek(),
        weekEndDate = selectedDate.floorToWeek().add(days: 6),
        selectedDiaryEntry = diaryEntries[selectedDate],
        gramsOfAlcohol = diaryEntries.values.map((e) => e.gramsOfAlcohol).sum;

  factory DiaryCubitState.initial(Date date) => DiaryCubitState._(selectedDate: date, diaryEntries: {});

  DiaryCubitState copyWith({Date? selectedDate, Map<Date, DiaryEntry>? diaryEntries}) => DiaryCubitState._(
        selectedDate: selectedDate ?? this.selectedDate,
        diaryEntries: diaryEntries ?? this.diaryEntries,
      );

  DiaryEntry getOrCreateDiaryEntry() => selectedDiaryEntry ?? DiaryEntry(date: selectedDate);
}
