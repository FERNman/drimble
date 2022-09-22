import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'domain/drink/consumed_drink.dart';
import 'features/add_drink/add_drink_page.dart';
import 'features/consumed_drink/consumed_drink_page.dart';
import 'features/home/home_page.dart';
import 'features/profile/profile_page.dart';
import 'features/todays_drinks/todays_drinks_page.dart';

part 'router.gr.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: HomePage, initial: true),
    AutoRoute(page: AddDrinkPage),
    AutoRoute(page: ConsumedDrinkPage),
    AutoRoute(page: TodaysDrinksPage),
    AutoRoute(page: ProfilePage),
  ],
)
class DrinkawareRouter extends _$DrinkawareRouter {}
