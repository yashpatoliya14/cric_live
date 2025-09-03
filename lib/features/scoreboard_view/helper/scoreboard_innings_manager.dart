import 'package:cric_live/utils/import_exports.dart';

class ScoreboardInningsManager extends ScoreboardCalculation {
  final ScoreboardRepo _repo;

  ScoreboardInningsManager(this._repo, matchId) : super(_repo, matchId);

  /// is inning finished

  Future<bool> isInningFinished() async {
    bool result = await _repo.isInningFinished(
      matchId,
      inningNo.value,
      totalOvers.value,
    );

    if (result && inningNo.value == 1) {
      getDialogBox(
        onMain: onTapMainButton,
        title: "Start 2nd Inning",
        closeText: "Later",
        mainText: "Start",
      );
      return result;
    } else if (result && inningNo.value == 2) {
      getDialogBox(
        onMain: onTapMainButton,
        title: "End Match",
        closeText: "Later",
        mainText: "End",
      );
      return result;
    }
    return result;
  }

  Future<bool> isOverCompleted() async {
    final overState = await _repo.getCurrentOverState(
      matchId: matchId,
      inningNo: inningNo.value,
      bowlerId: bowlerId.value,
    );

    // Use ballCount instead of ballSequence.length to avoid counting wides/no-balls
    return (overState['ballCount'] as int?) == 6 ||
        (overState['isOverComplete'] as bool?) == true;
  }

  /// Change player
  Future<void> changeBowler(int teamId) async {
    final dynamic result = await Get.toNamed(
      NAV_CHOOSE_PLAYER,
      arguments: {'teamId': teamId, 'limit': 1},
    );

    if (result != null && result is List && result.isNotEmpty) {
      final players = result.cast<ChoosePlayerModel>();
      // Update bowler info
      bowlerId.value = players[0].teamPlayerId ?? bowlerId.value;
      bowler.value = players[0].playerName ?? bowler.value;

      // Ensure all calculations are synchronized after bowler change
      await _synchronizeAfterBowlerChange();
    }
    // _ballActionManager?.onTapSwap();
  }

  /// Synchronize all calculations after bowler change
  Future<void> _synchronizeAfterBowlerChange() async {
    // Calculate in proper order to avoid conflicts
    await calculateCurrentOvers(); // Update main dashboard overs first
    await calculateBowler(); // Then calculate new bowler stats
    await calculateBatsman(); // Update batsman stats
    calculateOversState(); // Finally update the over state display

    // Force refresh of reactive variables
    currentOvers.refresh();
    bowlerState.refresh();
    oversState.refresh();
  }

  /// when user clicks on end match
  Future<void> endMatch() async {
    await _repo.endMatch(matchId);
  }

  Future<void> onTapMainButton() async {
    if (!await isInningFinished()) {
      Get.snackbar(
        "Please finish the match",
        "ERROR !",
        duration: Duration(milliseconds: 1000),
      );
      return;
    }
    if (inningNo.value == 1) {
      CreateMatchModel model = CreateMatchModel(status: 'resume');
      _repo.updateMatch(model);
      SyncFeature syncFeature = SyncFeature();
      syncFeature.syncMatchUpdate(matchId: matchId);
      Get.toNamed(NAV_SHIFT_INNING, arguments: {'matchId': matchId});
    } else {
      endMatch();
      // Get.delete<ScoreboardController>();
      Get.offNamed(NAV_RESULT, arguments: {'matchId': matchId});
    }
  }
}
