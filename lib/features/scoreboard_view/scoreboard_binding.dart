import 'package:cric_live/utils/import_exports.dart';

class ScoreboardBinding extends Bindings {
  @override
  void dependencies() {
    final matchId = Get.arguments['matchId'];
    // Remove fenix: true to ensure fresh controller instance for each match
    Get.lazyPut(() => ScoreboardController(matchId: matchId));
  }
}
