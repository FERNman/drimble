import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:sqlbrite/sqlbrite.dart';

import 'data/daos/diary_dao.dart';
import 'data/daos/drinks_dao.dart';
import 'data/diary_repository.dart';
import 'data/drinks_repository.dart';
import 'data/user_repository.dart';
import 'features/home/home_guard.dart';
import 'infra/l18n/l10n.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = await openDatabase(
    join(await getDatabasesPath(), 'drimble.db'),
    onCreate: (db, version) async {
      await DrinksDAO.create(db);
      await DiaryDAO.create(db);
    },
    version: 1,
  );
  final brite = BriteDatabase(database);

  runApp(DrimbleApp(brite));
}

class DrimbleApp extends StatefulWidget {
  final BriteDatabase database;

  const DrimbleApp(this.database, {super.key});

  @override
  State<DrimbleApp> createState() => _DrimbleAppState();
}

class _DrimbleAppState extends State<DrimbleApp> {
  DrimbleRouter? _router;

  @override
  Widget build(BuildContext context) {
    const colorScheme = ColorScheme.light(
      primary: Color(0xFF3879E9),
      primaryContainer: Color(0xFFD8E2FF),
      secondary: Color(0xFF7BE5C5),
      tertiary: Color(0xFFF3BB5D),
      tertiaryContainer: Color(0xFFFFDEAD),
      background: Colors.white,
      shadow: Colors.black,
      surface: Color(0xFFFEFBFF),
      surfaceVariant: Color(0xFFE1E2EC),
      surfaceTint: Colors.white,
    );

    final textTheme = GoogleFonts.poppinsTextTheme().apply(displayColor: Colors.black87);

    if (Platform.isAndroid) {
      // A hack(?) to make sure the navigation bar color is white on Android
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
      ));

      // https://github.com/flutter/flutter/issues/40590
      final WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
      binding.renderView.automaticSystemUiAdjustment = false;
    }

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => DrinksDAO(widget.database)),
        RepositoryProvider(create: (context) => DiaryDAO(widget.database)),
        RepositoryProvider(create: (context) => DrinksRepository(context.read(), context.read())),
        RepositoryProvider(create: (context) => DiaryRepository(context.read(), context.read())),
        RepositoryProvider(create: (context) => UserRepository(widget.database)),
      ],
      child: Builder(
        builder: (context) {
          // Has to be done here to be able to access the context
          _router ??= DrimbleRouter(homeGuard: HomeGuard(context.read()));

          return MaterialApp.router(
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: colorScheme,
              disabledColor: const Color(0x1F1F1F1F),
              scaffoldBackgroundColor: colorScheme.background,
              textTheme: textTheme,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                systemOverlayStyle: SystemUiOverlayStyle.dark,
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
                showCheckmark: false,
              ),
              cardTheme: CardTheme(
                color: Colors.white,
                margin: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              dividerTheme: const DividerThemeData(
                color: Colors.black54,
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: colorScheme.tertiaryContainer,
                foregroundColor: colorScheme.onTertiaryContainer,
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Colors.white,
                selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
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
            title: 'Drimble',
            routerDelegate: _router!.delegate(),
            routeInformationParser: _router!.defaultRouteParser(),
          );
        },
      ),
    );
  }
}
