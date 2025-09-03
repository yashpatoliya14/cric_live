import 'package:cric_live/utils/import_exports.dart';

class TournamentRepo {
  final ApiServices apiServices = ApiServices();
  Future<List<CreateMatchModel>?> fetchTournamentMatches(
    int tournamentId,
  ) async {
    List<CreateMatchModel> matches = [];
    try {
      Response res = await apiServices.get(
        "/CL_Matches/GetMatchesByTournamentId/$tournamentId",
      );

      if (res.statusCode == 200) {
        Map<String, dynamic> data =
            jsonDecode(res.body) as Map<String, dynamic>;
        data["matches"].forEach((match) {
          matches.add(CreateMatchModel().fromMap(match));
        });
      } else if (res.statusCode == 500) {
        throw Exception("Server error");
      } else {
        throw Exception("Unexpected Error");
      }

      return matches;
    } catch (e) {
      log("from fetchMatches");
      log(e.toString());
    }
  }
}
