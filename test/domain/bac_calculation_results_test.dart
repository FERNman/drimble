import 'package:drimble/domain/bac_calulation_results.dart';
import 'package:drimble/infra/extensions/copy_date_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BAC calculation results', () {
    group('getEntryAt', () {
      test('should return a sober entry if the entries are empty ', () {
        final when = DateTime(2022);

        final results = BACCalculationResults([]);

        final entry = results.getEntryAt(when);
        expect(entry.time, when);
        expect(entry.value, 0.0);
      });

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

      test('should interpolate between two values if no entry exists at the given time', () {
        final timestamp = DateTime(2022, 1, 1, 10, 30);
        final firstEntry = BACEntry(timestamp.copyWith(hour: 10, minute: 0), 1.0);
        final secondEntry = BACEntry(timestamp.copyWith(hour: 11, minute: 0), 2.0);

        final results = BACCalculationResults([firstEntry, secondEntry]);

        final entry = results.getEntryAt(timestamp);

        final interpolatedValue = (secondEntry.value + firstEntry.value) / 2.0;

        expect(entry.time, timestamp);
        expect(entry.value, interpolatedValue);
      }, skip: 'TODO: Interpolate');
    });

    group('findMaxEntryAfter', () {
      test('should be a sober entry if the entries are empty', () {
        final results = BACCalculationResults([]);

        final maxBAC = results.findMaxEntryAfter(DateTime(2020));
        expect(maxBAC.value, 0.0);
      });

      test('should be the entry with the hightest BAC', () {
        final timestamp = DateTime(2022, 1, 1);
        final firstEntry = BACEntry(timestamp.copyWith(hour: 11), 1.0);
        final secondEntry = BACEntry(timestamp.copyWith(hour: 12), 2.0);
        final thirdEntry = BACEntry(timestamp.copyWith(hour: 13), 1.5);

        final results = BACCalculationResults([firstEntry, secondEntry, thirdEntry]);

        final maxBAC = results.findMaxEntryAfter(timestamp);
        expect(maxBAC.value, secondEntry.value);
      });

      test('should ignore entries that are earlier than the given timestamp', () {
        final timestamp = DateTime(2022, 1, 1);
        final highestEntry = BACEntry(timestamp.copyWith(hour: 9), 5.0);
        final lowEntry = BACEntry(timestamp.copyWith(hour: 11), 1.0);
        final desiredEntry = BACEntry(timestamp.copyWith(hour: 12), 2.0);

        final results = BACCalculationResults([highestEntry, lowEntry, desiredEntry]);

        final maxBAC = results.findMaxEntryAfter(timestamp.copyWith(hour: 10));
        expect(maxBAC.value, desiredEntry.value);
      });
    });

    group('soberAt', () {
      test('should simply return the last entry if there is no sober entry', () {
        final timestamp = DateTime(2022, 1, 1);
        final firstEntry = BACEntry(timestamp.copyWith(hour: 11), 1.0);
        final secondEntry = BACEntry(timestamp.copyWith(hour: 12), 0.5);

        final results = BACCalculationResults([firstEntry, secondEntry]);

        final soberAt = results.soberAt;
        expect(soberAt, secondEntry.time);
      });

      test('should return the first sober result', () {
        final timestamp = DateTime(2022, 1, 1);
        final firstTimeSober = timestamp.copyWith(hour: 13);

        final results = BACCalculationResults([
          BACEntry(timestamp.copyWith(hour: 11), 1.0),
          BACEntry(timestamp.copyWith(hour: 12), 0.2),
          BACEntry(firstTimeSober, 0.0),
          BACEntry(timestamp.copyWith(hour: 14), 0.0),
        ]);

        final soberAt = results.soberAt;
        expect(soberAt, firstTimeSober);
      });

      test('should return the first time sober after all drinks even when sobering out in between', () {
        final timestamp = DateTime(2022, 1, 1);
        final firstTimeSober = timestamp.copyWith(hour: 13);

        final results = BACCalculationResults([
          BACEntry(timestamp.copyWith(hour: 10), 1.0),
          BACEntry(timestamp.copyWith(hour: 11), 0.0),
          BACEntry(timestamp.copyWith(hour: 12), 0.2),
          BACEntry(firstTimeSober, 0.0),
          BACEntry(timestamp.copyWith(hour: 14), 0.0),
        ]);

        final soberAt = results.soberAt;
        expect(soberAt, firstTimeSober);
      });
    });
  });
}
