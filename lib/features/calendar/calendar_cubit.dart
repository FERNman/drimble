import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/diary_repository.dart';
import '../../domain/date.dart';
import '../../domain/diary/diary_entry.dart';
import '../../infra/disposable.dart';

class CalendarCubit extends Cubit<CalendarCubitBaseState> with Disposable {
  final DiaryRepository _diaryRepository;

  CalendarCubit(this._diaryRepository, {required Date initiallyVisibleDate})
      : super(const CalendarCubitLoadingState()) {
    loadEntriesForMonth(initiallyVisibleDate.floorToMonth());
  }

  Future<void> loadEntriesForMonth(Date month) async {
    if (state is CalendarCubitState) {
      final earliestLoadedDate = (state as CalendarCubitState).earliestLoadedDate;
      final latestLoadedDate = (state as CalendarCubitState).latestLoadedDate;
      if (earliestLoadedDate.isBefore(month) && latestLoadedDate.isAfter(month)) {
        return;
      }
    }

    final loadingStart = month.subtract(months: 3);
    final loadingEnd = month.add(months: 2);

    final entries = await _diaryRepository.loadEntriesBetween(loadingStart, loadingEnd);
    emit(state.addEntries(
      diaryEntries: Map.fromEntries(entries.map((entry) => MapEntry(entry.date, entry))),
      earliestLoadedDate: loadingStart,
      latestLoadedDate: loadingEnd,
    ));
  }
}

abstract class CalendarCubitBaseState {
  const CalendarCubitBaseState();

  CalendarCubitBaseState addEntries({
    required Map<Date, DiaryEntry> diaryEntries,
    required Date earliestLoadedDate,
    required Date latestLoadedDate,
  }) =>
      CalendarCubitState(
        diaryEntries: diaryEntries,
        earliestLoadedDate: earliestLoadedDate,
        latestLoadedDate: latestLoadedDate,
      );
}

class CalendarCubitLoadingState extends CalendarCubitBaseState {
  const CalendarCubitLoadingState();
}

class CalendarCubitState extends CalendarCubitBaseState {
  final Date earliestLoadedDate;
  final Date latestLoadedDate;
  final Map<Date, DiaryEntry> diaryEntries;

  CalendarCubitState({required this.diaryEntries, required this.earliestLoadedDate, required this.latestLoadedDate});

  @override
  CalendarCubitBaseState addEntries({
    required Map<Date, DiaryEntry> diaryEntries,
    required Date earliestLoadedDate,
    required Date latestLoadedDate,
  }) =>
      CalendarCubitState(
        diaryEntries: {...this.diaryEntries, ...diaryEntries},
        earliestLoadedDate:
            earliestLoadedDate.isBefore(this.earliestLoadedDate) ? earliestLoadedDate : this.earliestLoadedDate,
        latestLoadedDate: latestLoadedDate.isAfter(this.latestLoadedDate) ? latestLoadedDate : this.latestLoadedDate,
      );
}
