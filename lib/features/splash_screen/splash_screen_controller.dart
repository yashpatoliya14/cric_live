import 'package:cric_live/utils/import_exports.dart';

class SplashScreenController extends GetxController {
  final RxString loadingText = 'Loading...'.obs;
  
  @override
  void onInit() {
    super.onInit();
    initializeApp();
  }
  
  /// Simple app initialization
  Future<void> initializeApp() async {
    loadingText.value = 'Initializing...';
    await Future.delayed(const Duration(seconds: 1));
    
    loadingText.value = 'Loading data...';
    await Future.delayed(const Duration(seconds: 1));
    
    loadingText.value = 'Almost ready...';
    await Future.delayed(const Duration(milliseconds: 500));
    
    navigateToNextScreen();
  }
  
  void navigateToNextScreen() {
    SharedPreferences preferences = Get.find<SharedPreferences>();
    String? token = preferences.getString("token");
    
    // Navigate based on authentication status
    if (token == null) {
      Get.offAllNamed(NAV_LOGIN);
    } else {
      Get.offAllNamed(NAV_DASHBOARD_PAGE);
    }
  }
}
