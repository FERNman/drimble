import '../../features/common/bac_format/bac_format.dart';
import '../alcohol/alcohol.dart';

class BACEntry {
  final DateTime time;

  /// In g/L
  final double value;

  BACEntry(this.time, this.value)
      : assert(!value.isNaN);

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
