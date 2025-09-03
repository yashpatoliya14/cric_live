import 'package:cric_live/features/choose_player_view/repo/Ichoose_player.dart';
import 'package:cric_live/utils/import_exports.dart';

class ChoosePlayerRepo implements Ichoose_player {
  @override
  Future<List<ChoosePlayerModel>?> getPlayersByTeamId(int teamId) async {
    try {
      ApiServices apiServices = ApiServices();
      Response res = await apiServices.get(
        "/CL_TeamPlayers/GetTeamPlayersById/$teamId",
      );
      if (res.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(res.body);
        return List.generate(data["data"].length, (i) {
          return ChoosePlayerModel.fromMap(data["data"][i]);
        });
      } else {
        throw Exception("Exception at fetch ");
      }
    } catch (e) {
      log("Error from fetchPlayers $e");
    }
  }
}
