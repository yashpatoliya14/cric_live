import 'package:cric_live/utils/import_exports.dart';

class DisplayLiveMatchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DisplayLiveMatchController>(() => DisplayLiveMatchController());
  }
}
