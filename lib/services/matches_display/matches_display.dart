import 'package:cric_live/utils/import_exports.dart';

class MatchesDisplay {
  final AuthService service = AuthService();
  final ApiServices apiServices = ApiServices();
  final ScoreboardRepository _scoreboardRepo = ScoreboardRepository();

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
          if (matchData is Map<String, dynamic>) {
            try {
              // Always try to create MatchModel, regardless of matchState
              MatchModel model = MatchModel.fromMap(matchData);
              matches.add(model);

            } catch (e) {
              log('❌ Error creating match model: ${e.toString()}');
              log('🔍 Problematic match data: $matchData');
            }
          } else {
            log('⚠️ Invalid match data format: $matchData');
          }
        }
      } else {
        log('⚠️ No matches found in response or invalid format');
        log('🔍 Response structure: ${data.keys.toList()}');
      }

      // Log matches info safely
      if (matches.isEmpty) {
        log("🔍 No valid matches found for user (UID: $uid)");
      }

      return matches;
    } catch (e) {
      log('❌ getUsersMatches error: ${e.toString()}');
      // Handle specific error cases
      if (e.toString().contains("Not Found")) {
        log("⚠️ Match endpoints not found on backend server");
        log("💡 Returning empty list for now");
        return <MatchModel>[];
      } else if (e.toString().contains("Server Error")) {
        throw Exception("Server error while fetching user matches");
      } else if (e.toString().contains("not authenticated")) {
        throw Exception("User authentication failed");
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

  /// Fetch live matches with pagination
  Future<List<MatchModel>?> getLiveMatchPaginated({required int from, required int limit}) async {
    try {
      log('📡 Fetching paginated live matches from: $from, limit: $limit');
      
      ApiServices apiServices = ApiServices();
      Map<String, dynamic> data = await apiServices.get(
        "/CL_Matches/GetLiveMatch/$from/$limit",
      );

      List<MatchModel> matches = [];

      // Check if matches data exists and is a list
      if (data.containsKey("matches") && data["matches"] is List) {
        List<dynamic> rawMatches = data["matches"] as List<dynamic>;
        log('📋 Raw matches received: ${rawMatches.length}');

        for (dynamic matchData in rawMatches) {
          if (matchData is Map<String, dynamic>) {
            try {
              // Add venue field if not present (fallback)
              if (!matchData.containsKey("location") ||
                  matchData["location"] == null) {
                matchData["location"] = "Venue TBD";
              }

              MatchModel model = MatchModel.fromMap(matchData);
              matches.add(model);
              log('✅ Successfully created match model: ${model.id} - ${model.status}');
            } catch (e) {
              log('❌ Error creating match model: ${e.toString()}');
            }
          }
        }
      } else {
        log('⚠️ No matches found in response or invalid format');
        log('🔍 Response structure: ${data.keys.toList()}');
      }

      log('📊 Total paginated matches parsed: ${matches.length}');
      return matches;
    } catch (e) {
      log('❌ getLiveMatchPaginated error: ${e.toString()}');
      if (e.toString().contains("Server Error")) {
        throw Exception("Server Side Error In fetch paginated live matches");
      }
      rethrow;
    }
  }
}
