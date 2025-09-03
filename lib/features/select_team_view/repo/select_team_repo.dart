import 'package:cric_live/services/auth/auth_service.dart';
import 'package:cric_live/services/auth/token_model.dart';
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
      late Response res;
      final AuthService authService = AuthService();
      TokenModel? tokenModel = authService.fetchInfoFromToken();
      if (tokenModel == null) {
        throw Exception("User not found");
      }
      if (tournamentId != null) {
        log("$tournamentId");
        log(":::::::::::::::::::::::::::::");
        res = await apiServices.get(
          "/CL_TournamentTeams/GetTournamentTeamById/$tournamentId",
        );
      } else {
        res = await apiServices.get("/CL_Teams/GetTeamByUid/${tokenModel.uid}");
      }
      if (res.statusCode == 200) {
        Map<String, dynamic> data =
            jsonDecode(res.body) as Map<String, dynamic>;

        if (data["data"] != null) {
          data["data"].forEach((team) {
            SelectTeamModel model = SelectTeamModel();
            model.teamId = team["teamId"];
            model.teamName = team["teamName"];
            model.teamLogo = team["logo"];
            model.tournamentId = team["tournamentId"];
            teams.add(model);
            log("$teams");
          });
          return teams;
        } else {
          throw Exception(":::: Teams not found ::::$data");
        }
      } else {
        throw Exception(" ::: Fetch teams failed :::$res");
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
        Response res = await apiServices.get(
          "/CL_TeamPlayers/GetTeamPlayers?teamId=${team.teamId}",
        );
        if (res.statusCode == 200) {
          List<dynamic> data = json.decode(res.body);

          if (data.isNotEmpty) {
            data.forEach((team) async {
              PlayersModel model = PlayersModel();
              model.teamId = team["teamId"];
              model.playerId = team["playerId"];
              model.playerName = team["playerName"];
              model.teamPlayerId = team["teamPlayerId"];
              // for scoring only
              if (wantToStore) {
                db.insert(TBL_TEAM_PLAYERS, model.toMap());
              }
            });
          } else {
            throw Exception(":::: Teams not found ::::$data");
          }
        } else {
          throw Exception(" ::: Fetch teams failed :::$res");
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
