import 'package:cric_live/utils/import_exports.dart';

class ScoreboardState extends GetxController {
  // Local Variables
  late int matchId;
  late CreateMatchModel matchModel;
  int isNoBall = 0;
  int isWide = 0;
  int wideRun = 0;
  int noBallRun = 0;
  int inningId = 0;

  // Match-level state
  final RxInt totalOvers = 0.obs;
  final RxInt inningNo = 1.obs;
  final RxInt totalRuns = 0.obs;
  final RxInt wickets = 0.obs;
  final RxDouble currentOvers = 0.1.obs;
  final RxDouble CRR = 0.0.obs;

  // Team state
  final RxString team1 = "Team A".obs;
  final RxString team2 = "Team B".obs;
  final RxInt team1Id = 0.obs;
  final RxInt team2Id = 0.obs;
  final RxInt currentBatsmanTeamId = 0.obs;

  // Player state
  final RxString bowler = "".obs;
  final RxInt bowlerId = 0.obs;
  final RxString nonStrikerBatsman = "".obs;
  final RxInt nonStrikerBatsmanId = 0.obs;
  final RxString strikerBatsman = "".obs;
  final RxInt strikerBatsmanId = 0.obs;

  // Player statistics
  final RxMap<String, double> nonStrikerBatsmanState = <String, double>{}.obs;
  final RxMap<String, double> strikerBatsmanState = <String, double>{}.obs;
  final RxMap<String, double> bowlerState = <String, double>{}.obs;
  final RxMap<String, dynamic> oversState = <String, dynamic>{}.obs;

  // UI state
  final RxBool isWideSelected = false.obs;
  final RxBool isByeSelected = false.obs;
  final RxBool isNoBallSelected = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = "".obs;

  ScoreboardState({required this.matchId});

  void resetAll() {
    // Reset local variables
    isNoBall = 0;
    isWide = 0;
    wideRun = 0;
    noBallRun = 0;
    inningId = 0;

    // Reset reactive variables
    totalOvers.value = 0;
    inningNo.value = 1;
    totalRuns.value = 0;
    wickets.value = 0;
    currentOvers.value = 0.1;
    CRR.value = 0.0;

    team1.value = "Team A";
    team2.value = "Team B";
    team1Id.value = 0;
    team2Id.value = 0;
    currentBatsmanTeamId.value = 0;

    bowler.value = "";
    bowlerId.value = 0;
    nonStrikerBatsman.value = "";
    nonStrikerBatsmanId.value = 0;
    strikerBatsman.value = "";
    strikerBatsmanId.value = 0;

    nonStrikerBatsmanState.clear();
    strikerBatsmanState.clear();
    bowlerState.clear();
    oversState.clear();

    isWideSelected.value = false;
    isByeSelected.value = false;
    isNoBallSelected.value = false;
    isLoading.value = false;
    errorMessage.value = "";
  }
}
