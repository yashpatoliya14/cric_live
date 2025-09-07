import 'package:cric_live/utils/import_exports.dart';

class SelectTeamRepo implements IselectTeam {
  late SharedPreferences prefs;
  SelectTeamRepo() {
    prefs = Get.find<SharedPreferences>();
  }
  final ApiServices apiServices = ApiServices();
  @override
  Future<List<SelectTeamModel>> fetchTeams({int? tournamentId}) async {
    try {
      List<SelectTeamModel> teams = <SelectTeamModel>[];
      final AuthService authService = AuthService();
      TokenModel? tokenModel = authService.fetchInfoFromToken();
      if (tokenModel == null) {
        throw Exception("User not found");
      }

      Map<String, dynamic> data;
      if (tournamentId != null) {
        data = await apiServices.get(
          "/CL_TournamentTeams/GetTournamentTeamById/$tournamentId",
        );
      } else {
        data = await apiServices.get(
          "/CL_Teams/GetTeamsByUid/${tokenModel.uid}",
        );
      }

      if (data["data"] != null) {
        data["data"].forEach((team) {
          SelectTeamModel model = SelectTeamModel();
          model.teamId = team["teamId"];
          model.teamName = team["teamName"];
          model.tournamentId = team["tournamentId"];
          teams.add(model);
          log("$teams");
        });
        return teams;
      } else {
        throw Exception(":::: Teams not found ::::$data");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> fetchPlayersAndSave(
    List<SelectTeamModel> teams,
    wantToStore,
  ) async {
    Database db = await MyDatabase().database;

    try {
      teams.forEach((team) async {
        ApiServices apiServices = ApiServices();
        try {
          Map<String, dynamic> data = await apiServices.get(
            "/CL_TeamPlayers/GetTeamPlayersById/${team.teamId}",
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

          if (playersData.isNotEmpty) {
            playersData.forEach((team) async {
              PlayersModel model = PlayersModel();
              model.teamId = team["teamId"];
              model.playerName = team["playerName"];
              model.teamPlayerId = team["teamPlayerId"];
              // for scoring only
              if (wantToStore) {
                db.insert(TBL_TEAM_PLAYERS, model.toMap());
              }
            });
          } else {
            log(":::: No players found for team ${team.teamId} ::::$data");
          }
        } catch (e) {
          log(" ::: Fetch players failed for team ${team.teamId} :::$e");
        }
      });
    } catch (e) {
      log("$e");
    }
  }

  @override
  Future<List<SelectTeamModel>> getAllTeams({
    required bool wantToStore,
    int? tournamentId,
  }) async {
    try {
      List<SelectTeamModel> teams = await fetchTeams(
        tournamentId: tournamentId,
      );
      await fetchPlayersAndSave(teams, wantToStore);
      if (tournamentId != null) {
        return teams;
      }
      // for scoring
      if (wantToStore) {
        Database db = await MyDatabase().database;
        teams.forEach((team) async {
          log(team.toMap().toString());
          await db.insert(TBL_TEAMS, team.toMap());
        });
      }
      return teams;
    } catch (e) {
      log("$e");
      Get.snackbar("Exception", e.toString());
      return [];
    }
  }
}
