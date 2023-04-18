import 'package:auto_route/auto_route.dart';

import 'features/home/home_guard.dart';
import 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class DrimbleRouter extends $DrimbleRouter {
  final HomeGuard _homeGuard;

  DrimbleRouter(this._homeGuard);

  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  late final routes = <AutoRoute>[
    AutoRoute(
      page: HomeRoute.page,
      path: '/',
      guards: [_homeGuard],
      children: [
        AutoRoute(page: DiaryRoute.page, path: ''),
        AutoRoute(page: AnalyticsRoute.page),
      ],
    ),
    AutoRoute(page: AddDrinkRoute.page),
    AutoRoute(page: EditDrinkRoute.page),
    AutoRoute(page: CreateDrinkRoute.page),
    AutoRoute(page: TodaysDrinksRoute.page),
    AutoRoute(page: ProfileRoute.page),
    AutoRoute(page: EditWeeklyAlcoholGoalRoute.page),
    AutoRoute(page: EditWeeklyDrinkFreeDaysGoalRoute.page),
    AutoRoute(
      page: OnboardingRoute.page,
      children: [
        AutoRoute(page: OnboardingWelcomeRoute.page, path: ''),
        AutoRoute(page: OnboardingSelectGenderRoute.page),
        AutoRoute(page: OnboardingSelectBirthyearRoute.page),
        AutoRoute(page: OnboardingSelectHeightRoute.page),
        AutoRoute(page: OnboardingSelectWeightRoute.page),
        AutoRoute(page: OnboardingSelectBodyCompositionRoute.page),
      ],
    )
  ];
}
