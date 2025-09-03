import 'package:cric_live/features/display_live_matches/display_live_match_controller.dart';
import 'package:cric_live/utils/import_exports.dart';

class DisplayLiveMatchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DisplayLiveMatchController>(
      () => DisplayLiveMatchController(),
    );
  }
}
