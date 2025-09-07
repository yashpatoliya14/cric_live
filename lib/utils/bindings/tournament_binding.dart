import 'package:cric_live/utils/import_exports.dart';

class TournamentBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => TournamentController());
  }
}
