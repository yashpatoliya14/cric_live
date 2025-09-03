import 'package:cric_live/features/display_live_matches/display_live_match_controller.dart';
import 'package:cric_live/utils/import_exports.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.put(DisplayLiveMatchController());
    Get.put(HistoryController());
  }
}
