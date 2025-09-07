import 'package:cric_live/utils/import_exports.dart';

class CreateMatchController extends GetxController {
  final CreateMatchRepo _repo = CreateMatchRepo();
  final SelectTeamRepo _selectTeamRepo = SelectTeamRepo();

  //variables
  int? tournamentId;
  int? matchIdOnline;

  //Rx variables
  var isReady = false.obs;
  var team1 = {}.obs;
  var team2 = {}.obs;
  RxList<PlayerModel> batsmanList = <PlayerModel>[].obs;
  RxList<PlayerModel> bowlerList = <PlayerModel>[].obs;

  RxString tossWinnerTeam = TEAM_A.obs;
  RxString batOrBowl = BAT.obs;
  RxInt overs = 0.obs;

  RxBool isNoBall = false.obs;
  RxBool isWide = false.obs;

  RxInt noBallRun = 1.obs;
  RxInt wideRun = 1.obs;

  RxString bowler = "".obs;
  RxInt bowlerId = 012345.obs;

  RxString nonStrikerBatsman = "".obs;
  RxInt nonStrikerBatsmanId = 123456.obs;

  RxString strikerBatsman = "".obs;
  RxInt strikerBatsmanId = 123456.obs;

  TextEditingController controllerOvers = TextEditingController();
  TextEditingController controllerNoBallRun = TextEditingController();
  TextEditingController controllerWideRun = TextEditingController();
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    everAll([batsmanList, bowlerList], (_) {
      isReady.value = batsmanList.length == 2 && bowlerList.isNotEmpty;
    });

    // Check if we are starting a scheduled match
    if (Get.arguments != null && Get.arguments['matchId'] != null) {
      final int matchId = Get.arguments['matchId'];
      matchIdOnline = matchId;
      loadScheduledMatch(matchId);
    }
    tournamentId = (Get.arguments as Map?)?["tournamentId"];

