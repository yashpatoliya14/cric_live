import 'package:cric_live/features/players_view/repo/players_repo.dart';
import 'package:cric_live/utils/import_exports.dart';

class PlayersController extends GetxController {
  int teamId;
  bool isView;
  PlayersController({required this.teamId, required this.isView});
  PlayersRepo _repo = PlayersRepo();

  //variables
  RxList<PlayersModel> players = <PlayersModel>[].obs;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getPlayers(teamId);
  }

  Future<void> getPlayers(id) async {
    players.value = await _repo.getPlayers(id) ?? [];
  }
}
