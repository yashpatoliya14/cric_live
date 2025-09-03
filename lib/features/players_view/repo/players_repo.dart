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
      Response res = await apiServices.get(
        "/CL_TeamPlayers/GetTeamPlayersById/$teamId",
      );
      if (res.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(res.body);
        return List.generate(data["data"].length, (i) {
          return PlayersModel().fromMap(data["data"][i]);
        });
      } else {
        throw Exception("Exception at fetch ");
      }
    } catch (e) {
      log("Error from fetchPlayers $e");
    }
  }
}
