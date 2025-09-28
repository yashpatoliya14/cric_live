import 'package:cric_live/utils/import_exports.dart';

class ChoosePlayerBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;
    int teamId = args['teamId'] as int;
    int limit = args['limit'] as int;
    List<int>? hiddenPlayerIds = args['hiddenPlayerIds'] as List<int>?;
    int? matchId = args['matchId'] as int?;
    int? inningNo = args['inningNo'] as int?;
    List<int>? selectedPlayerIds = args['selectedPlayerIds'] as List<int>?;
    
    Get.lazyPut(() => ChoosePlayerController(
      teamId: teamId, 
      limit: limit,
      hiddenPlayerIds: hiddenPlayerIds,
      matchId: matchId,
      inningNo: inningNo,
      selectedPlayerIds: selectedPlayerIds,
    ));
  }
}
