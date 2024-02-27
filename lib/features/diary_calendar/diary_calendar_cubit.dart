import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/diary_repository.dart';
import '../../domain/date.dart';
import '../../domain/diary/diary_entry.dart';
import '../../infra/disposable.dart';

class DiaryCalendarCubit extends Cubit<DiaryCalendarCubitState> with Disposable {
  final DiaryRepository _diaryRepository;
  static const bufferMax = 20;
  static const bufferMin = 5;

  DiaryCalendarCubit(this._diaryRepository) : super(DiaryCalendarCubitState.initial(bufferMax)) {
    _subscribeToRepository();
  }

  void updateRange(Date start, Date end) {
    if (_shouldUpdateRange(start, end)) {
      emit(state.withDates(start.subtract(days: bufferMax), end.add(days: bufferMax)));
    }
  }

  bool _shouldUpdateRange(Date start, Date end) {
    return start.difference(state.startDate).inDays < bufferMin || state.endDate.difference(end).inDays < bufferMin;
  }

  void _subscribeToRepository() async {
    final dateChangeStream =
        stream.map((state) => (state.startDate, state.endDate)).distinct().startWith((state.startDate, state.endDate));

    addSubscription(dateChangeStream
        .switchMap((val) => _diaryRepository
            .observeEntriesBetween(val.$1, val.$2)
            .map((items) => items.groupFoldBy((el) => el.date, (_, el) => el)))
        .listen((items) => emit(state.withEntries(items))));
  }
}

class DiaryCalendarCubitState {
  final Date startDate;
  final Date endDate;

  final Map<Date, DiaryEntry> _diaryEntries;

  DiaryCalendarCubitState({required this.startDate, required this.endDate, required Map<Date, DiaryEntry> diaryEntries})
      : _diaryEntries = diaryEntries;
  DiaryCalendarCubitState.initial(int bufferSize)
      : startDate = Date.today().subtract(days: bufferSize),
        endDate = Date.today().add(days: bufferSize),
        _diaryEntries = const {};

  DiaryCalendarCubitState withDates(Date start, Date end) =>
      DiaryCalendarCubitState(startDate: start, endDate: end, diaryEntries: _diaryEntries);

  DiaryCalendarCubitState withEntries(Map<Date, DiaryEntry> diaryEntries) =>
      DiaryCalendarCubitState(startDate: startDate, endDate: endDate, diaryEntries: diaryEntries);

  bool? isDrinkFreeDay(Date date) {
    return _diaryEntries[date]?.isDrinkFreeDay;
  }
}
