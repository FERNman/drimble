import 'package:realm/realm.dart';

part 'diary_entry_model.g.dart';

@RealmModel()
class _DiaryEntryModel {
  @PrimaryKey()
  late String id;

  late DateTime date;
  late bool isDrinkFreeDay;
}
