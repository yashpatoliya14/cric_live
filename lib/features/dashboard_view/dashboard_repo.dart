import 'package:cric_live/services/auth/auth_service.dart';
import 'package:cric_live/services/auth/token_model.dart';
import 'package:cric_live/utils/import_exports.dart';

class DashboardRepo {
  /// Fetch all user's matches based on uid
  Future<List<CreateMatchModel>?> getUsersMatches() async {
    try {
      AuthService service = AuthService();
      TokenModel? model = service.fetchInfoFromToken();
      if (model == null) {
        throw Exception("User not authenticated");
      }
      int uid = model.uid!;

      ApiServices apiServices = ApiServices();
      Response res = await apiServices.get("/CL_Matches/GetMatchesByUser/$uid");

      if (res.statusCode == 200) {
        List<CreateMatchModel> matches = [];

        // Parse JSON response body
        Map<String, dynamic> data;
        try {
          data = jsonDecode(res.body) as Map<String, dynamic>;
        } catch (e) {
          log(
            'Error parsing JSON response in getUsersMatches: ${e.toString()}',
          );
          log('Response body: ${res.body}');
          throw Exception('Invalid JSON response from server');
        }

        // Check if matches data exists and is a list
        if (data.containsKey("matches") && data["matches"] is List) {
          List<dynamic> rawMatches = data["matches"] as List<dynamic>;

          for (dynamic matchData in rawMatches) {
            if (matchData is Map<String, dynamic>) {
              try {
                CreateMatchModel model = CreateMatchModel().fromMap(matchData);
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
        if (matches.isNotEmpty) {
          log("First match data: ${matches[0].toMap()}");
          log("Total matches found: ${matches.length}");
        } else {
          log("No matches found for user");
        }

        return matches;
      } else if (res.statusCode == 404) {
        log("⚠️ Match endpoints not implemented on backend server");
        log("💡 Returning empty list for now");
        return <CreateMatchModel>[];
      } else if (res.statusCode == 500) {
        throw Exception("Server Side Error In fetch matches by user");
      } else {
        log("Unexpected Error - Status: ${res.statusCode}");
        log("Response body: ${res.body}");
        throw Exception(
          "Failed to fetch user matches - Status: ${res.statusCode}",
        );
      }
    } catch (e) {
      log('getUsersMatches error: ${e.toString()}');
      rethrow;
    }
  }

  /// Fetch live matches
  Future<List<CreateMatchModel>?> getLiveMatches() async {
    try {
      ApiServices apiServices = ApiServices();
      Response res = await apiServices.get("/CL_Matches/GetLiveMatch");

      if (res.statusCode == 200) {
        List<CreateMatchModel> matches = [];

        // Parse JSON response body
        Map<String, dynamic> data;
        try {
          data = jsonDecode(res.body) as Map<String, dynamic>;
        } catch (e) {
          log('Error parsing JSON response in getLiveMatches: ${e.toString()}');
          throw Exception('Invalid JSON response from server');
        }

        // Check if matches data exists and is a list
        if (data.containsKey("matches") && data["matches"] is List) {
          List<dynamic> rawMatches = data["matches"] as List<dynamic>;

          for (dynamic matchData in rawMatches) {
            if (matchData is Map<String, dynamic>) {
              try {
                CreateMatchModel model = CreateMatchModel().fromMap(matchData);
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
      } else if (res.statusCode == 500) {
        throw Exception("Server Side Error In fetch live matches");
      } else {
        throw Exception(
          "Failed to fetch live matches - Status: ${res.statusCode}",
        );
      }
    } catch (e) {
      log('getLiveMatches error: ${e.toString()}');
      rethrow;
    }
  }

  /// Get match state from CompleteMatchResultModel stored in matchState field
  Future<CompleteMatchResultModel?> getLiveMatchesState(
    CreateMatchModel match,
  ) async {
    try {
      if (match.matchState == null || match.matchState!.trim().isEmpty) {
        return null;
      }

      // Parse the stored match state JSON
      Map<String, dynamic> matchStateData;
      try {
        matchStateData = jsonDecode(match.matchState!) as Map<String, dynamic>;
      } catch (e) {
        log('Error parsing match state JSON: ${e.toString()}');
        return null;
      }

      // Convert to CompleteMatchResultModel
      CompleteMatchResultModel matchResultModel = CompleteMatchResultModel()
          .fromMap(matchStateData);
      return matchResultModel;
    } catch (e) {
      log(
        'Error in getLiveMatchesState for match ${match.id}: ${e.toString()}',
      );
      return null;
    }
  }

  /// Get match result with matchId
  Future<CompleteMatchResultModel?> getMatchStateById(matchId) async {
    if (matchId == null) {
      log("match get failed - matchId is null");
      return null;
    }

    try {
      ApiServices services = ApiServices();
      Response res = await services.get(
        "/CL_Matches/GetMatchState?matchId=$matchId",
      );

      if (res.statusCode == 200) {
        // Parse JSON response body
        Map<String, dynamic> data;
        try {
          data = jsonDecode(res.body) as Map<String, dynamic>;
        } catch (e) {
          log(
            'Error parsing JSON response in getMatchStateById: ${e.toString()}',
          );
          return null;
        }

        if (data.containsKey("data") && data["data"] != null) {
          return CompleteMatchResultModel().fromJson(data["data"]);
        } else {
          log('No data field found in response');
          return null;
        }
      } else {
        log("Server error - Status: ${res.statusCode}");
        return null;
      }
    } catch (e) {
      log('Error in getMatchStateById: ${e.toString()}');
      return null;
    }
  }
}
