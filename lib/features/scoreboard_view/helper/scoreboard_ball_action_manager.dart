import 'package:cric_live/utils/import_exports.dart';

class ScoreboardBallActionManager extends ScoreboardInningsManager {
  final ScoreboardRepo _repo;
  ScoreboardBallActionManager(ScoreboardRepo repo, int matchId)
    : _repo = repo,
      super(repo, matchId);

  Future<void> onTapRun({runs}) async {
    try {
      if (await isInningFinished()) {
        return;
      }
      if (await isOverCompleted()) {
        changeBowler(
          currentBatsmanTeamId.value == team1Id.value
              ? team2Id.value
              : team1Id.value,
        );
        return;
      }
      int? isWideLocal = null;
      int? isNoBallLocal = null;
      int? isByeLocal = null;
      if (isNoBallSelected.value) {
        runs += noBallRun;
        isNoBallLocal = 1;
      }
      if (isWideSelected.value) {
        runs += wideRun;
        isWideLocal = 1;
      }

      if (isByeSelected.value) {
        isByeLocal = 1;
      }
      ScoreboardModel data = ScoreboardModel(
        strikerBatsmanId: strikerBatsmanId.value,
        nonStrikerBatsmanId: nonStrikerBatsmanId.value,
        bowlerId: bowlerId.value,
        matchId: matchId,
        inningNo: inningNo.value,
        isStored: 0,
        currentOvers: currentOvers.value,
        runs: runs,
        totalOvers: totalOvers.value,
        isNoBall: isNoBallLocal,
        isWide: isWideLocal,
        isBye: isByeLocal,
      );
      _repo.addBallEntry(data);
      isWideSelected.value = false;
      isNoBallSelected.value = false;
      isByeSelected.value = false;

      // Calculate in proper order to avoid conflicts
      await calculateRuns();
      await calculateCurrentOvers();
      await calculateBowler();
      await calculateBatsman(); // Add batsman calculation
      await calculateOversState(); // AWAIT this call!

      if ([1, 3, 5].contains(runs)) {
        onTapSwap();
      }
    } catch (e) {
      log(
        ":::: Error at add data entry from local-database in tap run :::: \n $e",
      );
    }
  }

  Future<void> onTapWicket({required String wicketType}) async {
    try {
      if (await isInningFinished()) {
        return;
      }
      if (await isOverCompleted()) {
        changeBowler(
          currentBatsmanTeamId.value == team1Id.value
              ? team2Id.value
              : team1Id.value,
        );
        return;
      }
      ScoreboardModel data = ScoreboardModel(
        strikerBatsmanId: strikerBatsmanId.value,
        nonStrikerBatsmanId: nonStrikerBatsmanId.value,
        bowlerId: bowlerId.value,
        matchId: matchId,
        inningNo: inningNo.value,
        isStored: 0,
        currentOvers: currentOvers.value,
        totalOvers: totalOvers.value,
        isWicket: 1,
        wicketType: wicketType,
      );
      final dynamic result = await Get.toNamed(
        NAV_CHOOSE_PLAYER,
        arguments: {'teamId': matchModel.currentBattingTeamId, 'limit': 1},
      );

      if (result != null && result is List && result.isNotEmpty) {
        final players = result.cast<ChoosePlayerModel>();
        strikerBatsman.value = players[0].playerName?.toString() ?? "Unknown";
        strikerBatsmanId.value = players[0].teamPlayerId ?? 0;
      }

      _repo.addBallEntry(data);

      await calculateWicket();
      await calculateOversState();
    } catch (e) {
      log(
        ":::: Error at add data entry from local-database in tap wicket :::: \n $e",
      );
    }
  }

