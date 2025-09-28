import 'package:cric_live/utils/import_exports.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // PreloadService should already be registered from SplashScreen
    // If not found, create it as fallback
    if (!Get.isRegistered<PreloadService>()) {
      Get.put(PreloadService(), permanent: true);
    }
    
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.put(DisplayLiveMatchController());
    Get.put(HistoryController());
  }
}
