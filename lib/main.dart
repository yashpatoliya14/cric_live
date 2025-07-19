import 'package:cric_live/features/result_view/result_view.dart';
import 'package:cric_live/utils/import_exports.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CricLive',
      theme: ThemeData(
        splashColor: Colors.transparent,
        scaffoldBackgroundColor: Colors.blue[50],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.openSans(fontWeight: FontWeight.w600),
          ),
        ),

        textTheme: GoogleFonts.nunitoTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          titleTextStyle: GoogleFonts.openSans(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          scrolledUnderElevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,

          elevation: 0,
        ),
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Colors.deepOrange,
          onPrimary: Colors.white,
          secondary: Colors.blue.shade100,
          onSecondary: Colors.white,
          error: Colors.red.shade900,
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            shadowColor: Colors.grey,
            backgroundColor: Colors.grey.shade100,
          ),
        ),
        listTileTheme: ListTileThemeData(
          iconColor: Colors.deepOrangeAccent,
          titleTextStyle: GoogleFonts.nunito(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        //implement in later version
      ),
      initialRoute: NAV_DASHBOARD_PAGE,
      getPages: [
        GetPage(
          name: NAV_DASHBOARD_PAGE,
          page: () => DashboardView(),
          transition: Transition.fade,
        ),
        GetPage(
          name: NAV_CREATE_TOURNAMENT,
          page: () => CreateTournamentView(),
          transition: Transition.fade,
        ),
        GetPage(
          name: NAV_CREATE_TOURNAMENT,
          page: () => CreateTournamentView(),
          transition: Transition.fade,
        ),
        GetPage(
          name: NAV_SEARCH,
          page: () => SearchScreenView(),
          transition: Transition.fade,
        ),
        GetPage(
          name: NAV_SELECT_TEAM,
          page: () => SelectTeamView(),
          transition: Transition.fade,
        ),
        GetPage(
          name: NAV_CREATE_TEAM,
          page: () => CreateTeamView(),
          transition: Transition.fade,
        ),
        GetPage(
          name: NAV_SCOREBOARD,
          page: () => ScoreboardView(),
          transition: Transition.fade,
        ),
        GetPage(
          name: NAV_RESULT,
          page: () => ResultView(),
          transition: Transition.fade,
        ),
      ],
    );
  }
}
