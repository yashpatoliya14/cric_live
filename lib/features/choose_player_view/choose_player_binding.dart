import 'package:cric_live/utils/import_exports.dart';

class ChoosePlayerBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;
    int teamId = args['teamId'] as int;
    int limit = args['limit'] as int;
    Get.lazyPut(() => ChoosePlayerController(teamId: teamId, limit: limit));
  }
}
