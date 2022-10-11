import 'package:isar/isar.dart';

import '../../infra/extensions/floor_date_time.dart';

class DiaryEntry {
  Id? id;

  @Index()
  final DateTime date;

  bool isDrinkFreeDay;

  DiaryEntry({this.id, required DateTime date, required this.isDrinkFreeDay}) : date = date.floorToDay();
}
