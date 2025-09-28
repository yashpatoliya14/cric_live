import 'package:cric_live/utils/import_exports.dart';

class CreateTournamentRepo {
  final ApiServices _apiServices = ApiServices();

  /// Create a new tournament and return tournament ID
  Future<int?> createTournament(CreateTournamentModel tournament) async {
    try {
      // Check internet connection first
      bool hasInternet =
          await InternetRequiredService.checkForTournamentCreation();
      if (!hasInternet) {
        return null; // User cancelled or still no internet
      }

      Map<String, dynamic> responseData = await _apiServices.post(
        "/CL_Tournaments/CreateTournament",
        tournament.toJson(),
      );

      log('Tournament created successfully');
      // Try to get tournament ID from response
      return responseData['tournamentId'] as int?;
    } catch (e, stacktrace) {
      log('Error creating tournament: ${e.toString()}...  $stacktrace');
      return null;
    }
  }

  /// Fetch all users for scorer selection (deprecated - use searchUsers instead)
  Future<List<UserModel>> getAllUsers() async {
    try {
      // Check internet connection first
      bool hasInternet =
          await InternetRequiredService.checkForTournamentCreation();
      if (!hasInternet) {
        return []; // User cancelled or still no internet
      }

      Map<String, dynamic> response = await _apiServices.get(
        "/CL_Users/GetAllUsers",
      );

      // Handle different response structures
      List<dynamic> data;
      if (response.containsKey('data') && response['data'] is List) {
        data = response['data'] as List<dynamic>;
      } else if (response is List) {
        data = response as List<dynamic>;
      } else {
        // If response is the list directly
        data = [response];
      }

      List<UserModel> users =
          data
              .map(
                (userData) =>
                    UserModel.fromJson(userData as Map<String, dynamic>),
              )
              .toList();

      log('Fetched ${users.length} users');
      return users;
    } catch (e) {
      log('Error fetching users: ${e.toString()}');
      if (e.toString().contains("Server Error")) {
        throw Exception("Server error while fetching users");
      }
      rethrow;
    }
  }

  /// Search users by query string
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      // Check internet connection first
      bool hasInternet =
          await InternetRequiredService.checkForTournamentCreation();
      if (!hasInternet) {
        return []; // User cancelled or still no internet
      }

      if (query.trim().isEmpty) {
        return []; // Return empty list for empty query
      }

      Map<String, dynamic> response = await _apiServices.get(
        "/CL_Users/SearchUser/${Uri.encodeComponent(query.trim())}",
      );

      // Handle different response structures
      List<dynamic> data;
      if (response.containsKey('data') && response['data'] is List) {
        data = response['data'] as List<dynamic>;
      } else if (response.containsKey('users') && response['users'] is List) {
        data = response['users'] as List<dynamic>;
      } else if (response is List) {
        data = response as List<dynamic>;
      } else if (response.containsKey('result') && response['result'] is List) {
        data = response['result'] as List<dynamic>;
      } else {
        // If response is the list directly
        data = [response];
      }

      List<UserModel> users =
          data
              .map(
                (userData) =>
                    UserModel.fromJson(userData as Map<String, dynamic>),
              )
              .toList();

      log('Found ${users.length} users for query: "$query"');
      return users;
    } catch (e) {
      log('Error searching users: ${e.toString()}');
      if (e.toString().contains("Server Error")) {
        throw Exception("Server error while searching users");
      }
      rethrow;
    }
  }

  /// Create tournament team association
  Future<bool> createTournamentTeam(TournamentTeamModel tournamentTeam) async {
    try {
      // Check internet connection first
      bool hasInternet =
          await InternetRequiredService.checkForTournamentCreation();
      if (!hasInternet) {
        return false; // User cancelled or still no internet
      }

      await _apiServices.post(
        "/CL_TournamentTeams/CreateTournamentTeam",
        tournamentTeam.toJson(),
      );

      log('Tournament team created successfully');
      return true;
    } catch (e) {
      log('Error creating tournament team: ${e.toString()}');
      if (e.toString().contains("Server Error")) {
        throw Exception("Server error while creating tournament team");
      }
      rethrow;
    }
  }
}
