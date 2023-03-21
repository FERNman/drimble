class Goals {
  final int? weeklyGramsOfAlcohol;
  final int? weeklyDrinkFreeDays;

  const Goals({this.weeklyGramsOfAlcohol, this.weeklyDrinkFreeDays});

  Goals copyWith({int? weeklyGramsOfAlcohol, int? weeklyDrinkFreeDays}) => Goals(
        weeklyGramsOfAlcohol: weeklyGramsOfAlcohol ?? this.weeklyGramsOfAlcohol,
        weeklyDrinkFreeDays: weeklyDrinkFreeDays ?? this.weeklyDrinkFreeDays,
      );
}
