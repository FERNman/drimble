import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'domain/diary/consumed_drink.dart';
import 'features/add_drink/add_drink_page.dart';
import 'features/consumed_drink/consumed_drink_page.dart';
import 'features/diary/diary_guard.dart';
import 'features/diary/diary_page.dart';
import 'features/onboarding/onboarding_cubit_provider_page.dart';
import 'features/onboarding/onboarding_select_birthyear_page.dart';
import 'features/onboarding/onboarding_select_body_composition_page.dart';
import 'features/onboarding/onboarding_select_gender_page.dart';
import 'features/onboarding/onboarding_select_height_page.dart';
import 'features/onboarding/onboarding_select_weight_page.dart';
import 'features/onboarding/onboarding_welcome_page.dart';
import 'features/profile/profile_page.dart';
import 'features/todays_drinks/todays_drinks_page.dart';

part 'router.gr.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: DiaryPage, initial: true, guards: [DiaryGuard]),
    AutoRoute(page: AddDrinkPage),
    AutoRoute(page: ConsumedDrinkPage),
    AutoRoute(page: TodaysDrinksPage),
    AutoRoute(page: ProfilePage),
    AutoRoute(
      page: OnboardingCubitProviderPage,
      name: 'OnboardingRoute',
      children: [
        AutoRoute(page: OnboardingWelcomePage, initial: true),
        AutoRoute(page: OnboardingSelectGenderPage),
        AutoRoute(page: OnboardingSelectBirthyearPage),
        AutoRoute(page: OnboardingSelectHeightPage),
        AutoRoute(page: OnboardingSelectWeightPage),
        AutoRoute(page: OnboardingSelectBodyCompositionPage),
      ],
    )
  ],
)
class DrimbleRouter extends _$DrimbleRouter {
  DrimbleRouter({required super.diaryGuard});
}
