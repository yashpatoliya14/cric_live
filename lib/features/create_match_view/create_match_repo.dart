import 'package:cric_live/utils/import_exports.dart';

class CreateMatchRepo extends ScoreboardRepo {
  /// create a match in locally
  Future<int> createMatch(CreateMatchModel data) async {
    try {
      Database db = await MyDatabase().database;
      return await db.insert(TBL_MATCHES, data.toMap());
    } catch (e) {
      log("$e");
      return -1;
    }
  }

  Future<CreateMatchModel?> getMatchById(int matchId) async {
    ApiServices services = ApiServices();
    try {
      Response res = await services.get("/CL_Matches/GetMatchById/$matchId");
      if (res.statusCode == 200) {
        Map<String, dynamic> result = jsonDecode(res.body);

        log(result["match"].toString());

        if (result["match"] != null) {
          return CreateMatchModel().fromMap(result["match"]);
        } else {
          log("⚠️ matchId missing in response: ${res.body}");
        }
      }
    } catch (e) {
      log("⚠️ JSON decode failed: $e");
    }
    return null;
  }

  createMatchOnline(CreateMatchModel match) async {
    ApiServices services = ApiServices();
    log(match.toMap().toString());
    Response res = await services.post(
      "/CL_Matches/CreateMatch",
      match.toMap(),
    );
    if (res.statusCode == 200) {
      try {
        Map<String, dynamic> result =
            jsonDecode(res.body) as Map<String, dynamic>;
        log(result.toString());
        if (result["matchId"] != null) {
          return result["matchId"];
        } else {
          log("⚠️ matchId missing in response: ${res.body}");
        }
      } catch (e) {
        log("⚠️ JSON decode failed: ${res.body}");
      }
    }
  }

  Future<void> updateMatchOnline({required CreateMatchModel model}) async {
    try {
      log(
        "::::::::::::::::::::::::::::::::::::::::::::::::::::;update match ${model.toMap()}",
      );
      ApiServices _services = ApiServices();
      final res = await _services.put(
        "/CL_Matches/UpdateMatch/${model.matchIdOnline}",
        model.toMap(),
      );
      if (res.statusCode == 200) {
        log(
          "Success to update a match details :::::::::::::::::::::::::::::UPDATE MATCH",
        );
      } else if (res.statusCode == 500) {
        log("Server error");
      } else {
        throw Exception("Unexpected error");
      }
    } catch (e) {
      log("Error in syncMatchUpdate");
      log(e.toString());
    }
  }
}
