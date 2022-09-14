import 'package:isar/isar.dart';

part 'database_duration.g.dart';

@embedded
class DatabaseDuration {
  @ignore
  Duration duration;

  int get value => duration.inMicroseconds;
  set value(int microseconds) => duration = Duration(microseconds: microseconds);

  DatabaseDuration({int microseconds = 0}) : duration = Duration(microseconds: microseconds);
}

extension Database on Duration {
  DatabaseDuration toEntity() => DatabaseDuration(microseconds: inMicroseconds);
}
