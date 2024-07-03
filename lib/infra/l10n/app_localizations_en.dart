import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get common_massUnit => 'g';

  @override
  String common_mass(int amount) {
    return '${amount}g';
  }

  @override
  String get common_volumeUnit => 'ml';

  @override
  String common_volume(int amount) {
    return '${amount}ml';
  }

  @override
  String get common_caloriesUnit => 'kcal';

  @override
  String common_calories(int amount) {
    return '${amount}kcal';
  }

  @override
  String get common_continue => 'Continue';

  @override
  String get common_genderMale => 'Male';

  @override
  String get common_genderFemale => 'Female';

  @override
  String get common_bodyCompositionLean => 'Lean';

  @override
  String get common_bodyCompositionAthletic => 'Athletic';

  @override
  String get common_bodyCompositionAverage => 'Average';

  @override
  String get common_bodyCompositionOverweight => 'Overweight';

  @override
  String get common_stomachFullnessEmpty => 'Nothing';

  @override
  String get common_stomachFullnessLittle => 'A little bit';

  @override
  String get common_stomachFullnessNormal => 'A normal amount';

  @override
  String get common_stomachFullnessFull => 'A lot';

  @override
  String get common_save => 'Save';

  @override
  String get common_invalidTimeFormat => 'Invalid time format';

  @override
  String get remove_drink_title => 'Remove drink';

  @override
  String get remove_drink_description => 'Are you sure you want to remove this drink?';

  @override
  String get remove_drink_cancel => 'Cancel';

  @override
  String get remove_drink_yes => 'Yes';

  @override
  String get sign_in_welcomeToDrimble => 'Welcome to Drimble';

  @override
  String get sign_in_signInWithGoogle => 'Sign in with Google';

  @override
  String get sign_in_continueWithoutSigningIn => 'Continue without signing in';

  @override
  String get sign_in_error => 'An error occurred while signing in.';

  @override
  String get onboarding_firstNameTitle => 'How can I call you?';

  @override
  String get onboarding_enterFirstName => 'Enter your first name...';

  @override
  String get onboarding_getStarted => 'Get started';

  @override
  String get onboarding_genderSelectionTitle => 'What is your biological gender?';

  @override
  String get onboarding_genderSelectionDescription => 'Your biological gender has a great impact on the metabolism of alcohol due to differences in enzymatic activity.';

  @override
  String get onboarding_firstNameHint => 'Max';

  @override
  String get onboarding_birthyearSelectionTitle => 'When were you born?';

  @override
  String get onboarding_birthyearSelectionDescription => 'Depending on your age, a different formula is used for calcualting your blood alcohol levels.';

  @override
  String get onboarding_heightSelectionTitle => 'How tall are you?';

  @override
  String get onboarding_heightSelectionDescription => 'The size of organs vary with body height. The bigger your organs are, the faster you can metabolize alcohol.';

  @override
  String get onboarding_weightSelectionTitle => 'What is your weight?';

  @override
  String get onboarding_weightSelectionDescription => 'Combined with your height and body composition, your weight changes amount of alcohol you can tolerate without getting drunk.';

  @override
  String get onboarding_bodyCompositionSelectionTitle => 'Choose your body composition';

  @override
  String get onboarding_bodyCompositionSelectionDescription => 'The amount of muscle and fat you carry influences the amount of alcohol you can metabolize at once.';

  @override
  String get onboarding_bodyCompositionSelectionLabel => 'Body composition';

  @override
  String get onboarding_finish => 'Finish';

  @override
  String get diary_notDrinkingToday => 'Not drinking today?';

  @override
  String get diary_markAsDrinkFreeDay => 'Mark as drink-free day';

  @override
  String get diary_drinkFreeDay => 'Drink-free day 🎉';

  @override
  String get diary_drinkFreeDayGreatJob => 'Great job!';

  @override
  String get diary_consumedDrinksTitle => 'Consumed drinks';

  @override
  String get diary_consumedDrinksMore => 'more';

  @override
  String get diary_consumedDrinksSeeAll => 'see all';

  @override
  String get diary_bacChartDisclaimer => 'These values are estimates and may not reflect your actual blood alcohol level';

  @override
  String get diary_maxBAC => ' max';

  @override
  String get add_drink_addADrink => 'Add a drink';

  @override
  String get add_drink_recentlyAdded => 'Recently added';

  @override
  String get add_drink_common => 'Common';

  @override
  String get add_drink_search => 'Search...';

  @override
  String get search_drink_whatAreYouLookingFor => 'What are you looking for?';

  @override
  String get search_drink_noResults => 'We couldn\'\'t find any drinks matching your search...';

  @override
  String get edit_drink_youreAboutToConsume => 'You\'\'re about to consume';

  @override
  String edit_drink_youreAboutToConsumeGrams(int grams) {
    return '${grams}g';
  }

  @override
  String get edit_drink_youreAboutToConsumeOfAlcohol => 'of alcohol.';

  @override
  String get edit_drink_amount => 'Amount';

  @override
  String get edit_drink_enterAmount => 'enter';

  @override
  String get edit_drink_invalidAmount => 'Invalid amount';

  @override
  String get edit_drink_strength => 'Strength';

  @override
  String get edit_drink_invalidABV => 'Invalid percentage';

  @override
  String get edit_drink_stomachFullness => 'Stomach fullness';

  @override
  String get edit_drink_priorToConsumption => 'Prior to consumption';

  @override
  String get edit_drink_timing => 'Timing';

  @override
  String get edit_drink_startTime => 'Start time';

  @override
  String get edit_drink_endTime => 'End time';

  @override
  String get edit_drink_alcoholicIngredients => 'Alcoholic ingredients';

  @override
  String get edit_drink_spiritsLiquors => 'Spirits & Liquors';

  @override
  String get edit_drink_duration => 'Duration';

  @override
  String get edit_drink_invalidDuration => 'Invalid duration';

  @override
  String get edit_drink_minutes => 'minutes';

  @override
  String get edit_drink_done => 'Done';

  @override
  String get profile_title => 'Profile';

  @override
  String get profile_signOut => 'Sign out';

  @override
  String get profile_birthyear => 'Birthyear';

  @override
  String get profile_birthyear_errorEmpty => 'Please enter the year you were born';

  @override
  String get profile_birthyear_errorInvalid => 'Please enter a valid year';

  @override
  String get profile_height => 'Height';

  @override
  String get profile_weight => 'Weight';

  @override
  String get profile_bodyComposition => 'Body composition';

  @override
  String get profile_howIsTheBacEstimated => 'How is the BAC estimated?';

  @override
  String get profile_signOutDialog_title => 'Sign out';

  @override
  String get profile_signOutDialog_content => 'Are you sure you want to sign out? This will delete all your data.';

  @override
  String get profile_signOutDialog_cancel => 'Cancel';

  @override
  String get profile_signOutDialog_confirm => 'Sign out';

  @override
  String get calendar_title => 'Calendar';

  @override
  String get faq_title => 'FAQ';

  @override
  String get faq_howIsTheBloodAlcoholLevelEstimated => 'How is the blood alcohol level estimated?';

  @override
  String get faq_howIsTheBloodAlcoholLevelEstimatedText => 'To estimate the BAC, an adapted version of the Watson formula is used. The estimate is based on the amount of alcohol consumed, the time of consumption, and the amount of water in your body. To estimate those values, the formula takes gender, weight, height, and age into account. In addition, the formula assumes an average metabolism of up to 20mg/100ml (depending on the BAC) per hour.';

  @override
  String get faq_canTheAppReplaceABreathalyzer => 'Can the app replace a breathalyzer?';

  @override
  String get faq_canTheAppReplaceABreathalyzerText => 'No! The app is only intended to give an approximate indication of the blood alcohol level. The actual blood alcohol level can only be determined by a breathalyzer or a blood test.';

  @override
  String get faq_doesTheEstimatedBACCorrespondToTheActualBAC => 'Does the estimated blood alcohol level correspond to the actual blood alcohol level?';

  @override
  String get faq_doesTheEstimatedBACCorrespondToTheActualBACText => 'No! Even though the formula used is a scientifically proven method, the estimated blood alcohol level is only an approximation. The actual blood alcohol level depends on many factors, such as the individual metabolism, the amount of food consumed, the type of alcohol consumed, etc. The estimated blood alcohol level is therefore only an approximation and should not be used as a basis for decisions that could endanger life and limb.';

  @override
  String get diary_glassesOfWaterDescription => 'To avoid hangovers, consume one glass of water between every alcoholic drink.';

  @override
  String get diary_yourDrinking => 'Your drinking';

  @override
  String get diary_statisticsAlcohol => 'alcohol';

  @override
  String get diary_kcalInTotal => 'in total';

  @override
  String get diary_water => 'Water';

  @override
  String get diary_selectedWeek => 'selected week';

  @override
  String get diary_ofAlcohol => 'of alcohol';

  @override
  String get diary_quickAdd => 'Quick add';

  @override
  String get diary_trackYourHangover => 'Track your hangover';

  @override
  String get diary_predictingNoHangover => 'Predicting no hangover';

  @override
  String get diary_predictingMildHangover => 'Predicting a mild hangover';

  @override
  String get diary_predictingBadHangover => 'Predicting a pretty bad hangover';

  @override
  String get diary_predictingSevereHangover => 'Predicting a severe hangover';

  @override
  String get select_stomach_fullness_description => 'Eating before drinking influences how fast alcohol is absorbed and metabolizes.';

  @override
  String get select_stomach_fullness_title => 'How much did you eat today before drinking?';

  @override
  String get track_hangover_severity_title => 'Hungover?';

  @override
  String get track_hangover_severity_description => 'Rating the intensity of your hangover enables Drimble to better estimate your hangover severity the next time you’re drinking.';

  @override
  String get common_hangoverSeverityNone => 'No hangover 🙌🏻';

  @override
  String get common_hangoverSeverityVeryMild => 'Barely noticeable 🙂';

  @override
  String get common_hangoverSeverityMild => 'Slightly stirred 😐';

  @override
  String get common_hangoverSeverityModerate => 'Moderate 😕';

  @override
  String get common_hangoverSeverityPrettyBad => 'Pretty bad 🙁';

  @override
  String get common_hangoverSeverityHeavy => 'This is not fun 😖';

  @override
  String get common_hangoverSeveritySevere => 'I\\\'m dying 🤯';

  @override
  String get push_notification_permission_title => 'Tracking reminders';

  @override
  String get push_notification_permission_description => 'Can we send you reminders to drink water, take a break, and track your hangovers?';

  @override
  String get push_notification_permission_notNow => 'Not now';

  @override
  String get push_notification_permission_sure => 'Sure!';

  @override
  String get pushNotificationChannelName => 'Reminders';

  @override
  String get pushNotification_trackHangoverSeverity_title => 'Good morning! How are you doing?';

  @override
  String get pushNotification_trackHangoverSeverity_description => 'Track your hangover';
}
