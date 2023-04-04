import 'package:realm/realm.dart';

import '../../domain/alcohol/milliliter.dart';
import '../../domain/alcohol/percentage.dart';

part 'drink_model.g.dart';

@RealmModel()
class _DrinkModel {
  @PrimaryKey()
  late String id;
  late String name;
  late String icon;
  late String category;
  late Milliliter volume;
  late Percentage alcoholByVolume;
  late DateTime startTime;
  late int duration;
  late String stomachFullness;
}
