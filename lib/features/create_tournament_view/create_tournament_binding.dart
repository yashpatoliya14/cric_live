import 'package:cric_live/utils/import_exports.dart';

class CreateTournamentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CreateTournamentController());
  }
}