  Future<void> onTapRetire({required String wicketType}) async {
    try {
      if (await isInningFinished()) {
        return;
      }
      if (await isOverCompleted()) {
        changeBowler(
          currentBatsmanTeamId.value == team1Id.value
              ? team2Id.value
              : team1Id.value,
        );
        return;
      }
      ScoreboardModel data = ScoreboardModel(
        strikerBatsmanId: strikerBatsmanId.value,
        nonStrikerBatsmanId: nonStrikerBatsmanId.value,
        bowlerId: bowlerId.value,
        matchId: matchId,
        inningNo: inningNo.value,
        isStored: 0,
        currentOvers: currentOvers.value,
        totalOvers: totalOvers.value,
        isWicket: 0,
        wicketType: wicketType,
      );
      final dynamic result = await Get.toNamed(
        NAV_CHOOSE_PLAYER,
        arguments: {'teamId': matchModel.currentBattingTeamId, 'limit': 1},
      );

      if (result != null && result is List && result.isNotEmpty) {
        final players = result.cast<ChoosePlayerModel>();
        strikerBatsman.value = players[0].playerName?.toString() ?? "Unknown";
        strikerBatsmanId.value = players[0].teamPlayerId ?? 0;
      }

      _repo.addBallEntry(data);

      await calculateWicket();
      await calculateOversState();
    } catch (e) {
      log(
        ":::: Error at add data entry from local-database in tap retire :::: \n $e",
      );
    }
  }

  Future<void> onTapWide() async {
    try {
      if (await isInningFinished()) {
        return;
      }
      ScoreboardModel data = ScoreboardModel(
        strikerBatsmanId: strikerBatsmanId.value,
        nonStrikerBatsmanId: nonStrikerBatsmanId.value,
        bowlerId: bowlerId.value,
        matchId: matchId,
        inningNo: inningNo.value,
        isStored: 0,
        currentOvers: currentOvers.value,
        totalOvers: totalOvers.value,
        isWide: isWide,
        runs: wideRun,
      );
      _repo.addBallEntry(data);
      await calculateRuns();
      await calculateCurrentOvers();
      await calculateBowler();
      await calculateOversState();
    } catch (e) {
      log(
        ":::: Error at add data entry from local-database in tap Wide :::: \n $e",
      );
    }
  }

  Future<void> onTapNoBall() async {
    try {
      if (await isInningFinished()) {
        return;
      }
      ScoreboardModel data = ScoreboardModel(
        strikerBatsmanId: strikerBatsmanId.value,
        nonStrikerBatsmanId: nonStrikerBatsmanId.value,
        matchId: matchId,
        inningNo: inningNo.value,
        bowlerId: bowlerId.value,
        isStored: 0,
        currentOvers: currentOvers.value,
        totalOvers: totalOvers.value,
        isNoBall: isNoBall,
        runs: noBallRun,
      );
      _repo.addBallEntry(data);
      await calculateRuns();
      await calculateCurrentOvers();
      await calculateBowler();
      await calculateOversState();
    } catch (e) {
      log(
        ":::: Error at add data entry from local-database in tap no ball :::: \n $e",
      );
    }
  }

  Future<void> undoBall() async {
    ScoreboardModel? lastEntry = await _repo.undoBall();

    // Recalculate all stats after undo
    await calculateRuns();
    await calculateWicket();
    await calculateCurrentOvers();
    await calculateBowler();
    await calculateBatsman();
    await calculateOversState();

    if (lastEntry == null) {
      return;
    }

    strikerBatsmanId.value = lastEntry.strikerBatsmanId ?? 11111;
    nonStrikerBatsmanId.value = lastEntry.nonStrikerBatsmanId ?? 11111;
    bowlerId.value = lastEntry.bowlerId ?? 11111;
    strikerBatsman.value = await _repo.getPlayerName(strikerBatsmanId.toInt());
    nonStrikerBatsman.value = await _repo.getPlayerName(
      nonStrikerBatsmanId.toInt(),
    );
    bowler.value = await _repo.getPlayerName(bowlerId.toInt());
  }

  void onTapSwap() async {
    if (await isInningFinished()) {
      return;
    }
    // Swap names
    String tempName = strikerBatsman.value;
    strikerBatsman.value = nonStrikerBatsman.value;
    nonStrikerBatsman.value = tempName;

    // Swap IDs
    int tempId = strikerBatsmanId.value;
    strikerBatsmanId.value = nonStrikerBatsmanId.value;
    nonStrikerBatsmanId.value = tempId;

    // Recalculate each batsman’s stats separately
    strikerBatsmanState.value = await _repo.calculateBatsman(
      strikerBatsmanId.toInt(),
    );
    nonStrikerBatsmanState.value = await _repo.calculateBatsman(
      nonStrikerBatsmanId.toInt(),
    );
  }
}
