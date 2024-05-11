import 'package:auto_route/auto_route.dart';

import 'features/diary/diary_guard.dart';
import 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class DrimbleRouter extends $DrimbleRouter {
  final DiaryGuard _diaryGuard;

  DrimbleRouter(this._diaryGuard);

  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  late final routes = <AutoRoute>[
    AutoRoute(page: DiaryRoute.page, path: '/', guards: [_diaryGuard]),
    AutoRoute(page: SearchDrinkRoute.page),
    AutoRoute(page: AddConsumedDrinkRoute.page),
    AutoRoute(page: EditConsumedDrinkRoute.page),
    AutoRoute(page: ProfileRoute.page),
    AutoRoute(page: EditWeeklyAlcoholGoalRoute.page),
    AutoRoute(page: EditWeeklyDrinkFreeDaysGoalRoute.page),
    AutoRoute(page: CalendarRoute.page),
    AutoRoute(page: FAQRoute.page),
    AutoRoute(page: SignInRoute.page),
    AutoRoute(
      page: OnboardingRoute.page,
      children: [
        AutoRoute(page: OnboardingEnterNameRoute.page, path: ''),
        AutoRoute(page: OnboardingSelectGenderRoute.page),
        AutoRoute(page: OnboardingSelectBirthyearRoute.page),
        AutoRoute(page: OnboardingSelectHeightRoute.page),
        AutoRoute(page: OnboardingSelectWeightRoute.page),
        AutoRoute(page: OnboardingSelectBodyCompositionRoute.page),
      ],
    )
  ];
}
