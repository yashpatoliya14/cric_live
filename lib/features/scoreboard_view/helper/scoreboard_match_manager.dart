import 'package:cric_live/utils/import_exports.dart';

class ScoreboardMatchManager extends ScoreboardState {
  final ScoreboardRepo _repo;

  ScoreboardMatchManager(this._repo, matchId) : super(matchId: matchId);

  Future<void> initializeMatch(int matchId) async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      await findMatch(matchId);
      await _refreshAllData();
    } catch (e) {
      errorMessage.value = "Failed to initialize match: ${e.toString()}";
      log('Error initializing ScoreboardController: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> findMatch(int matchId) async {
    final foundMatch = await _repo.findMatch(matchId);

    matchModel = foundMatch;
    totalOvers.value = matchModel.overs ?? 0;
    inningNo.value = matchModel.inningNo ?? 0;
    wideRun = matchModel.wideRun ?? 0;
    noBallRun = matchModel.noBallRun ?? 0;
    currentBatsmanTeamId.value = matchModel.currentBattingTeamId ?? 0;
    team1Id.value = matchModel.team1 ?? 0;
    team2Id.value = matchModel.team2 ?? 0;
    isWide = matchModel.wideRun == 0 ? 0 : 1;
    isNoBall = matchModel.noBallRun == 0 ? 0 : 1;

    // Validate essential data
    if (team1Id.value == 0 || team2Id.value == 0) {
      throw Exception('Invalid team data in match');
    }

    // Fetch and set team names
    await _setTeamName(team1Id.value, team1);
    await _setTeamName(team2Id.value, team2);

    // Fetch and set player names + IDs
    await _setPlayerInfo(
      playerId: matchModel.strikerBatsmanId ?? 0,
      nameRx: strikerBatsman,
      idRx: strikerBatsmanId,
    );

    await _setPlayerInfo(
      playerId: matchModel.nonStrikerBatsmanId ?? 0,
      nameRx: nonStrikerBatsman,
      idRx: nonStrikerBatsmanId,
    );

    await _setPlayerInfo(
      playerId: matchModel.bowlerId ?? 0,
      nameRx: bowler,
      idRx: bowlerId,
    );

    // update a status
    matchModel.status = 'live';
    await _repo.updateMatch(matchModel);
    SyncFeature syncFeature = SyncFeature();
    syncFeature.checkConnectivity(
      () async => await syncFeature.syncMatchUpdate(matchId: matchId),
    );
  }

  /// Helper: Set team name by teamId
  Future<void> _setTeamName(int teamId, RxString teamRx) async {
    teamRx.value = await _repo.getTeamName(teamId);
    teamRx.refresh();
  }

  /// Helper: Set player name + ID
  Future<void> _setPlayerInfo({
    required int playerId,
    required RxString nameRx,
    required RxInt idRx,
  }) async {
    idRx.value = playerId;
    nameRx.value = await _repo.getPlayerName(playerId);
  }

  /// Refresh all match data
  Future<void> _refreshAllData() async {
    // await _calculations.calculateRuns();
    // await calculateWicket();
    // await getCurrentOvers();
    // await calculateBowler();
    // await calculateBatsman();
    // getOversState();
  }
}
