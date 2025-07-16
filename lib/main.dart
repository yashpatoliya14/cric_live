import 'package:cric_live/features/dashboard_view/dashboard_view.dart';
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
        scaffoldBackgroundColor: Colors.blue[500],
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.deepOrange,
          focusColor: Colors.deepOrange.shade900,
          disabledColor: Colors.deepOrange.shade200,
          textTheme: ButtonTextTheme.primary,
        ),
        textTheme: GoogleFonts.nunitoTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          titleTextStyle: GoogleFonts.openSans(color: Colors.black),
        ),
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Colors.deepOrange,
          onPrimary: Colors.white,
          secondary: Colors.deepOrange.shade500,
          onSecondary: Colors.white,
          error: Colors.red.shade900,
          onError: Colors.white,
          surface: Colors.blue.shade50,
          onSurface: Colors.black,
        ),
      ),
      darkTheme: ThemeData(
        //implement in later version
      ),
      home: DashboardView(),
      getPages: [
        // GetPage(name: "/dashboard", page:()=>DashboardView())
      ],
    );
  }
}
