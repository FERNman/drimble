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
    soberAt = _findFirstSoberEntry();
  }

  BACEntry getBACAt(DateTime time) {
    if (_results.isEmpty) {
      return BACEntry(time, 0.0);
    }

    return _results.reduce((lhs, rhs) => lhs.time.difference(time).abs() < rhs.time.difference(time).abs() ? lhs : rhs);
  }

  BACEntry _findMaxBAC() {
    if (_results.isEmpty) {
      return BACEntry(DateTime.now(), 0.0);
    }

    return _results.reduce((lhs, rhs) => lhs.value > rhs.value ? lhs : rhs);
  }

  DateTime _findFirstSoberEntry() {
    if (_results.isEmpty) {
      return DateTime.now();
    }

    return _results.firstWhere((element) => element.value <= 0.01).time;
  }
}
