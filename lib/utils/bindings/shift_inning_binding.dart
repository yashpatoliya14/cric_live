import 'package:cric_live/features/shift_inning_view/shift_inning_controller.dart';
import 'package:cric_live/utils/import_exports.dart';

class ShiftInningBinding extends Bindings {
  @override
  void dependencies() {
    Map<String, dynamic> args = Get.arguments;
    Get.lazyPut(() => ShiftInningController(matchId: args['matchId']));
  }
}
