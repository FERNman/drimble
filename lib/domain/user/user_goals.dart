import 'package:json_annotation/json_annotation.dart';

part 'user_goals.g.dart';

@JsonSerializable()
class UserGoals {
  final int? weeklyGramsOfAlcohol;
  final int? weeklyDrinkFreeDays;

  const UserGoals({this.weeklyGramsOfAlcohol, this.weeklyDrinkFreeDays});

  UserGoals copyWith({int? weeklyGramsOfAlcohol, int? weeklyDrinkFreeDays}) => UserGoals(
        weeklyGramsOfAlcohol: weeklyGramsOfAlcohol ?? this.weeklyGramsOfAlcohol,
        weeklyDrinkFreeDays: weeklyDrinkFreeDays ?? this.weeklyDrinkFreeDays,
      );

  factory UserGoals.fromJson(Map<String, dynamic> json) => _$UserGoalsFromJson(json);

  Map<String, dynamic> toJson() => _$UserGoalsToJson(this);

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is UserGoals &&
          weeklyGramsOfAlcohol == other.weeklyGramsOfAlcohol &&
          weeklyDrinkFreeDays == other.weeklyDrinkFreeDays;

  @override
  int get hashCode => Object.hash(weeklyGramsOfAlcohol, weeklyDrinkFreeDays);
}
