import 'package:cric_live/utils/import_exports.dart';

class PlayersRepo {
  Future<List<PlayersModel>?> getPlayers(int teamId) async {
    // Database db = await MyDatabase().database;
    // List<Map<String, dynamic>> players = await db.rawQuery(
    //   '''
    //       SELECT * FROM $TBL_TEAM_PLAYERS
    //       WHERE teamId = ?
    //     ''',
    //   [id],
    // );
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
        // If response is a single item, wrap it in a list
        playersData = [data];
      }

      return List.generate(playersData.length, (i) {
        return PlayersModel().fromMap(playersData[i]);
      });
    } catch (e) {
      log("Error from fetchPlayers $e");
      return null;
    }
  }
}
