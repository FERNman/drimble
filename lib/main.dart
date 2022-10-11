import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';

import 'data/beverages_repository.dart';
import 'data/consumed_drinks_repository.dart';
import 'data/diary_repository.dart';
import 'data/user_repository.dart';
import 'features/diary/diary_guard.dart';
import 'infra/database/database_consumed_drink.dart';
import 'infra/database/database_diary_entry.dart';
import 'router.dart';

void main() {
  runApp(const DrinkawareApp());
}

class DrinkawareApp extends StatefulWidget {
  const DrinkawareApp({super.key});

  @override
  State<DrinkawareApp> createState() => _DrinkawareAppState();
}

class _DrinkawareAppState extends State<DrinkawareApp> {
  DrinkawareRouter? _router;

  @override
  Widget build(BuildContext context) {
    const colorScheme = ColorScheme.light(
      primary: Color(0xFF0059C5),
      primaryContainer: Color(0xFFD8E2FF),
      secondary: Color(0xFF006B56),
      tertiary: Color(0xFFF3BB5D),
      tertiaryContainer: Color(0xFFFFDEAD),
      background: Colors.white,
      shadow: Colors.black,
      surface: Color(0xFFFEFBFF),
      surfaceVariant: Color(0xFFE1E2EC),
    );

    final textTheme = GoogleFonts.poppinsTextTheme();

    return MultiRepositoryProvider(
      providers: [
        // TODO: Check for a better way
        RepositoryProvider(
          lazy: false,
          create: (context) => Isar.openSync([
            DatabaseConsumedDrinkSchema,
            DatabaseDiaryEntrySchema,
          ]),
        ),
        RepositoryProvider(create: (context) => ConsumedDrinksRepository(context.read())),
        RepositoryProvider(create: (context) => DiaryRepository(context.read())),
        RepositoryProvider(create: (context) => BeveragesRepository()),
        RepositoryProvider(create: (context) => UserRepository()),
      ],
      child: Builder(
        builder: (context) {
          // Has to be done here to be able to access the context
          _router ??= DrinkawareRouter(diaryGuard: DiaryGuard(context.read()));

          return MaterialApp.router(
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: colorScheme,
              disabledColor: const Color(0x1F1F1F1F),
              scaffoldBackgroundColor: colorScheme.background,
              textTheme: textTheme,
              appBarTheme: const AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarIconBrightness: Brightness.dark,
                  statusBarColor: Colors.black,
                ),
              ),
              inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
              chipTheme: ChipThemeData(
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1.0, color: colorScheme.outline),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                labelStyle: textTheme.labelMedium,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                backgroundColor: Colors.transparent,
                selectedColor: colorScheme.primaryContainer,
                pressElevation: 0,
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: colorScheme.tertiaryContainer,
                foregroundColor: colorScheme.onTertiaryContainer,
              ),
            ),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
            ],
            title: 'Drinkaware',
            routerDelegate: _router!.delegate(),
            routeInformationParser: _router!.defaultRouteParser(),
          );
        },
      ),
    );
  }
}