    controllerWideRun.text = '0';
    controllerNoBallRun.text = '0';
    controllerOvers.text = '2';
  }

  Future<void> loadScheduledMatch(int matchId) async {
    CreateMatchModel? match = await _repo.getMatchById(matchId);
    if (match != null) {
      controllerOvers.text = match.overs.toString();
      controllerNoBallRun.text = match.noBallRun.toString();
      controllerWideRun.text = match.wideRun.toString();

      //fetch values
      team1["teamId"] = match.team1?.toInt();
      team2["teamId"] = match.team2?.toInt();
      team1["teamName"] = await _repo.scoreboardRepo.getTeamNameOnline(
        match.team1 ?? -1,
      );
      team2["teamName"] = await _repo.scoreboardRepo.getTeamNameOnline(
        match.team2 ?? -1,
      );
      tournamentId = match.tournamentId;
    }
  }

  /// Set team 1 and update toss winner to Team A by default
  void setTeam1(Map<String, dynamic> teamData) {
    team1.assignAll(teamData);
    // Set toss winner to Team A (team1) by default
    tossWinnerTeam.value = teamData['teamName'] ?? TEAM_A;

    // Clear selected players when team changes
    _clearSelectedPlayers();
  }

  /// Set team 2
  void setTeam2(Map<String, dynamic> teamData) {
    team2.assignAll(teamData);

    // If no toss winner set yet, default to Team A
    if (tossWinnerTeam.value == TEAM_A && team1.isNotEmpty) {
      tossWinnerTeam.value = team1['teamName'];
    }

    // Clear selected players when team changes
    _clearSelectedPlayers();
  }

  /// Clear selected players when teams change
  void _clearSelectedPlayers() {
    batsmanList.clear();
    bowlerList.clear();
    strikerBatsman.value = "";
    nonStrikerBatsman.value = "";
    bowler.value = "";
    strikerBatsmanId.value = 123456;
    nonStrikerBatsmanId.value = 123456;
    bowlerId.value = 012345;
  }

  onTossWinnerTeamChanged(value) {
    if (value != null) {
      tossWinnerTeam.value = value;
    }
  }

  onbatOrBowlChanged(value) {
    if (value != null) {
      batOrBowl.value = value;
    }
  }

  onNoBallChanged(value) {
    if (value != null) {
      isNoBall.value = value;
    }
  }

  onWideChanged(value) {
    if (value != null) {
      isWide.value = value;
    }
  }

  bool isBatsmanTeam(team) {
    if (tossWinnerTeam.value == team['teamName'] && batOrBowl.value == BAT) {
      return true;
    } else if (tossWinnerTeam.value != team['teamName'] &&
        batOrBowl.value == BOWL) {
      return true;
    }
    return false;
  }

  /// Validate all match requirements before starting
  // Add this new validation method inside your CreateMatchController
  String? validatePreTossSettings() {
    if (team1.isEmpty || team1['teamId'] == null) {
      return "Please select Team 1";
    }
    if (team2.isEmpty || team2['teamId'] == null) {
      return "Please select Team 2";
    }
    if (team1['teamId'] == team2['teamId']) {
      return "Teams must be different. Please select different teams.";
    }
    if (controllerOvers.text.isEmpty) {
      return "Please enter number of overs";
    }
    int? overs = int.tryParse(controllerOvers.text);
    if (overs == null || overs <= 0 || overs > 50) {
      return "Please enter a valid number of overs (1-50)";
    }
    return null; // All good
  }

  onCreateMatch({required bool isScheduled}) async {
    // Run validation first
    String? validationError = validatePreTossSettings();

    if (validationError != null) {
      Get.snackbar(
        "Validation Error",
        validationError,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    // Clear any existing ScoreboardController instances to prevent conflicts
    try {
      Get.delete<ScoreboardController>();
    } catch (e) {
      log('No existing ScoreboardController instances to clear: $e');
    }

    CreateMatchModel data = CreateMatchModel(
      matchIdOnline: matchIdOnline,
      matchDate: DateTime.now(),
      inningNo: 1,
      overs: int.parse(controllerOvers.text),
      noBallRun: int.parse(controllerNoBallRun.text),
      wideRun: int.parse(controllerWideRun.text),
      status: "scheduled",
      tossWon:
          tossWinnerTeam.value == team1['teamId']
              ? team1['teamId']
              : team2['teamId'],
      team1: team1['teamId'],
      team2: team2['teamId'],
      currentBattingTeamId:
          isBatsmanTeam(team1) ? team1['teamId'] : team2['teamId'],
      strikerBatsmanId: strikerBatsmanId.value,
      nonStrikerBatsmanId: nonStrikerBatsmanId.value,
      bowlerId: bowlerId.value,
      tournamentId: tournamentId,
    );

    // fetch uid
    AuthService service = AuthService();
    TokenModel? tokenModel = service.fetchInfoFromToken();
    if (tokenModel == null) {
      throw Exception("userid is not found");
    }
    data.uid = tokenModel.uid ?? -1;

    // first it create match in database
    matchIdOnline = await _repo.createMatchOnline(data);
    if (matchIdOnline == null) {
      Get.snackbar("Match Is Not Created", "Please Try Again");
      return;
    } else {
      data.matchIdOnline = matchIdOnline;
    }

    if (tournamentId != null || isScheduled) {
      Get.back();
    } else {
      Get.toNamed(NAV_TOSS_DECISION, arguments: {"matchId": matchIdOnline});
    }
  }

  startMatch() async {
    CreateMatchModel data = CreateMatchModel(
      matchIdOnline: matchIdOnline,
      matchDate: DateTime.now(),
      inningNo: 1,
      overs: int.parse(controllerOvers.text),
      noBallRun: int.parse(controllerNoBallRun.text),
      wideRun: int.parse(controllerWideRun.text),
      status: "live",
      tossWon:
          tossWinnerTeam.value == team1['teamId']
              ? team1['teamId']
              : team2['teamId'],
      team1: team1['teamId'],
      team2: team2['teamId'],
      currentBattingTeamId:
          isBatsmanTeam(team1) ? team1['teamId'] : team2['teamId'],
      strikerBatsmanId: batsmanList[0].teamPlayerId,
      nonStrikerBatsmanId: batsmanList[1].teamPlayerId,
      bowlerId: bowlerList[0].teamPlayerId,
      tournamentId: tournamentId,
      uid: _repo.getUidOfUser(),
    );

    //update a match in online
    await _repo.updateMatchOnline(model: data);

    // set up local database
    await _selectTeamRepo.getAllTeams(wantToStore: true);
    int? localMatchId = await _repo.createMatch(data);

    Get.toNamed(NAV_SCOREBOARD, arguments: {"matchId": localMatchId});
  }

  Future<void> selectBatsman() async {
    // Validate teams are selected first
    if (team1.isEmpty || team2.isEmpty) {
      Get.snackbar(
        "Teams Required",
        "Please select both teams before choosing players",

        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    int battingTeamId =
        isBatsmanTeam(team1) ? team1['teamId'] : team2['teamId'];

    List<PlayerModel> batters = await Get.toNamed(
      NAV_CHOOSE_PLAYER,
      arguments: {"teamId": battingTeamId, "limit": 2},
    );

    if (batters.length < 2) {
      return;
    }

    // Update the batsman list
    batsmanList.value = batters;

    strikerBatsmanId.value = batters[0].teamPlayerId ?? 0;
    nonStrikerBatsmanId.value = batters[1].teamPlayerId ?? 0;
    strikerBatsman.value = batters[0].playerName ?? "";
    nonStrikerBatsman.value = batters[1].playerName ?? "";
  }

  Future<void> selectBowler() async {
    // Validate teams are selected first
    if (team1.isEmpty || team2.isEmpty) {
      Get.snackbar(
        "Teams Required",
        "Please select both teams before choosing players",

        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    int bowlingTeamId =
        isBatsmanTeam(team1) ? team2['teamId'] : team1['teamId'];
    String bowlingTeamName =
        isBatsmanTeam(team1) ? team2['teamName'] : team1['teamName'];

    List<PlayerModel> bowlers = await Get.toNamed(
      NAV_CHOOSE_PLAYER,
      arguments: {"teamId": bowlingTeamId, "limit": 1},
    );

    if (bowlers.isEmpty) {
      Get.snackbar(
        "Selection Required",
        "Please select 1 bowler from $bowlingTeamName to continue.",

        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Update the bowler list
    bowlerList.value = bowlers;

    bowlerId.value = bowlers[0].teamPlayerId ?? 0;
    bowler.value = bowlers[0].playerName ?? "";
  }
}
