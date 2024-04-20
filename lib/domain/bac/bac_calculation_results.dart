import 'package:collection/collection.dart';

import '../../features/common/bac_format/bac_format.dart';
import '../alcohol/alcohol.dart';

class BACEntry {
  final DateTime time;

  /// In g/100mL
  final double value;

  BACEntry(this.time, this.value) {
    assert(!value.isNaN);
    assert(value >= 0.0);
  }

  BACEntry.sober(this.time) : value = 0.0;

  bool get isSober {
    return value < Alcohol.soberLimit;
  }

  BACEntry copyWith({DateTime? time, double? value}) => BACEntry(time ?? this.time, value ?? this.value);

  @override
  String toString() => BacFormat().format(value);
}

class BACCalculationResults {
  static DateTime? _findFirstSoberEntry(List<BACEntry> results) {
    return results.reversed.takeWhile((entry) => entry.isSober).lastOrNull?.time;
  }

  static DateTime? _findTimeOfFirstDrink(List<BACEntry> results) {
    return results.firstWhereOrNull((element) => element.value > Alcohol.soberLimit)?.time;
  }

  static List<BACEntry> _generateEmptyResults(DateTime startTime, DateTime endTime, Duration timestep) {
    final itemCount = (endTime.difference(startTime).inMinutes / timestep.inMinutes).round();
    return List.generate(itemCount, (i) => BACEntry.sober(startTime.add(timestep * i)));
  }

  final List<BACEntry> _results;
  final DateTime? timeOfFirstDrink;
  final DateTime? soberAt;
  final BACEntry maxBAC;

  BACCalculationResults(this._results)
      : assert(_results.isNotEmpty),
        timeOfFirstDrink = _findTimeOfFirstDrink(_results),
        soberAt = _findFirstSoberEntry(_results),
        maxBAC = _results.reduce((max, el) => max.value > el.value ? max : el);

  BACCalculationResults.empty({
    required DateTime startTime,
    required DateTime endTime,
    required Duration timestep,
  })  : _results = _generateEmptyResults(startTime, endTime, timestep),
        timeOfFirstDrink = null,
        soberAt = startTime,
        maxBAC = BACEntry.sober(startTime);

  BACEntry getEntryAt(DateTime time) {
    if (time.isBefore(_results.first.time)) {
      return _results.first.copyWith(time: time);
    }

    if (time.isAfter(_results.last.time)) {
      return _results.last.copyWith(time: time);
    }

    return _results
        .reduce((lhs, rhs) => lhs.time.difference(time).abs() < rhs.time.difference(time).abs() ? lhs : rhs)
        .copyWith(time: time);
  }

  BACEntry findMaxEntryAfter(DateTime time) {
    return _results.fold(BACEntry.sober(time), (max, el) {
      if (el.time.isBefore(time)) {
        return max;
      }

      return max.value > el.value ? max : el;
    });
  }
}
