import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// No description provided for @common_massUnit.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get common_massUnit;

  /// No description provided for @common_mass.
  ///
  /// In en, this message translates to:
  /// **'{amount}g'**
  String common_mass(int amount);

  /// No description provided for @common_volumeUnit.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get common_volumeUnit;

  /// No description provided for @common_volume.
  ///
  /// In en, this message translates to:
  /// **'{amount}ml'**
  String common_volume(int amount);

  /// No description provided for @common_caloriesUnit.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get common_caloriesUnit;

  /// No description provided for @common_calories.
  ///
  /// In en, this message translates to:
  /// **'{amount}kcal'**
  String common_calories(int amount);

  /// No description provided for @common_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get common_continue;

  /// No description provided for @common_genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get common_genderMale;

  /// No description provided for @common_genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get common_genderFemale;

  /// No description provided for @common_bodyCompositionLean.
  ///
  /// In en, this message translates to:
  /// **'Lean'**
  String get common_bodyCompositionLean;

  /// No description provided for @common_bodyCompositionAthletic.
  ///
  /// In en, this message translates to:
  /// **'Athletic'**
  String get common_bodyCompositionAthletic;

  /// No description provided for @common_bodyCompositionAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get common_bodyCompositionAverage;

  /// No description provided for @common_bodyCompositionOverweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get common_bodyCompositionOverweight;

  /// No description provided for @common_stomachFullnessEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing'**
  String get common_stomachFullnessEmpty;

  /// No description provided for @common_stomachFullnessLittle.
  ///
  /// In en, this message translates to:
  /// **'A little bit'**
  String get common_stomachFullnessLittle;

  /// No description provided for @common_stomachFullnessNormal.
  ///
  /// In en, this message translates to:
  /// **'A normal amount'**
  String get common_stomachFullnessNormal;

  /// No description provided for @common_stomachFullnessFull.
  ///
  /// In en, this message translates to:
  /// **'A lot'**
  String get common_stomachFullnessFull;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @remove_drink_title.
  ///
  /// In en, this message translates to:
  /// **'Remove drink'**
  String get remove_drink_title;

  /// No description provided for @remove_drink_description.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this drink?'**
  String get remove_drink_description;

  /// No description provided for @remove_drink_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get remove_drink_cancel;

  /// No description provided for @remove_drink_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get remove_drink_yes;

  /// No description provided for @sign_in_welcomeToDrimble.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Drimble'**
  String get sign_in_welcomeToDrimble;

  /// No description provided for @sign_in_signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get sign_in_signInWithGoogle;

  /// No description provided for @sign_in_continueWithoutSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Continue without signing in'**
  String get sign_in_continueWithoutSigningIn;

  /// No description provided for @onboarding_firstNameTitle.
  ///
  /// In en, this message translates to:
  /// **'How can I call you?'**
  String get onboarding_firstNameTitle;

  /// No description provided for @onboarding_enterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name...'**
  String get onboarding_enterFirstName;

  /// No description provided for @onboarding_getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboarding_getStarted;

  /// No description provided for @onboarding_genderSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your biological gender?'**
  String get onboarding_genderSelectionTitle;

  /// No description provided for @onboarding_genderSelectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Your biological gender has a great impact on the metabolism of alcohol due to differences in enzymatic activity.'**
  String get onboarding_genderSelectionDescription;

  /// No description provided for @onboarding_firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get onboarding_firstNameHint;

  /// No description provided for @onboarding_birthyearSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'When were you born?'**
  String get onboarding_birthyearSelectionTitle;

  /// No description provided for @onboarding_birthyearSelectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Depending on your age, a different formula is used for calcualting your blood alcohol levels.'**
  String get onboarding_birthyearSelectionDescription;

  /// No description provided for @onboarding_heightSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'How tall are you?'**
  String get onboarding_heightSelectionTitle;

  /// No description provided for @onboarding_heightSelectionDescription.
  ///
  /// In en, this message translates to:
  /// **'The size of organs vary with body height. The bigger your organs are, the faster you can metabolize alcohol.'**
  String get onboarding_heightSelectionDescription;

  /// No description provided for @onboarding_weightSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your weight?'**
  String get onboarding_weightSelectionTitle;

  /// No description provided for @onboarding_weightSelectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Combined with your height and body composition, your weight changes amount of alcohol you can tolerate without getting drunk.'**
  String get onboarding_weightSelectionDescription;

  /// No description provided for @onboarding_bodyCompositionSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your body composition'**
  String get onboarding_bodyCompositionSelectionTitle;

  /// No description provided for @onboarding_bodyCompositionSelectionDescription.
  ///
  /// In en, this message translates to:
  /// **'The amount of muscle and fat you carry influences the amount of alcohol you can metabolize at once.'**
  String get onboarding_bodyCompositionSelectionDescription;

  /// No description provided for @onboarding_bodyCompositionSelectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Body composition'**
  String get onboarding_bodyCompositionSelectionLabel;

  /// No description provided for @onboarding_finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get onboarding_finish;

  /// No description provided for @home_appBarDiary.
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get home_appBarDiary;

  /// No description provided for @home_appBarAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get home_appBarAnalytics;

  /// No description provided for @diary_notDrinkingToday.
  ///
  /// In en, this message translates to:
  /// **'Not drinking today?'**
  String get diary_notDrinkingToday;

  /// No description provided for @diary_markAsDrinkFreeDay.
  ///
  /// In en, this message translates to:
  /// **'Mark as drink-free day'**
  String get diary_markAsDrinkFreeDay;

  /// No description provided for @diary_drinkFreeDay.
  ///
  /// In en, this message translates to:
  /// **'Drink-free day 🎉'**
  String get diary_drinkFreeDay;

  /// No description provided for @diary_drinkFreeDayGreatJob.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get diary_drinkFreeDayGreatJob;

  /// No description provided for @diary_reachesMaxBACAt.
  ///
  /// In en, this message translates to:
  /// **'reaches {bac} at {time}'**
  String diary_reachesMaxBACAt(String bac, DateTime time);

  /// No description provided for @diary_soberAt.
  ///
  /// In en, this message translates to:
  /// **'sober at {time}'**
  String diary_soberAt(DateTime time);

  /// No description provided for @diary_soberInFuture.
  ///
  /// In en, this message translates to:
  /// **'sober on {date} at {time}'**
  String diary_soberInFuture(DateTime date, DateTime time);

  /// No description provided for @diary_soberTomorrowAt.
  ///
  /// In en, this message translates to:
  /// **'sober tomorrow at {time}'**
  String diary_soberTomorrowAt(DateTime time);

  /// No description provided for @diary_youreSober.
  ///
  /// In en, this message translates to:
  /// **'you\'re sober! 🎉'**
  String get diary_youreSober;

  /// No description provided for @diary_statisticsGramsOfAlcohol.
  ///
  /// In en, this message translates to:
  /// **'grams of alcohol'**
  String get diary_statisticsGramsOfAlcohol;

  /// No description provided for @diary_statisticsGramsOfAlcoholGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Aim for less than 40 grams of alcohol in one session to stay healthy'**
  String get diary_statisticsGramsOfAlcoholGuidelines;

  /// No description provided for @diary_statisticsDrinks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero{drinks} one{drink} other{drinks}}'**
  String diary_statisticsDrinks(int count);

  /// No description provided for @diary_statisticsCalories.
  ///
  /// In en, this message translates to:
  /// **'calories'**
  String get diary_statisticsCalories;

  /// No description provided for @diary_statisticsConsumedToday.
  ///
  /// In en, this message translates to:
  /// **'consumed today'**
  String get diary_statisticsConsumedToday;

  /// No description provided for @diary_statisticsFromAlcohol.
  ///
  /// In en, this message translates to:
  /// **'from alcohol'**
  String get diary_statisticsFromAlcohol;

  /// No description provided for @diary_consumedDrinksTitle.
  ///
  /// In en, this message translates to:
  /// **'Consumed drinks'**
  String get diary_consumedDrinksTitle;

  /// No description provided for @diary_consumedDrinksMore.
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get diary_consumedDrinksMore;

  /// No description provided for @diary_consumedDrinksSeeAll.
  ///
  /// In en, this message translates to:
  /// **'see all'**
  String get diary_consumedDrinksSeeAll;

  /// No description provided for @diary_bacChartDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'These values are estimates and may not reflect your actual blood alcohol level'**
  String get diary_bacChartDisclaimer;

  /// No description provided for @diary_maxBAC.
  ///
  /// In en, this message translates to:
  /// **' max'**
  String get diary_maxBAC;

  /// No description provided for @analytics_title.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics_title;

  /// No description provided for @analytics_weekFromTo.
  ///
  /// In en, this message translates to:
  /// **'{start} - {end}'**
  String analytics_weekFromTo(DateTime start, DateTime end);

  /// No description provided for @analytics_changeFromLastWeek.
  ///
  /// In en, this message translates to:
  /// **'from last week'**
  String get analytics_changeFromLastWeek;

  /// No description provided for @analytics_highestBloodAlcoholLevel.
  ///
  /// In en, this message translates to:
  /// **'highest blood alcohol level'**
  String get analytics_highestBloodAlcoholLevel;

  /// No description provided for @analytics_maxBACInfo.
  ///
  /// In en, this message translates to:
  /// **'Stay below 0.08% to minimize immediate health consequences and damage to your brain.'**
  String get analytics_maxBACInfo;

  /// No description provided for @analytics_totalAlcoholConsumption.
  ///
  /// In en, this message translates to:
  /// **'Alcohol consumption'**
  String get analytics_totalAlcoholConsumption;

  /// No description provided for @analytics_totalAlcoholConsumptionDescription.
  ///
  /// In en, this message translates to:
  /// **'Your weekly alcohol consumption is the main indicator for the effect that alcohol has on you.'**
  String get analytics_totalAlcoholConsumptionDescription;

  /// No description provided for @analytics_setAGoal.
  ///
  /// In en, this message translates to:
  /// **'Set a goal'**
  String get analytics_setAGoal;

  /// No description provided for @analytics_statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get analytics_statistics;

  /// No description provided for @analytics_drinkingTrends.
  ///
  /// In en, this message translates to:
  /// **'Drinking trends'**
  String get analytics_drinkingTrends;

  /// No description provided for @analytics_date_thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get analytics_date_thisWeek;

  /// No description provided for @analytics_noAlcoholConsumedYet.
  ///
  /// In en, this message translates to:
  /// **'No drinks yet! 🎉'**
  String get analytics_noAlcoholConsumedYet;

  /// No description provided for @analytics_alcoholConsumptionWithinLimits.
  ///
  /// In en, this message translates to:
  /// **'within your limits 💪'**
  String get analytics_alcoholConsumptionWithinLimits;

  /// No description provided for @analytics_alcoholConsumptionCloseToLimit.
  ///
  /// In en, this message translates to:
  /// **'close to your limit 😬'**
  String get analytics_alcoholConsumptionCloseToLimit;

  /// No description provided for @analytics_alcoholConsumptionOverLimit.
  ///
  /// In en, this message translates to:
  /// **'surpassed your limit 😔'**
  String get analytics_alcoholConsumptionOverLimit;

  /// No description provided for @analytics_goalsWeeklyAlcoholRemaining.
  ///
  /// In en, this message translates to:
  /// **'{remainingAlcohol}g remaining'**
  String analytics_goalsWeeklyAlcoholRemaining(int remainingAlcohol);

  /// No description provided for @analytics_gramsOfAlcohol.
  ///
  /// In en, this message translates to:
  /// **'of alcohol'**
  String get analytics_gramsOfAlcohol;

  /// No description provided for @analytics_drinkFreeDays.
  ///
  /// In en, this message translates to:
  /// **'drink-free {days, plural, zero{days} one{day} other{days}}'**
  String analytics_drinkFreeDays(int days);

  /// No description provided for @analytics_remainingDrinkFreeDaysToGoal.
  ///
  /// In en, this message translates to:
  /// **'more to hit your goal!'**
  String get analytics_remainingDrinkFreeDaysToGoal;

  /// No description provided for @analytics_drinkFreeDaysGoalHit.
  ///
  /// In en, this message translates to:
  /// **'You hit your goal! 😍'**
  String get analytics_drinkFreeDaysGoalHit;

  /// No description provided for @analytics_drinksThisWeek.
  ///
  /// In en, this message translates to:
  /// **'this week'**
  String get analytics_drinksThisWeek;

  /// No description provided for @analytics_averageAlcoholPerSession.
  ///
  /// In en, this message translates to:
  /// **'avg. per session'**
  String get analytics_averageAlcoholPerSession;

  /// No description provided for @analytics_maybeTrySettingAGoal.
  ///
  /// In en, this message translates to:
  /// **'Maybe try setting a goal?'**
  String get analytics_maybeTrySettingAGoal;

  /// No description provided for @todays_drinks_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get todays_drinks_history;

  /// No description provided for @add_drink_addADrink.
  ///
  /// In en, this message translates to:
  /// **'Add a drink'**
  String get add_drink_addADrink;

  /// No description provided for @add_drink_recentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get add_drink_recentlyAdded;

  /// No description provided for @add_drink_common.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get add_drink_common;

  /// No description provided for @edit_drink_youreAboutToConsume.
  ///
  /// In en, this message translates to:
  /// **'You\'\'re about to consume'**
  String get edit_drink_youreAboutToConsume;

  /// No description provided for @edit_drink_youreAboutToConsumeGrams.
  ///
  /// In en, this message translates to:
  /// **'{grams}g'**
  String edit_drink_youreAboutToConsumeGrams(int grams);

  /// No description provided for @edit_drink_youreAboutToConsumeOfAlcohol.
  ///
  /// In en, this message translates to:
  /// **'of alcohol.'**
  String get edit_drink_youreAboutToConsumeOfAlcohol;

  /// No description provided for @edit_drink_amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get edit_drink_amount;

  /// No description provided for @edit_drink_enterAmount.
  ///
  /// In en, this message translates to:
  /// **'enter'**
  String get edit_drink_enterAmount;

  /// No description provided for @edit_drink_invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get edit_drink_invalidAmount;

  /// No description provided for @edit_drink_strength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get edit_drink_strength;

  /// No description provided for @edit_drink_invalidABV.
  ///
  /// In en, this message translates to:
  /// **'Invalid percentage'**
  String get edit_drink_invalidABV;

  /// No description provided for @edit_drink_stomachFullness.
  ///
  /// In en, this message translates to:
  /// **'Stomach fullness'**
  String get edit_drink_stomachFullness;

  /// No description provided for @edit_drink_priorToConsumption.
  ///
  /// In en, this message translates to:
  /// **'Prior to consumption'**
  String get edit_drink_priorToConsumption;

  /// No description provided for @edit_drink_timing.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get edit_drink_timing;

  /// No description provided for @edit_drink_startTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get edit_drink_startTime;

  /// No description provided for @edit_drink_endTime.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get edit_drink_endTime;

  /// No description provided for @edit_drink_alcoholicIngredients.
  ///
  /// In en, this message translates to:
  /// **'Alcoholic ingredients'**
  String get edit_drink_alcoholicIngredients;

  /// No description provided for @edit_drink_spiritsLiquors.
  ///
  /// In en, this message translates to:
  /// **'Spirits & Liquors'**
  String get edit_drink_spiritsLiquors;

  /// No description provided for @edit_drink_duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get edit_drink_duration;

  /// No description provided for @edit_drink_invalidDuration.
  ///
  /// In en, this message translates to:
  /// **'Invalid duration'**
  String get edit_drink_invalidDuration;

  /// No description provided for @edit_drink_minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get edit_drink_minutes;

  /// No description provided for @edit_drink_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get edit_drink_done;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @profile_signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profile_signOut;

  /// No description provided for @profile_birthyear.
  ///
  /// In en, this message translates to:
  /// **'Birthyear'**
  String get profile_birthyear;

  /// No description provided for @profile_birthyear_errorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter the year you were born'**
  String get profile_birthyear_errorEmpty;

  /// No description provided for @profile_birthyear_errorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid year'**
  String get profile_birthyear_errorInvalid;

  /// No description provided for @profile_height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get profile_height;

  /// No description provided for @profile_weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get profile_weight;

  /// No description provided for @profile_bodyComposition.
  ///
  /// In en, this message translates to:
  /// **'Body composition'**
  String get profile_bodyComposition;

  /// No description provided for @profile_howIsTheBacEstimated.
  ///
  /// In en, this message translates to:
  /// **'How is the BAC estimated?'**
  String get profile_howIsTheBacEstimated;

  /// No description provided for @profile_signOutDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profile_signOutDialog_title;

  /// No description provided for @profile_signOutDialog_content.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out? This will delete all your data.'**
  String get profile_signOutDialog_content;

  /// No description provided for @profile_signOutDialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profile_signOutDialog_cancel;

  /// No description provided for @profile_signOutDialog_confirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profile_signOutDialog_confirm;

  /// No description provided for @editWeeklyAlcoholGoal_title.
  ///
  /// In en, this message translates to:
  /// **'Weekly alcohol consumption'**
  String get editWeeklyAlcoholGoal_title;

  /// No description provided for @editWeeklyAlcoholGoal_description.
  ///
  /// In en, this message translates to:
  /// **'Reducing your weekly alcohol consumption can help you sleep better, feel happier and be healthier overall.\nTry setting a goal that is slightly below your current consumption, and if you manage to hit it, be more ambitious next week!'**
  String get editWeeklyAlcoholGoal_description;

  /// No description provided for @editWeeklyDrinkFreeDaysGoal_title.
  ///
  /// In en, this message translates to:
  /// **'Drink-free days'**
  String get editWeeklyDrinkFreeDaysGoal_title;

  /// No description provided for @editWeeklyDrinkFreeDaysGoal_description.
  ///
  /// In en, this message translates to:
  /// **'Drink-free days give your mind and body time to recover from the alcohol and prevent developing unhealthy habits.\nTry having at least as many drink-free days per week as days that you are drinking!'**
  String get editWeeklyDrinkFreeDaysGoal_description;

  /// No description provided for @editWeeklyGoal_setGoal.
  ///
  /// In en, this message translates to:
  /// **'Set goal!'**
  String get editWeeklyGoal_setGoal;

  /// No description provided for @analytics_switch_week_selectWeek.
  ///
  /// In en, this message translates to:
  /// **'Select week'**
  String get analytics_switch_week_selectWeek;

  /// No description provided for @analytics_switch_week_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get analytics_switch_week_apply;

  /// No description provided for @add_drink_search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get add_drink_search;

  /// No description provided for @search_drink_whatAreYouLookingFor.
  ///
  /// In en, this message translates to:
  /// **'What are you looking for?'**
  String get search_drink_whatAreYouLookingFor;

  /// No description provided for @search_drink_noResults.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'\'t find any drinks matching your search...'**
  String get search_drink_noResults;

  /// No description provided for @faq_title.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq_title;

  /// No description provided for @faq_howIsTheBloodAlcoholLevelEstimated.
  ///
  /// In en, this message translates to:
  /// **'How is the blood alcohol level estimated?'**
  String get faq_howIsTheBloodAlcoholLevelEstimated;

  /// No description provided for @faq_howIsTheBloodAlcoholLevelEstimatedText.
  ///
  /// In en, this message translates to:
  /// **'To estimate the BAC, an adapted version of the Watson formula is used. The estimate is based on the amount of alcohol consumed, the time of consumption, and the amount of water in your body. To estimate those values, the formula takes gender, weight, height, and age into account. In addition, the formula assumes an average metabolism of up to 20mg/100ml (depending on the BAC) per hour.'**
  String get faq_howIsTheBloodAlcoholLevelEstimatedText;

  /// No description provided for @faq_canTheAppReplaceABreathalyzer.
  ///
  /// In en, this message translates to:
  /// **'Can the app replace a breathalyzer?'**
  String get faq_canTheAppReplaceABreathalyzer;

  /// No description provided for @faq_canTheAppReplaceABreathalyzerText.
  ///
  /// In en, this message translates to:
  /// **'No! The app is only intended to give an approximate indication of the blood alcohol level. The actual blood alcohol level can only be determined by a breathalyzer or a blood test.'**
  String get faq_canTheAppReplaceABreathalyzerText;

  /// No description provided for @faq_doesTheEstimatedBACCorrespondToTheActualBAC.
  ///
  /// In en, this message translates to:
  /// **'Does the estimated blood alcohol level correspond to the actual blood alcohol level?'**
  String get faq_doesTheEstimatedBACCorrespondToTheActualBAC;

  /// No description provided for @faq_doesTheEstimatedBACCorrespondToTheActualBACText.
  ///
  /// In en, this message translates to:
  /// **'No! Even though the formula used is a scientifically proven method, the estimated blood alcohol level is only an approximation. The actual blood alcohol level depends on many factors, such as the individual metabolism, the amount of food consumed, the type of alcohol consumed, etc. The estimated blood alcohol level is therefore only an approximation and should not be used as a basis for decisions that could endanger life and limb.'**
  String get faq_doesTheEstimatedBACCorrespondToTheActualBACText;

  /// No description provided for @common_invalidTimeFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid time format'**
  String get common_invalidTimeFormat;

  /// No description provided for @diary_glassesOfWaterDescription.
  ///
  /// In en, this message translates to:
  /// **'To avoid hangovers, consume one glass of water between every alcoholic drink.'**
  String get diary_glassesOfWaterDescription;

  /// No description provided for @diary_yourDrinking.
  ///
  /// In en, this message translates to:
  /// **'Your drinking'**
  String get diary_yourDrinking;

  /// No description provided for @diary_statisticsAlcohol.
  ///
  /// In en, this message translates to:
  /// **'alcohol'**
  String get diary_statisticsAlcohol;

  /// No description provided for @diary_kcalInTotal.
  ///
  /// In en, this message translates to:
  /// **'in total'**
  String get diary_kcalInTotal;

  /// No description provided for @diary_water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get diary_water;

  /// No description provided for @diary_selectedWeek.
  ///
  /// In en, this message translates to:
  /// **'selected week'**
  String get diary_selectedWeek;

  /// No description provided for @diary_ofAlcohol.
  ///
  /// In en, this message translates to:
  /// **'of alcohol'**
  String get diary_ofAlcohol;

  /// No description provided for @select_stomach_fullness_description.
  ///
  /// In en, this message translates to:
  /// **'Eating before drinking influences how fast alcohol is absorbed and metabolizes.'**
  String get select_stomach_fullness_description;

  /// No description provided for @select_stomach_fullness_title.
  ///
  /// In en, this message translates to:
  /// **'How much did you eat today before drinking?'**
  String get select_stomach_fullness_title;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
