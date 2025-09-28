import 'package:cric_live/utils/import_exports.dart';
import 'package:cric_live/features/splash_screen/splash_screen_controller.dart';

class SplashScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashScreenController>(() => SplashScreenController());
  }
}
