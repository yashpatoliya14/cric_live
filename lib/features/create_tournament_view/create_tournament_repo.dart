import 'package:cric_live/features/create_tournament_view/create_tournament_model.dart';
import 'package:cric_live/features/create_tournament_view/models/user_model.dart';
import 'package:cric_live/features/dashboard_view/models/team_model.dart';
import 'package:cric_live/utils/import_exports.dart';

class CreateTournamentRepo {
  /// Create a new tournament and return tournament ID
  Future<int?> createTournament(CreateTournamentModel tournament) async {
    try {
      ApiServices apiServices = ApiServices();
      Response res = await apiServices.post(
        "/CL_Tournaments/CreateTournament",
        tournament.toJson(),
      );

      if (res.statusCode == 200) {
        log('Tournament created successfully');
        // Try to get tournament ID from response
        try {
          Map<String, dynamic> responseData = jsonDecode(res.body);
          return responseData['tournamentId'] as int?;
        } catch (e) {
          log('Could not parse tournament ID from response: $e');
          return null;
        }
      } else if (res.statusCode == 500) {
        throw Exception("Server error while creating tournament");
      } else {
        throw Exception(
          "Failed to create tournament - Status: ${res.statusCode}",
        );
      }
    } catch (e) {
      log('Error creating tournament: ${e.toString()}');
      rethrow;
    }
  }

  /// Fetch all users for scorer selection
  Future<List<UserModel>> getAllUsers() async {
    try {
      ApiServices apiServices = ApiServices();
      Response res = await apiServices.get("/CL_Users/GetAllUsers");

      if (res.statusCode == 200) {
        List<dynamic> data = jsonDecode(res.body);
        List<UserModel> users =
            data
                .map(
                  (userData) =>
                      UserModel.fromJson(userData as Map<String, dynamic>),
                )
                .toList();

        log('Fetched ${users.length} users');
        return users;
      } else if (res.statusCode == 500) {
        throw Exception("Server error while fetching users");
      } else {
        throw Exception("Failed to fetch users - Status: ${res.statusCode}");
      }
    } catch (e) {
      log('Error fetching users: ${e.toString()}');
      rethrow;
    }
  }

  /// Create tournament team association
  Future<bool> createTournamentTeam(TournamentTeamModel tournamentTeam) async {
    try {
      ApiServices apiServices = ApiServices();
      Response res = await apiServices.post(
        "/CL_TournamentTeams/CreateTournamentTeam",
        tournamentTeam.toJson(),
      );

      if (res.statusCode == 200) {
        log('Tournament team created successfully');
        return true;
      } else if (res.statusCode == 500) {
        throw Exception("Server error while creating tournament team");
      } else {
        throw Exception(
          "Failed to create tournament team - Status: ${res.statusCode}",
        );
      }
    } catch (e) {
      log('Error creating tournament team: ${e.toString()}');
      rethrow;
    }
  }

  /// Get all tournament teams for team selection
  Future<List<TeamModel>> getAllTournamentTeams() async {
    try {
      ApiServices apiServices = ApiServices();
      Response res = await apiServices.get(
        "/CL_TournamentTeams/GetTournamentTeams",
      );

      if (res.statusCode == 200) {
        List<dynamic> data = jsonDecode(res.body);
        List<TeamModel> teams = [];

        for (dynamic teamData in data) {
          if (teamData is Map<String, dynamic>) {
            try {
              TeamModel team = TeamModel(
                id: teamData['teamId'] as int?,
                name: teamData['teamName'] as String?,
                shortName: teamData['teamShortName'] as String?,
                logo: teamData['teamLogo'] as String?,
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
      } else if (res.statusCode == 500) {
        throw Exception("Server error while fetching teams");
      } else {
        throw Exception("Failed to fetch teams - Status: ${res.statusCode}");
      }
    } catch (e) {
      log('Error fetching tournament teams: ${e.toString()}');
      rethrow;
    }
  }
}
