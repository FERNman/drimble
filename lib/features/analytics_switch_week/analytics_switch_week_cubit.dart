import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/diary_repository.dart';
import '../../domain/date.dart';
import '../../domain/diary/diary_entry.dart';
import '../../infra/disposable.dart';

class AnalyticsSwitchWeekCubit extends Cubit<AnalyticsSwitchWeekBaseState> with Disposable {
  final DiaryRepository _diaryRepository;

  AnalyticsSwitchWeekCubit(this._diaryRepository, {required Date initialDate})
      : super(AnalyticsSwitchWeekLoadingState(
          visibleMonth: initialDate.floorToMonth(),
          selectedDate: initialDate,
        )) {
    _initState();
  }

  void _initState() {
    final visibleMonth$ = stream.map((state) => state.visibleMonth).distinct().startWith(state.visibleMonth);

    final diaryEntries$ = visibleMonth$.flatMap((month) {
      final firstDayOfFirstWeek = month.floorToWeek();
      final lastDayOfLastWeek = month.add(months: 1).floorToWeek().add(days: 6);

      return _diaryRepository.observeEntriesBetween(firstDayOfFirstWeek, lastDayOfLastWeek);
    });

    addSubscription(
      diaryEntries$
          .map(
            (entries) => AnalyticsSwitchWeekState(
              visibleMonth: state.visibleMonth,
              selectedDate: state.selectedDate,
              diaryEntries: entries.groupFoldBy((el) => el.date, (_, el) => el),
            ),
          )
          .listen(emit),
    );
  }

  void changeVisibleMonth(Date month) {
    emit(AnalyticsSwitchWeekLoadingState(
      visibleMonth: month.floorToMonth(),
      selectedDate: state.selectedDate,
    ));
  }

  void changeSelectedDate(Date date) {
    emit(state.copyWith(selectedDate: date));
  }
}

abstract class AnalyticsSwitchWeekBaseState {
  final Date visibleMonth;
  final Date selectedDate;

  const AnalyticsSwitchWeekBaseState({
    required this.visibleMonth,
    required this.selectedDate,
  });

  AnalyticsSwitchWeekBaseState copyWith({Date? visibleMonth, Date? selectedDate});
}

class AnalyticsSwitchWeekLoadingState extends AnalyticsSwitchWeekBaseState {
  const AnalyticsSwitchWeekLoadingState({
    required super.visibleMonth,
    required super.selectedDate,
  });

  @override
  AnalyticsSwitchWeekBaseState copyWith({Date? visibleMonth, Date? selectedDate}) => AnalyticsSwitchWeekLoadingState(
        visibleMonth: visibleMonth ?? this.visibleMonth,
        selectedDate: selectedDate ?? this.selectedDate,
      );
}

class AnalyticsSwitchWeekState extends AnalyticsSwitchWeekBaseState {
  final Map<Date, DiaryEntry> diaryEntries;

  const AnalyticsSwitchWeekState({
    required super.visibleMonth,
    required super.selectedDate,
    this.diaryEntries = const {},
  });

  @override
  AnalyticsSwitchWeekBaseState copyWith({Date? visibleMonth, Date? selectedDate}) => AnalyticsSwitchWeekState(
        visibleMonth: visibleMonth ?? this.visibleMonth,
        selectedDate: selectedDate ?? this.selectedDate,
        diaryEntries: diaryEntries,
      );
}
