import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/diary_repository.dart';
import '../../domain/date.dart';
import '../../domain/diary/diary_entry.dart';
import '../../infra/disposable.dart';

class CalendarCubit extends Cubit<CalendarCubitBaseState> with Disposable {
  final DiaryRepository _diaryRepository;

  CalendarCubit(this._diaryRepository, {required Date initialDate})
      : super(CalendarCubitLoadingState(
          visibleMonth: initialDate.floorToMonth(),
          selectedDate: initialDate,
        )) {
    _initState();
  }

  void _initState() {
    final visibleMonth$ = stream.map((state) => state.visibleMonth).startWith(state.visibleMonth).distinct();

    final diaryEntries$ = visibleMonth$.flatMap((month) {
      final firstDayOfFirstWeek = month.floorToWeek();
      final lastDayOfLastWeek = month.add(months: 1).floorToWeek().add(days: 6);

      return _diaryRepository.observeEntriesBetween(firstDayOfFirstWeek, lastDayOfLastWeek);
    });

    addSubscription(
      diaryEntries$
          .map(
            (entries) => CalendarCubitState(
              visibleMonth: state.visibleMonth,
              selectedDate: state.selectedDate,
              diaryEntries: entries.groupFoldBy((el) => el.date, (_, el) => el),
            ),
          )
          .listen(emit),
    );
  }

  void changeVisibleMonth(Date month) {
    emit(CalendarCubitLoadingState(
      visibleMonth: month.floorToMonth(),
      selectedDate: state.selectedDate,
    ));
  }

  void changeSelectedDate(Date date) {
    emit(state.copyWith(selectedDate: date));
  }
}

abstract class CalendarCubitBaseState {
  final Date visibleMonth;
  final Date selectedDate;

  const CalendarCubitBaseState({
    required this.visibleMonth,
    required this.selectedDate,
  });

  CalendarCubitBaseState copyWith({Date? visibleMonth, Date? selectedDate});
}

class CalendarCubitLoadingState extends CalendarCubitBaseState {
  const CalendarCubitLoadingState({
    required super.visibleMonth,
    required super.selectedDate,
  });

  @override
  CalendarCubitBaseState copyWith({Date? visibleMonth, Date? selectedDate}) => CalendarCubitLoadingState(
        visibleMonth: visibleMonth ?? this.visibleMonth,
        selectedDate: selectedDate ?? this.selectedDate,
      );
}

class CalendarCubitState extends CalendarCubitBaseState {
  final Map<Date, DiaryEntry> diaryEntries;

  const CalendarCubitState({
    required super.visibleMonth,
    required super.selectedDate,
    this.diaryEntries = const {},
  });

  @override
  CalendarCubitBaseState copyWith({Date? visibleMonth, Date? selectedDate}) => CalendarCubitState(
        visibleMonth: visibleMonth ?? this.visibleMonth,
        selectedDate: selectedDate ?? this.selectedDate,
        diaryEntries: diaryEntries,
      );
}
