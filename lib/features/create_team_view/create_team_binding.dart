import 'package:cric_live/features/create_team_view/create_team_controller.dart';
import 'package:cric_live/utils/import_exports.dart';

class CreateTeamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CreateTeamController());
  }
}
