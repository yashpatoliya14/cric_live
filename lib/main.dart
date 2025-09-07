import 'package:cric_live/utils/import_exports.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  Get.put(preferences);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown, // optional (for upside down)
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SharedPreferences preferences = Get.find<SharedPreferences>();
    String? token = preferences.getString("token");

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder:
          (context, child) => GetMaterialApp(
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
              textTheme: TextTheme(
                displayLarge: GoogleFonts.nunito(fontWeight: FontWeight.w800),
                displayMedium: GoogleFonts.nunito(fontWeight: FontWeight.w500),
                displaySmall: GoogleFonts.nunito(),
                titleLarge: GoogleFonts.nunito(fontWeight: FontWeight.w800),
                titleMedium: GoogleFonts.nunito(fontWeight: FontWeight.w700),
              ),

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
                secondary: Colors.grey.shade200,
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
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                    color: Colors.deepOrange,
                    width: 2.0,
                  ),
                ),
                labelStyle: TextStyle(color: Colors.grey.shade700),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 12.0,
                ),
              ),
            ),
            darkTheme: ThemeData(),
            themeMode: ThemeMode.light,
            initialRoute: token == null ? NAV_LOGIN : NAV_DASHBOARD_PAGE,
            initialBinding: token == null ? LoginBinding() : DashboardBinding(),
            getPages: [
              GetPage(
                name: NAV_TOURNAMENT_DISPLAY,
                page: () => TournamentView(),
                binding: TournamentBinding(),
                transition: Transition.fade,
              ),
              GetPage(
                name: NAV_TOSS_DECISION,
                page: () => TossDecisionView(),
                binding: BindingsBuilder(() {
                  Get.put(CreateMatchController());
                }),
              ),

              GetPage(
                name: NAV_MATCH_VIEW,
                page: () => MatchView(),
                binding: MatchBinding(),
                transition: Transition.fade,
              ),
              GetPage(
                name: NAV_OTP_SCREEN,
                page: () => OtpScreenView(),
                binding: OtpScreenBinding(),
                transition: Transition.fade,
              ),
              GetPage(
                name: NAV_LOGIN,
                page: () => LoginView(),
                binding: LoginBinding(),
                transition: Transition.fade,
              ),
              GetPage(
                name: NAV_SIGNUP,
                page: () => const SignUpView(),
                binding: SignUpBinding(),
                transition: Transition.leftToRightWithFade,
              ),
              GetPage(
                name: NAV_DASHBOARD_PAGE,
                page: () => DashboardView(),
                binding: DashboardBinding(),
                transition: Transition.fade,
              ),
              GetPage(
                name: NAV_CREATE_TOURNAMENT,
                page: () => CreateTournamentView(),
                binding: CreateTournamentBinding(),
                transition: Transition.fade,
              ),
              GetPage(
                name: NAV_CREATE_MATCH,
                page: () => CreateMatchView(),
                binding: CreateMatchBinding(),
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
                binding: CreateTeamBinding(),
                transition: Transition.fade,
              ),
              GetPage(
                name: NAV_SCOREBOARD,
                page: () => ScoreboardView(),
                binding: ScoreboardBinding(),
                transition: Transition.fade,
              ),
              GetPage(
                name: NAV_RESULT,
                page: () => ResultView(),
                binding: ResultBinding(),
                transition: Transition.fade,
              ),
              GetPage(
                name: NAV_MATCH_VIEW,
                page: () => const MatchView(),
                binding: MatchBinding(),
                transition: Transition.fade,
              ),
              GetPage(
                name: NAV_PLAYERS,
                page: () => PlayersView(),
                binding: PlayersBinding(),
                transition: Transition.leftToRight,
              ),
              GetPage(
                name: NAV_CHOOSE_PLAYER,
                page: () => ChoosePlayerView(),
                binding: ChoosePlayerBinding(),
                transition: Transition.leftToRight,
              ),
              GetPage(
                name: NAV_SHIFT_INNING,
                page: () => ShiftInningView(),
                binding: ShiftInningBinding(),
                transition: Transition.leftToRight,
              ),

              GetPage(
                name: NAV_FORGOT_PASSWORD_EMAIL,
                page: () => ForgotPasswordEmailView(),
                binding: ForgotPasswordEmailBinding(),
                transition: Transition.leftToRight,
              ),

              GetPage(
                name: NAV_RESET_PASSWORD,
                page: () => ResetPasswordView(),
                binding: ResetPasswordBinding(),
                transition: Transition.leftToRight,
              ),
            ],
          ),
    );
  }
}
