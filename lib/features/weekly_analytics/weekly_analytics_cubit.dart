import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WeeklyAnalyticsCubit extends Cubit<WeeklyAnalyticsCubitState> {
  WeeklyAnalyticsCubit()
      : super(WeeklyAnalyticsCubitState(
          weekStartDate: DateTime.now(),
          gramsOfAlcoholPerDay: [],
        ));
}

class WeeklyAnalyticsCubitState {
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final List<double?> gramsOfAlcoholPerDay;
  final double maxBAC = 0.0;

  bool get isCurrentWeek {
    final now = DateTime.now();

    return now.isAfter(weekStartDate) && now.isBefore(weekEndDate);
  }

  bool get didDrink => gramsOfAlcoholPerDay.whereNotNull().any((element) => element > 0.0);

  WeeklyAnalyticsCubitState({
    required this.weekStartDate,
    required this.gramsOfAlcoholPerDay,
  }) : weekEndDate = weekStartDate.add(const Duration(days: 7));
}
