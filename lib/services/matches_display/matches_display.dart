import 'package:cric_live/utils/import_exports.dart';

class MatchesDisplay {
  final AuthService service = AuthService();
  final ApiServices apiServices = ApiServices();
  final ScoreboardRepo _scoreboardRepo = ScoreboardRepo();

  /// Fetch all user's matches based on uid
  Future<List<MatchModel>?> getUsersMatches() async {
    try {
      TokenModel? model = service.fetchInfoFromToken();
      if (model == null) {
        throw Exception("User not authenticated");
      }
      int uid = model.uid!;

      Map<String, dynamic> data = await apiServices.get(
        "/CL_Matches/GetMatchesByUser/$uid",
      );

      List<MatchModel> matches = [];

      // Check if matches data exists and is a list
      if (data.containsKey("matches") && data["matches"] is List) {
        List<dynamic> rawMatches = data["matches"] as List<dynamic>;

        for (dynamic matchData in rawMatches) {
          if (matchData is Map<String, dynamic> ||
              matchData["status"] == "scheduled") {
            try {
              if (matchData["status"] == "scheduled") {
                matchData["team1Name"] = await _scoreboardRepo
                    .getTeamNameOnline(matchData["team1"]);
                matchData["team2Name"] = await _scoreboardRepo
                    .getTeamNameOnline(matchData["team2"]);
              }
              if (matchData["matchState"] != null) {
                matchData["matchState"] =
                    jsonDecode(matchData["matchState"]) as Map<String, dynamic>;
              }
              MatchModel model = MatchModel.fromMap(matchData);

              matches.add(model);
            } catch (e) {
              log('Error creating match model: ${e.toString()}');
              // Continue with other matches instead of failing completely
            }
          }
        }
      } else {
        log('No matches found in response or invalid format');
      }

      // Log matches info safely
      if (matches.isEmpty) {
        log("No matches found for user");
      }

      return matches;
    } catch (e) {
      log('getUsersMatches error: ${e.toString()}');
      // Handle specific error cases
      if (e.toString().contains("Not Found")) {
        log("⚠️ Match endpoints not implemented on backend server");
        log("💡 Returning empty list for now");
        return <MatchModel>[];
      } else if (e.toString().contains("Server Error")) {
        throw Exception("Server Side Error In fetch matches by user");
      }
      rethrow;
    }
  }

  /// Fetch all user's tournaments based on uid
  Future<List<CreateTournamentModel>?> getUsersTournaments() async {
    try {
      AuthService service = AuthService();
      TokenModel? model = service.fetchInfoFromToken();
      if (model == null) {
        throw Exception("User not authenticated");
      }
      int uid = model.uid!;

      ApiServices apiServices = ApiServices();
      Map<String, dynamic> data = await apiServices.get(
        "/CL_Tournaments/GetTournamentById/$uid",
      );

      List<CreateTournamentModel> matches = [];

      // Check if matches data exists and is a list
      if (data.containsKey("tournaments") && data["tournaments"] is List) {
        List<dynamic> rawMatches = data["tournaments"] as List<dynamic>;

        for (dynamic tournament in rawMatches) {
          if (tournament is Map<String, dynamic>) {
            try {
              CreateTournamentModel model = CreateTournamentModel.fromJson(
                tournament,
              );
              matches.add(model);
            } catch (e) {
              log('Error creating match model: ${e.toString()}');
              // Continue with other matches instead of failing completely
            }
          }
        }
      } else {
        log('No matches found from tournaments in response or invalid format');
      }

      // Log matches info safely
      if (matches.isEmpty) {
        log("No matches tournaments found for user");
      }

      return matches;
    } catch (e) {
      log('getUsersMatches error: ${e.toString()}');
      // Handle specific error cases
      if (e.toString().contains("Not Found")) {
        log("⚠️ Match endpoints not implemented on backend server");
        log("💡 Returning empty list for now");
        return <CreateTournamentModel>[];
      } else if (e.toString().contains("Server Error")) {
        throw Exception("Server Side Error In fetch matches by user");
      }
      rethrow;
    }
  }

  /// Fetch live matches
  Future<List<MatchModel>?> getLiveMatches() async {
    try {
      ApiServices apiServices = ApiServices();
      Map<String, dynamic> data = await apiServices.get(
        "/CL_Matches/GetLiveMatch",
      );

      List<MatchModel> matches = [];

      // Check if matches data exists and is a list
      if (data.containsKey("matches") && data["matches"] is List) {
        List<dynamic> rawMatches = data["matches"] as List<dynamic>;

        for (dynamic matchData in rawMatches) {
          if (matchData is Map<String, dynamic>) {
            try {
              // Parse matchState if it's a string
              if (matchData["matchState"] is String) {
                matchData["matchState"] = jsonDecode(matchData["matchState"]);
              }

              // Add venue field if not present (fallback)
              if (!matchData.containsKey("location") ||
                  matchData["location"] == null) {
                matchData["location"] = "Venue TBD";
              }

              MatchModel model = MatchModel.fromMap(matchData);
              matches.add(model);
            } catch (e) {
              log('Error creating match model: ${e.toString()}');
            }
          }
        }
      } else {
        log('No matches found in response or invalid format');
      }

      return matches;
    } catch (e) {
      log('getLiveMatches error: ${e.toString()}');
      if (e.toString().contains("Server Error")) {
        throw Exception("Server Side Error In fetch live matches");
      }
      rethrow;
    }
  }
}
