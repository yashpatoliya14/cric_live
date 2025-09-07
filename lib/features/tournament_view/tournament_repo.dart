import 'package:cric_live/utils/import_exports.dart';

class TournamentRepo {
  final ApiServices apiServices = ApiServices();
  final ScoreboardRepo _scoreboardRepo = ScoreboardRepo();

  Future<List<CreateMatchModel>?> fetchTournamentMatches(
    int tournamentId,
  ) async {
    List<CreateMatchModel> matches = [];
    try {
      Map<String, dynamic> data = await apiServices.get(
        "/CL_Matches/GetMatchesByTournamentId/$tournamentId",
      );

      for (Map<String, dynamic> match in data["matches"]) {
        match["team1Name"] = await _scoreboardRepo.getTeamNameOnline(
          match["team1"],
        );

        match["team2Name"] = await _scoreboardRepo.getTeamNameOnline(
          match["team2"],
        );
        log(match["team2Name"].toString());
        matches.add(CreateMatchModel.fromMap(match));
      }
    } catch (e) {
      log("Error from fetchTournamentMatches: $e");
      if (e.toString().contains("Server Error")) {
        throw Exception("Server error");
      }
      rethrow;
    }
    return matches;
  }

  Future<TournamentModel?> getTournamentById(int hostId) async {
    try {
      log("Fetching tournament with hostId: $hostId");
      Map<String, dynamic> data = await apiServices.get(
        "/CL_Tournaments/GetTournamentById/$hostId",
      );

      log("Tournament API response: $data");

      // Assuming the API returns tournaments array with single tournament
      if (data["tournaments"] != null && data["tournaments"].isNotEmpty) {
        var tournamentData = data["tournaments"][0];
        log("Creating TournamentModel from: $tournamentData");
        return TournamentModel.fromMap(tournamentData);
      } else {
        log("No tournaments found in response");
        // Check if the response is directly a tournament object instead of array
        if (data.containsKey("tournamentId") || data.containsKey("name")) {
          log("Trying to parse response as direct tournament object");
          return TournamentModel.fromMap(data);
        }
      }

      return null;
    } catch (e) {
      log("Error from getTournamentById: $e");
      if (e.toString().contains("Server Error")) {
        throw Exception("Server error while fetching tournament");
      }
      rethrow;
    }
  }
}
