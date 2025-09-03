import 'package:cric_live/utils/import_exports.dart';

class MatchViewRepo {
  Future<CompleteMatchResultModel?> getMatchState(int matchId) async {
    try {
      ApiServices apiServices = ApiServices();
      Response res = await apiServices.get(
        "/CL_Matches/GetMatchState?matchId=$matchId",
      );
      if (res.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(res.body);
        CompleteMatchResultModel matchState = CompleteMatchResultModel()
            .fromMap(jsonDecode(data["data"]));
        return matchState;
      } else if (res.statusCode == 500) {
        throw Exception("Server error !");
      } else {
        throw Exception("Unexpected error");
      }
    } catch (e) {
      rethrow;
    }
  }
}
