import 'drink/alcohol.dart';

class BACEntry {
  final DateTime time;
  final double value;

  BACEntry(this.time, this.value) {
    assert(!value.isNaN);
  }
}

class BACCalculationResults {
  final List<BACEntry> _results;

  late final BACEntry maxBAC;
  late final DateTime soberAt;

  BACCalculationResults(this._results) {
    maxBAC = _findMaxBAC();
    soberAt = _findFirstSoberEntry(maxBAC.time);
  }

  BACEntry getBACAt(DateTime time) {
    if (_results.isEmpty) {
      return BACEntry(time, 0.0);
    }

    // TODO: Interpolate
    return _results.reduce((lhs, rhs) => lhs.time.difference(time).abs() < rhs.time.difference(time).abs() ? lhs : rhs);
  }

  BACEntry _findMaxBAC() {
    if (_results.isEmpty) {
      return BACEntry(DateTime.now(), 0.0);
    }

    return _results.reduce((lhs, rhs) => lhs.value > rhs.value ? lhs : rhs);
  }

  DateTime _findFirstSoberEntry(DateTime timeOfMaxBAC) {
    if (_results.isEmpty) {
      return DateTime.now();
    }

    final firstSoberEntry =
        _results.firstWhere((el) => el.time.isAfter(timeOfMaxBAC) && el.value <= Alcohol.soberLimit);
    return firstSoberEntry.time;
  }
}
