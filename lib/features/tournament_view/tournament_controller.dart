import 'package:cric_live/features/create_match_view/create_match_repo.dart';
import 'package:cric_live/features/tournament_view/tournament_repo.dart';
import 'package:cric_live/utils/import_exports.dart';

class TournamentController extends GetxController {
  //RxVariables
  RxList<CreateMatchModel> matches = <CreateMatchModel>[].obs;
  //local variables
  late int tournamentId;
  final TournamentRepo _repo = TournamentRepo();
  final CreateMatchRepo _createMatchRepo = CreateMatchRepo();
  final SelectTeamRepo _selectTeamRepo = SelectTeamRepo();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    tournamentId = Get.arguments["tournamentId"];

    _initializedData();
  }

  _initializedData() async {
    matches.value = await _repo.fetchTournamentMatches(tournamentId) ?? [];
    log("matches  :::::::::::::::::$matches");
  }

  startMatch(CreateMatchModel match) async {
    // dynamic tempMatch = match.toMap();
    // tempMatch.remove("team1Name");
    // tempMatch.remove("team2Name");
    // log(tempMatch.toString());
    // log(":::::::::::::::::::::::::::");
    // tempMatch = CreateMatchModel().fromMap(tempMatch);
    // int localMatchId = await _createMatchRepo.createMatch(tempMatch);
    // _selectTeamRepo.getAllTeams(
    //   wantToStore: true,
    //   tournamentId: match.tournamentId,
    // );
    Get.toNamed(NAV_TOSS_DECISION, arguments: {"matchId": match.id});
  }

  tempFetch() {
    _initializedData();
  }
}
