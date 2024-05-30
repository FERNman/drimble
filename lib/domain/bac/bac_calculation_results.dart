import 'package:collection/collection.dart';

import '../../features/common/bac_format/bac_format.dart';
import '../alcohol/alcohol.dart';

class BACEntry {
  final DateTime time;

  /// In g/100mL
  final double value;

  BACEntry(this.time, this.value)
      : assert(!value.isNaN),
        assert(value >= 0.0);

  const BACEntry.sober(this.time) : value = 0.0;

  bool get isSober {
    return value < Alcohol.soberLimit;
  }

  BACEntry copyWith({DateTime? time, double? value}) => BACEntry(time ?? this.time, value ?? this.value);

  @override
  String toString() => BacFormat().format(value);

  @override
  operator ==(Object other) =>
      identical(this, other) || other is BACEntry && time == other.time && value == other.value;

  @override
  int get hashCode => time.hashCode ^ value.hashCode;
}

class BACCalculationResults {
  final List<BACEntry> _results;

  final DateTime startTime;
  final DateTime endTime;
  final BACEntry maxBAC;

  BACCalculationResults(List<BACEntry> results)
      : assert(results.isNotEmpty),
        _results = results.sortedBy((element) => element.time),
        startTime = results.first.time,
        endTime = results.last.time,
        maxBAC = results.reduce((max, el) => max.value > el.value ? max : el);

  BACCalculationResults.empty(final DateTime time)
      : _results = const [],
        maxBAC = BACEntry.sober(time),
        startTime = time,
        endTime = time;

  /// Returns a `BACEntry` with the given `time` as time. The `value` is either the exact value on this time,
  /// or, if no entry exists at the given time, interpolated between the two closests entries.
  /// If `time` is outside the range of the results, the value of the first or last entry is used.
  BACEntry getEntryAt(DateTime time) {
    if (_results.isEmpty) {
      return BACEntry.sober(time);
    }

    var start = 0;
    var end = _results.length;
    while (start < end) {
      final mid = start + ((end - start) >> 1);
      final midTime = _results[mid].time;
      if (midTime.isBefore(time)) {
        start = mid + 1;
      } else if (midTime.isAfter(time)) {
        end = mid;
      } else {
        return _results[mid];
      }
    }

    // At this point, `start` is the index of the first element that's not less than `time`,
    // or `_results.length` if all elements are less than `time`.

    if (start == 0) {
      // All elements are larger. Return the first one.
      return _results[0].copyWith(time: time);
    } else if (start >= _results.length) {
      // All elements are smaller. Return the last one.
      return _results.last.copyWith(time: time);
    } else {
      // Interpolate between the two closest elements.
      final prevEntry = _results[start - 1];
      final nextEntry = _results[start];
      return _interpolate(prevEntry, nextEntry, time);
    }
  }

  BACEntry _interpolate(BACEntry prevEntry, BACEntry nextEntry, DateTime time) {
    final prevTime = prevEntry.time.millisecondsSinceEpoch;
    final nextTime = nextEntry.time.millisecondsSinceEpoch;
    final targetTime = time.millisecondsSinceEpoch;

    final fraction = (targetTime - prevTime) / (nextTime - prevTime);
    final interpolatedValue = prevEntry.value + fraction * (nextEntry.value - prevEntry.value);

    return BACEntry(time, interpolatedValue);
  }

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is BACCalculationResults &&
          startTime.isAtSameMomentAs(other.startTime) &&
          endTime.isAtSameMomentAs(other.endTime) &&
          const ListEquality().equals(_results, other._results);

  @override
  int get hashCode => _results.hashCode;
}
