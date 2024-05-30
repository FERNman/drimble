import 'package:drimble/domain/bac/bac_calculation_results.dart';
import 'package:drimble/infra/extensions/copy_date_time.dart';
import 'package:flutter_test/flutter_test.dart';

import '../generate_entities.dart';

void main() {
  group(BACCalculationResults, () {
    group('getEntryAt', () {
      test('should return the exact value if a entry exists at the given time', () {
        final when = DateTime(2022);
        const value = 1.2;

        final entries = [BACEntry(when, value)];
        final results = BACCalculationResults(entries);

        final entry = results.getEntryAt(when);
        expect(entry.time, when);
        expect(entry.value, value);
      });

      test('should correctly handle asking for a timestamp that is before the earliest entry', () {
        final timestamp = DateTime(2022, 1, 1, 10);
        final firstEntry = BACEntry(timestamp.copyWith(hour: 11), 1.0);
        final lastEntry = BACEntry(timestamp.copyWith(hour: 12), 2.0);

        final results = BACCalculationResults([firstEntry, lastEntry]);

        final entry = results.getEntryAt(timestamp);

        expect(entry.time, timestamp);
        expect(entry.value, firstEntry.value);
      });

      test('should correctly handle asking for a timestamp that is after the last entry', () {
        final timestamp = DateTime(2022, 1, 1, 13);
        final firstEntry = BACEntry(timestamp.copyWith(hour: 11), 1.0);
        final lastEntry = BACEntry(timestamp.copyWith(hour: 12), 2.0);

        final results = BACCalculationResults([firstEntry, lastEntry]);

        final entry = results.getEntryAt(timestamp);

        expect(entry.time, timestamp);
        expect(entry.value, lastEntry.value);
      });

      test('should linearly interpolate between two values if no entry exists at the given time', () {
        final timestamp = DateTime(2022, 1, 1, 10, 30);
        final firstEntry = BACEntry(timestamp.copyWith(hour: 10, minute: 0), 1.0);
        final secondEntry = BACEntry(timestamp.copyWith(hour: 11, minute: 0), 2.0);

        final results = BACCalculationResults([firstEntry, secondEntry]);

        final entry = results.getEntryAt(timestamp);

        final interpolatedValue = (secondEntry.value + firstEntry.value) / 2.0;

        expect(entry.time, timestamp);
        expect(entry.value, interpolatedValue);
      });
    });

    group('equality', () {
      test('should be equal if empty and same time', () {
        final start = faker.date.dateTime();

        final results1 = BACCalculationResults.empty(start);
        final results2 = BACCalculationResults.empty(start);

        expect(results1, results2);
      });

      test('should not be equal if empty and different time', () {
        final time1 = faker.date.dateTime();
        final time2 = faker.date.dateTime();

        final results1 = BACCalculationResults.empty(time1);
        final results2 = BACCalculationResults.empty(time2);

        expect(results1, isNot(results2));
      });
    });
  });
}
