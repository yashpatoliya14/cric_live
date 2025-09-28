import 'package:cric_live/utils/import_exports.dart';

class CreateMatchRepo {
  final ApiServices _services = ApiServices();
  final ScoreboardRepository scoreboardRepo = ScoreboardRepository();

  /// create a match in locally
  Future<int> createMatch(MatchModel data) async {
    try {
      final Database db = await MyDatabase().database;
      return await db.insert(TBL_MATCHES, data.toMap());
    } catch (e) {
      log("$e");
      return -1;
    }
  }

  /// function is used for get match wherever ** use scheduled a match then this function is called **
  Future<MatchModel?> getMatchById(int matchId) async {
    try {
      // Check internet connection first
      bool hasInternet = await InternetRequiredService.checkForMatchCreation();
      if (!hasInternet) {
        return null; // User cancelled or still no internet
      }

      Map<String, dynamic> result = await _services.get(
        "/CL_Matches/GetMatchById/$matchId",
      );

      if (result["match"] != null) {
        return MatchModel.fromMap(result["match"]);
      } else {
        log("⚠️ match data missing in response: $result");
      }
    } catch (e) {
      log("⚠️ API request failed: $e");
    }
    return null;
  }

  createMatchOnline(MatchModel match) async {
    try {
      // Check internet connection first
      bool hasInternet = await InternetRequiredService.checkForMatchCreation();
      if (!hasInternet) {
        return; // User cancelled or still no internet
      }

      Map<String, dynamic> result = await _services.post(
        "/CL_Matches/CreateMatch",
        match.toMap(),
      );
      if (result["matchId"] != null) {
        return result["matchId"];
      } else {
        log("⚠️ matchId missing in response: $result");
      }
    } catch (e) {
      log("⚠️ API request failed: $e");
    }
  }

  int? getUidOfUser() {
    try {
      //fetch uid
      AuthService service = AuthService();
      TokenModel? tokenModel = service.fetchInfoFromToken();
      if (tokenModel == null) {
        throw Exception("userid is not found");
      }
      return tokenModel.uid;
    } catch (e, stackTrace) {
      log("token not found !!!!! $e and $stackTrace");
      return null;
    }
  }

  updateMatchOnline({required MatchModel model}) async {
    try {
      // Check internet connection first
      bool hasInternet = await InternetRequiredService.checkForMatchCreation();
      if (!hasInternet) {
        return; // User cancelled or still no internet
      }

      await _services.put(
        "/CL_Matches/UpdateMatch/${model.matchIdOnline}",
        model.toMap(),
      );
      log("match is updated");
    } catch (e) {
      log("Error in syncMatchUpdate");
      log(e.toString());
      if (e.toString().contains("Server Error")) {
        log("Server error");
      }
    }
  }
}
