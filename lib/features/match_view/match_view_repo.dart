import 'package:cric_live/utils/import_exports.dart';

class MatchViewRepo {
  Future<CompleteMatchResultModel?> getMatchState(int matchId) async {
    try {
      ApiServices apiServices = ApiServices();
      Map<String, dynamic> data = await apiServices.get(
        "/CL_Matches/GetMatchState?matchId=$matchId",
      );

      CompleteMatchResultModel matchState = CompleteMatchResultModel().fromMap(
        jsonDecode(data["data"]),
      );
      return matchState;
    } catch (e) {
      if (e.toString().contains("Server Error")) {
        throw Exception("Server error !");
      }
      rethrow;
    }
  }
}
