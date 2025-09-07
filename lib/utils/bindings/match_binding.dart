import 'package:cric_live/features/match_view/match_controller.dart';
import 'package:cric_live/utils/import_exports.dart';

class MatchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MatchController>(() => MatchController(), fenix: true);
  }
}
