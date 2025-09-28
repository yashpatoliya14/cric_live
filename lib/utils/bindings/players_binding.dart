import 'package:cric_live/features/players_view/players_view.dart';
import 'package:cric_live/utils/import_exports.dart';

class PlayersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PlayersView(),fenix: true);
  }
}
