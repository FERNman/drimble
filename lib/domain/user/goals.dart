class Goals {
  final int? weeklyGramsOfAlcohol;
  final int? weeklyDrinkFreeDays;

  const Goals({this.weeklyGramsOfAlcohol, this.weeklyDrinkFreeDays});

  Goals copyWith({int? weeklyGramsOfAlcohol, int? weeklyDrinkFreeDays}) => Goals(
        weeklyGramsOfAlcohol: weeklyGramsOfAlcohol ?? this.weeklyGramsOfAlcohol,
        weeklyDrinkFreeDays: weeklyDrinkFreeDays ?? this.weeklyDrinkFreeDays,
      );

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is Goals &&
          runtimeType == other.runtimeType &&
          weeklyGramsOfAlcohol == other.weeklyGramsOfAlcohol &&
          weeklyDrinkFreeDays == other.weeklyDrinkFreeDays;

  @override
  int get hashCode => Object.hash(weeklyGramsOfAlcohol, weeklyDrinkFreeDays);
}
