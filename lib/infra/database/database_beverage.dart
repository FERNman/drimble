import 'package:isar/isar.dart';

import '../../domain/alcohol/beverage.dart';

part 'database_beverage.g.dart';

@embedded
class DatabaseBeverage extends Beverage {
  DatabaseBeverage({
    super.name = '',
    super.icon = '',
    super.standardServings = const [],
    super.defaultABV = 0,
    super.defaultDuration = const Duration(),
  });
}

extension Database on Beverage {
  DatabaseBeverage toEntity() => DatabaseBeverage(
        name: name,
        icon: icon,
        standardServings: standardServings,
        defaultABV: defaultABV,
        defaultDuration: defaultDuration,
      );
}
