import 'package:cric_live/features/signup_view/signup_model.dart';
import 'package:cric_live/services/auth/auth_service.dart';
import 'package:cric_live/services/auth/token_model.dart';
import 'package:cric_live/utils/import_exports.dart';

class CreateTeamRepo {
  Future<List<SignupModel>?> searchUser(String searchText) async {
    try {
      List<SignupModel> users = [];
      ApiServices apiServices = ApiServices();
      Response res = await apiServices.get("/CL_Users/SearchUser/$searchText");
      if (res.statusCode == 200) {
        Map<String, dynamic> data =
            jsonDecode(res.body) as Map<String, dynamic>;
        data["users"].forEach((user) {
          users.add(SignupModel.fromMap(user));
        });
        return users;
      }
    } catch (e) {
      log("search User error $e");
    }
  }

  Future<int?> createTeam(List<SignupModel> users, String teamName) async {
    try {
      ApiServices apiServices = ApiServices();
      AuthService authService = AuthService();
      TokenModel? user = await authService.fetchInfoFromToken();
      if (user == null) {
        throw Exception("User not found for create team");
      }
      Response res = await apiServices.post("/CL_Teams/CreateTeam", {
        "teamName": teamName,
        "uid": user.uid,
      });
      int? teamId;
      if (res.statusCode == 200) {
        Map<String, dynamic> data =
            jsonDecode(res.body) as Map<String, dynamic>;
        teamId = data["teamId"];
        for (SignupModel u in users) {
          Response res = await apiServices.post(
            "/CL_TeamPlayers/CreateTeamPlayer",
            {"teamId": teamId, "uid": u.uid},
          );

          if (res.statusCode == 200) {
            jsonDecode(res.body) as Map<String, dynamic>;
            log("craete team player success");
          } else if (res.statusCode == 500) {
            throw Exception("Server error from create team player");
          } else {
            throw Exception("Unexpected error from create team player");
          }
        }
        log("create team success");
        return teamId;
      } else if (res.statusCode == 500) {
        throw Exception("Server error from create team");
      } else {
        throw Exception("Unexpected error from create team");
      }
    } catch (e) {
      log("create team error $e");
    }
  }
}
