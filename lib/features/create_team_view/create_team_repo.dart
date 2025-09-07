import 'package:cric_live/utils/import_exports.dart';

class CreateTeamRepo {
  Future<int?> createTeam(List<PlayerModel> players, String teamName) async {
    try {
      ApiServices apiServices = ApiServices();
      AuthService authService = AuthService();

      TokenModel? user = authService.fetchInfoFromToken();
      if (user == null) {
        throw Exception("User not found for create team");
      }

      // Create the team first
      Map<String, dynamic> data = await apiServices.post(
        "/CL_Teams/CreateTeam",
        {"teamName": teamName, "uid": user.uid},
      );

      int teamId = data["teamId"];

      // Add each player to the team
      for (PlayerModel player in players) {
        try {
          Map<String, dynamic> playerResult = await apiServices.post(
            "/CL_TeamPlayers/CreateTeamPlayer",
            {"teamId": teamId, "playerName": player.playerName},
          );

          log("Create team player success: ${player.playerName}");
        } catch (e) {
          log("Failed to add player: ${player.playerName} - Error: $e");
        }
      }

      log("Create team success with ID: $teamId");
      return teamId;
    } catch (e) {
      log("Create team error: $e");
      if (e.toString().contains("Server Error")) {
        throw Exception("Server error from create team");
      }
      rethrow;
    }
  }
}
