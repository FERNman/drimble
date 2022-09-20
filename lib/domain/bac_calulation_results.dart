import 'drink/alcohol.dart';

class BACEntry {
  final DateTime time;
  final double value;

  BACEntry(this.time, this.value) {
    assert(!value.isNaN);
  }

  BACEntry.sober(this.time) : value = 0.0;

  BACEntry copyWith({DateTime? time, double? value}) => BACEntry(time ?? this.time, value ?? this.value);
}

class BACCalculationResults {
  final List<BACEntry> _results;

  late final BACEntry maxBAC;
  late final DateTime soberAt;

  BACCalculationResults(this._results) {
    maxBAC = _findMaxBAC();
    soberAt = _findFirstSoberEntry();
  }

  BACEntry getBACAt(DateTime time) {
    if (_results.isEmpty) {
      return BACEntry.sober(time);
    }

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

  BACEntry _findMaxBAC() {
    if (_results.isEmpty) {
      return BACEntry.sober(DateTime.now());
    }

    return _results.reduce((lhs, rhs) => lhs.value > rhs.value ? lhs : rhs);
  }

  DateTime _findFirstSoberEntry() {
    if (_results.isEmpty) {
      return DateTime.now();
    }

    // Go through results from last to first
    // Return first entry where the next entry is no longer sober
    for (var i = _results.length - 1; i > 0; i--) {
      final nextEntry = _results[i - 1];
      if (nextEntry.value >= Alcohol.soberLimit) {
        final currentEntry = _results[i];
        return currentEntry.time;
      }
    }

    return _results.last.time;
  }
}
