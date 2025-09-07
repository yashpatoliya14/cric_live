import 'package:cric_live/utils/import_exports.dart';

class ScoreboardController extends ScoreboardBallActionManager {
  ScoreboardRepo _repo = ScoreboardRepo();

  ScoreboardController({required int matchId, ScoreboardRepo? repo})
    : _repo = repo ?? ScoreboardRepo(),
      super(repo ?? ScoreboardRepo(), matchId);

  @override
  void onInit() {
    super.onInit();

    // resetControllerState();
    calculateBatsman();
    calculateCurrentOvers();
    calculateOversState();
    calculateBowler();
    calculateCRR();
    calculateRuns();
    calculateWicket();
    initializeMatch(matchId);
  }

  @override
  void onReady() {
    super.onReady();
    // Ensure we have the latest match data when view is ready
    // refreshAllData();
  }

  //endregion

  @override
  void dispose() {
    super.dispose();
  }

  updateMatchStatus(String status) async {
    CreateMatchModel matchModel = await _repo.findMatch(matchId);
    matchModel.status = status;
    await _repo.updateMatch(matchModel);
  }

  onWillPopScope() async {
    if (currentOvers < totalOvers.toDouble()) {
      return await getDialogBox(
        onMain: () async {
          await updateMatchStatus("resume");
          SyncFeature syncFeature = SyncFeature();
          syncFeature.syncMatchUpdate(matchId: matchId);
          Get.back();
        },
        title: "Sure want to close",
        closeText: "cancel",
        mainText: "close",
      );
    }
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}
