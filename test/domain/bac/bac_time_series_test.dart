import 'package:drimble/domain/bac/bac_entry.dart';
import 'package:drimble/domain/bac/bac_time_series.dart';
import 'package:drimble/infra/extensions/copy_date_time.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../generate_entities.dart';

void main() {
  group(BACTimeSeries, () {
    test('should return the exact value if a entry exists at the given time', () {
      final when = DateTime(2022);
      const value = 1.2;

      final entries = [BACEntry(when, value)];
      final results = BACTimeSeries(entries);

      final entry = results.getEntryAt(when);
      expect(entry.time, when);
      expect(entry.value, value);
    });

    test('should correctly handle asking for a timestamp that is before the earliest entry', () {
      final timestamp = DateTime(2022, 1, 1, 10);
      final firstEntry = BACEntry(timestamp.copyWith(hour: 11), 1.0);
      final lastEntry = BACEntry(timestamp.copyWith(hour: 12), 2.0);

      final results = BACTimeSeries([firstEntry, lastEntry]);

      final entry = results.getEntryAt(timestamp);

      expect(entry.time, timestamp);
      expect(entry.value, firstEntry.value);
    });

    test('should correctly handle asking for a timestamp that is after the last entry', () {
      final timestamp = DateTime(2022, 1, 1, 13);
      final firstEntry = BACEntry(timestamp.copyWith(hour: 11), 1.0);
      final lastEntry = BACEntry(timestamp.copyWith(hour: 12), 2.0);

      final results = BACTimeSeries([firstEntry, lastEntry]);

      final entry = results.getEntryAt(timestamp);

      expect(entry.time, timestamp);
      expect(entry.value, lastEntry.value);
    });

    test('should linearly interpolate between two values if no entry exists at the given time', () {
      final timestamp = DateTime(2022, 1, 1, 10, 30);
      final firstEntry = BACEntry(timestamp.copyWith(hour: 10, minute: 0), 1.0);
      final secondEntry = BACEntry(timestamp.copyWith(hour: 11, minute: 0), 2.0);

      final results = BACTimeSeries([firstEntry, secondEntry]);

      final entry = results.getEntryAt(timestamp);

      final interpolatedValue = (secondEntry.value + firstEntry.value) / 2.0;

      expect(entry.time, timestamp);
      expect(entry.value, interpolatedValue);
    });

    test('should be able to retrieve a specific entry by date', () {
      final timestamp = DateTime(2022, 1, 1, 14, 00);
      final bacEntry = BACEntry(timestamp.copyWith(hour: 14, minute: 0), 5.0);
      final entries = [
        BACEntry(timestamp.copyWith(hour: 10, minute: 0), 1.0),
        BACEntry(timestamp.copyWith(hour: 11, minute: 0), 2.0),
        BACEntry(timestamp.copyWith(hour: 12, minute: 0), 3.0),
        BACEntry(timestamp.copyWith(hour: 13, minute: 0), 4.0),
        bacEntry,
        BACEntry(timestamp.copyWith(hour: 15, minute: 0), 6.0),
        BACEntry(timestamp.copyWith(hour: 16, minute: 0), 7.0),
      ];

      final results = BACTimeSeries(entries);

      final entry = results.getEntryAt(timestamp);
      expect(entry, bacEntry);
    });

    group('equality', () {
      test('should be equal if empty and same time', () {
        final start = faker.date.dateTime();

        final results1 = BACTimeSeries.empty(start);
        final results2 = BACTimeSeries.empty(start);

        expect(results1, results2);
      });

      test('should not be equal if empty and different time', () {
        final time1 = faker.date.dateTime();
        final time2 = faker.date.dateTime();

        final results1 = BACTimeSeries.empty(time1);
        final results2 = BACTimeSeries.empty(time2);

        expect(results1, isNot(results2));
      });

      test('should be equal if the entries are the same', () {
        final startTime = faker.date.dateTime();
        final entries = [
          BACEntry(startTime, faker.randomGenerator.decimal(min: 0.01)),
          BACEntry(startTime.add(const Duration(minutes: 1)), faker.randomGenerator.decimal(min: 0.01)),
          BACEntry(startTime.add(const Duration(minutes: 2)), faker.randomGenerator.decimal(min: 0.01)),
          BACEntry(startTime.add(const Duration(minutes: 3)), faker.randomGenerator.decimal(min: 0.01)),
        ];

        // Use spread operator for a deep copy
        expect(BACTimeSeries([...entries]), BACTimeSeries([...entries]));
      });

      test('should not be equal with different entries', () {
        final startTime = faker.date.dateTime();
        final firstEntries = [
          BACEntry(startTime, faker.randomGenerator.decimal(min: 0.01)),
          BACEntry(startTime.add(const Duration(minutes: 1)), faker.randomGenerator.decimal(min: 0.01)),
          BACEntry(startTime.add(const Duration(minutes: 2)), faker.randomGenerator.decimal(min: 0.01)),
          BACEntry(startTime.add(const Duration(minutes: 3)), faker.randomGenerator.decimal(min: 0.01)),
        ];

        final secondEntries = [
          BACEntry(startTime, faker.randomGenerator.decimal(min: 0.01)),
          BACEntry(startTime.add(const Duration(minutes: 1)), faker.randomGenerator.decimal(min: 0.01)),
          BACEntry(startTime.add(const Duration(minutes: 2)), faker.randomGenerator.decimal(min: 0.01)),
          BACEntry(startTime.add(const Duration(minutes: 3)), faker.randomGenerator.decimal(min: 0.01)),
        ];

        expect(BACTimeSeries(firstEntries), isNot(BACTimeSeries(secondEntries)));
      });
    });
  });
}
