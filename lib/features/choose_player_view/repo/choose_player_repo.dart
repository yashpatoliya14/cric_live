import 'package:cric_live/utils/import_exports.dart';

class ChoosePlayerRepo implements Ichoose_player {
  @override
  Future<List<PlayerModel>?> getPlayersByTeamId(int teamId) async {
    try {
      ApiServices apiServices = ApiServices();
      Map<String, dynamic> data = await apiServices.get(
        "/CL_TeamPlayers/GetTeamPlayersById/$teamId",
      );

      // Handle different response structures
      List<dynamic> playersData;
      if (data.containsKey("data") && data["data"] is List) {
        playersData = data["data"] as List<dynamic>;
      } else if (data is List) {
        playersData = data as List<dynamic>;
      } else {
        playersData = [data];
      }

      return List.generate(playersData.length, (i) {
        return PlayerModel.fromMap(playersData[i]);
      });
    } catch (e, stackTrace) {
      log("Error from Choose player repo $e  ::::::::: $stackTrace");
      return null;
    }
  }
}
