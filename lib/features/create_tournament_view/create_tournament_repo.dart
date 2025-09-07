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

  /// Fetch all users for scorer selection
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

  /// Create tournament team association
  Future<bool> createTournamentTeam(TournamentTeamModel tournamentTeam) async {
    try {
      // Check internet connection first
      bool hasInternet =
          await InternetRequiredService.checkForTournamentCreation();
      if (!hasInternet) {
        return false; // User cancelled or still no internet
      }

      Map<String, dynamic> response = await _apiServices.post(
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

  /// Get all tournament teams for team selection
  Future<List<TeamModel>> getAllTournamentTeams() async {
    try {
      // Check internet connection first
      bool hasInternet =
          await InternetRequiredService.checkForTournamentCreation();
      if (!hasInternet) {
        return []; // User cancelled or still no internet
      }

      ApiServices apiServices = ApiServices();
      Map<String, dynamic> response = await apiServices.get(
        "/CL_TournamentTeams/GetTournamentTeams",
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

      List<TeamModel> teams = [];

      for (dynamic teamData in data) {
        if (teamData is Map<String, dynamic>) {
          try {
            TeamModel team = TeamModel(
              id: teamData['teamId'] as int?,
              name: teamData['teamName'] as String?,
              shortName: teamData['teamShortName'] as String?,
            );
            teams.add(team);
          } catch (e) {
            log('Error parsing team data: ${e.toString()}');
            // Continue with other teams instead of failing completely
          }
        }
      }

      log('Fetched ${teams.length} tournament teams');
      return teams;
    } catch (e) {
      log('Error fetching tournament teams: ${e.toString()}');
      if (e.toString().contains("Server Error")) {
        throw Exception("Server error while fetching teams");
      }
      rethrow;
    }
  }
}
