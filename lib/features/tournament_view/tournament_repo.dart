import 'package:cric_live/utils/import_exports.dart';

class TournamentRepo {
  final ApiServices apiServices = ApiServices();
  final ScoreboardRepository _scoreboardRepo = ScoreboardRepository();

  Future<List<MatchModel>?> fetchTournamentMatches(int tournamentId) async {
    List<MatchModel> matches = [];
    try {
      log("Fetching matches for tournament ID: $tournamentId");
      Map<String, dynamic> data = await apiServices.get(
        "/CL_Matches/GetMatchesByTournamentId/$tournamentId",
      );
      log("API Response: $data");

      // Validate API response structure
      if (data["matches"] == null || data["matches"] is! List) {
        log(
          "Warning: Invalid API response structure. 'matches' field is missing or not a list.",
        );
        return [];
      }

      for (Map<String, dynamic> match in data["matches"]) {
        try {
          MatchModel matchModel = MatchModel.fromMap(match);
          matches.add(matchModel);
          log("Successfully created MatchModel for match ID: ${match['id']}");
        } catch (e) {
          log(
            "Error creating MatchModel for match ID: ${match['id']} - Error: $e",
          );
          log("Match data that caused error: $match");
          // Continue processing other matches instead of failing completely
        }
      }

      log(
        "Successfully processed ${matches.length} matches out of ${data['matches'].length} total matches",
      );
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

  /// NEW METHOD: Get tournament by specific tournament ID (not hostId)
  Future<TournamentModel?> getTournamentBySpecificId(int tournamentId) async {
    try {
      log("🎯 Fetching specific tournament with tournamentId: $tournamentId");
      
      // First, try to get tournaments by hostId and find the specific one
      // Since your API structure returns all tournaments for a host, we need to find the specific one
      // We can't determine the hostId from just tournamentId, so we'll need a different approach
      
      // Option 1: If you have an API endpoint that takes tournamentId directly, use it:
      // Map<String, dynamic> data = await apiServices.get("/CL_Tournaments/GetTournamentByTournamentId/$tournamentId");
      
      // Option 2: Since we don't have that endpoint, we need to search through all tournaments
      // For now, let's use the existing approach but filter by tournamentId
      
      // We can try to get all tournaments and filter (this is not efficient but will work)
      // However, since we don't know the hostId, we need to modify the API call
      
      // Actually, let's check if there's a direct endpoint first
      try {
        // Try direct tournament fetch (if this API exists)
        Map<String, dynamic> directData = await apiServices.get(
          "/CL_Tournaments/GetTournamentByTournamentId/$tournamentId",
        );
        log("🎯 Direct tournament API response: $directData");
        
        if (directData["tournaments"] != null && directData["tournaments"].isNotEmpty) {
          var tournamentData = directData["tournaments"][0];
          log("🏆 Creating TournamentModel from direct fetch: $tournamentData");
          return TournamentModel.fromMap(tournamentData);
        }
      } catch (directError) {
        log("⚠️ Direct tournament fetch failed: $directError");
        log("🔄 Falling back to search through host tournaments");
      }
      
      // Fallback: If direct fetch fails, we need to search through the tournaments returned by hostId
      // But we don't have hostId, so we'll make a reasonable assumption or use the search API
      
      // Get the tournament arguments to extract hostId if available
      final arguments = Get.arguments as Map<String, dynamic>?;
      int? hostIdFromArgs = arguments?['hostId'];
      
      if (hostIdFromArgs != null) {
        log("🏠 Using hostId from arguments: $hostIdFromArgs");
        Map<String, dynamic> data = await apiServices.get(
          "/CL_Tournaments/GetTournamentById/$hostIdFromArgs",
        );
        
        log("📋 Tournament search API response: $data");
        
        if (data["tournaments"] != null && data["tournaments"].isNotEmpty) {
          // Search for the specific tournament in the list
          List<dynamic> tournaments = data["tournaments"];
          
          for (var tournamentData in tournaments) {
            if (tournamentData['tournamentId'] == tournamentId) {
              log("✅ Found matching tournament: $tournamentData");
              return TournamentModel.fromMap(tournamentData);
            }
          }
          
          log("⚠️ Tournament with ID $tournamentId not found in host $hostIdFromArgs's tournaments");
        }
      }
      
      log("❌ No tournament found with ID: $tournamentId");
      return null;
      
    } catch (e) {
      log("❌ Error from getTournamentBySpecificId: $e");
      if (e.toString().contains("Server Error")) {
        throw Exception("Server error while fetching tournament");
      }
      rethrow;
    }
  }
}
