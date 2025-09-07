import 'package:cric_live/utils/import_exports.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.put(DisplayLiveMatchController());
    Get.put(HistoryController());
  }
}
