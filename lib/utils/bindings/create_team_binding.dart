import 'package:cric_live/utils/import_exports.dart';

class CreateTeamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CreateTeamController(), fenix: true);
  }
}
